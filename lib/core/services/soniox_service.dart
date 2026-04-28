import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'usage_limit_service.dart';

/// Soniox STT WebSocket 연결 상태
enum SonioxState { idle, connecting, recording, stopping, error }

/// Soniox 실시간 STT 서비스
///
/// WebSocket으로 PCM16bits 오디오를 스트리밍하여 실시간 음성 인식.
/// 공식 Flutter SDK 없음 → web_socket_channel + record 패키지로 직접 구현.
class SonioxService {
  static SonioxService? _instance;
  static SonioxService get instance => _instance ??= SonioxService._();
  SonioxService._();

  static const _wsEndpoint = 'wss://stt-rt.soniox.com/transcribe-websocket';
  static const _sampleRate = 16000;
  static const _model = 'stt-rt-preview';

  final _recorder = AudioRecorder();
  WebSocketChannel? _channel;
  StreamSubscription<Uint8List>? _audioSub;

  SonioxState _state = SonioxState.idle;
  SonioxState get state => _state;

  // 외부에서 구독할 스트림 컨트롤러
  final _transcriptController = StreamController<String>.broadcast();
  final _finalController = StreamController<String>.broadcast();
  final _stateController = StreamController<SonioxState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// 실시간 비확정 텍스트 스트림
  Stream<String> get onTranscript => _transcriptController.stream;

  /// 문장 확정 텍스트 스트림 (endpoint 감지 후)
  Stream<String> get onFinal => _finalController.stream;

  /// 상태 변화 스트림
  Stream<SonioxState> get onState => _stateController.stream;

  /// 에러 메시지 스트림
  Stream<String> get onError => _errorController.stream;

  String get _apiKey => dotenv.env['SONIOX_API_KEY'] ?? '';

  /// 음성 녹음 + STT 시작
  Future<bool> start({List<String> languageHints = const ['ko']}) async {
    if (_state != SonioxState.idle) return false;
    if (_apiKey.isEmpty || _apiKey == 'YOUR_SONIOX_API_KEY_HERE') {
      _emitError('Soniox API 키가 설정되지 않았습니다. .env 파일에 SONIOX_API_KEY를 입력해주세요.');
      return false;
    }

    // 사용량 한도 체크
    final usageOk = await UsageLimitService.instance
        .canUseWithBonus(UsageType.sonioxSession);
    if (!usageOk) {
      _emitError('오늘 음성 AI 사용량이 초과됐습니다. '
          '광고를 시청하면 추가 사용이 가능합니다.');
      return false;
    }

    // 마이크 권한 확인
    if (!await _recorder.hasPermission()) {
      _emitError('마이크 권한이 없습니다.');
      return false;
    }

    _setState(SonioxState.connecting);

    try {
      // 1. WebSocket 연결
      _channel = WebSocketChannel.connect(Uri.parse(_wsEndpoint));

      // 2. 설정 메시지 전송
      final config = jsonEncode({
        'api_key': _apiKey,
        'model': _model,
        'audio_format': 'pcm_s16le',
        'sample_rate': _sampleRate,
        'num_channels': 1,
        'language_hints': languageHints,
        'enable_endpoint_detection': true,
        'max_endpoint_delay_ms': 1200,
      });
      _channel!.sink.add(config);

      // 3. 서버 응답 수신 설정
      _channel!.stream.listen(
        _onWsMessage,
        onError: (e) => _emitError('WebSocket 오류: $e'),
        onDone: _onWsDone,
      );

      // 4. 마이크 스트리밍 시작
      final audioStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: _sampleRate,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );

      _audioSub = audioStream.listen(
        (chunk) => _channel?.sink.add(chunk),
        onError: (e) => _emitError('오디오 스트림 오류: $e'),
      );

      _setState(SonioxState.recording);
      // 세션 시작 시 사용량 카운터 증가
      await UsageLimitService.instance.increment(UsageType.sonioxSession);
      return true;
    } catch (e) {
      _emitError('STT 시작 실패: $e');
      await _cleanup();
      return false;
    }
  }

  /// 음성 녹음 중지 및 최종 결과 대기
  Future<void> stop() async {
    if (_state != SonioxState.recording) return;
    _setState(SonioxState.stopping);

    await _recorder.stop();
    _audioSub?.cancel();

    // 빈 프레임 전송 → 서버에 스트림 종료 알림
    _channel?.sink.add(Uint8List(0));
  }

  /// 강제 취소
  Future<void> cancel() async {
    await _recorder.cancel();
    await _cleanup();
    _setState(SonioxState.idle);
  }

  // ── 내부 처리 ────────────────────────────────────────

  void _onWsMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;

      if (data.containsKey('error')) {
        _emitError(data['error'].toString());
        return;
      }

      // 토큰 파싱
      final tokens = (data['tokens'] as List<dynamic>?) ?? [];
      final nonFinalText = StringBuffer();
      final finalText = StringBuffer();

      for (final token in tokens) {
        final text = token['text'] as String? ?? '';
        final isFinal = token['is_final'] as bool? ?? false;
        if (isFinal) {
          finalText.write(text);
        } else {
          nonFinalText.write(text);
        }
      }

      // 실시간 텍스트 전달
      final combined = finalText.toString() + nonFinalText.toString();
      if (combined.isNotEmpty && !_transcriptController.isClosed) {
        _transcriptController.add(combined);
      }

      // endpoint 감지 = 문장 완성
      final isEndpoint = data['is_endpoint'] as bool? ?? false;
      if (isEndpoint && finalText.isNotEmpty && !_finalController.isClosed) {
        _finalController.add(finalText.toString().trim());
      }

      // finished = 서버 처리 완료
      final isFinished = data['is_finished'] as bool? ?? false;
      if (isFinished) {
        final remaining = finalText.toString().trim();
        if (remaining.isNotEmpty && !_finalController.isClosed) {
          _finalController.add(remaining);
        }
        _cleanup();
        _setState(SonioxState.idle);
      }
    } catch (e) {
      debugPrint('Soniox 메시지 파싱 오류: $e');
    }
  }

  void _onWsDone() {
    if (_state == SonioxState.stopping || _state == SonioxState.recording) {
      _cleanup();
      _setState(SonioxState.idle);
    }
  }

  void _setState(SonioxState s) {
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
  }

  void _emitError(String msg) {
    debugPrint('SonioxService 오류: $msg');
    if (!_errorController.isClosed) _errorController.add(msg);
    _cleanup();
    _setState(SonioxState.error);
  }

  Future<void> _cleanup() async {
    await _audioSub?.cancel();
    _audioSub = null;
    await _channel?.sink.close();
    _channel = null;
    try {
      await _recorder.stop();
    } catch (_) {}
  }

  void dispose() {
    _cleanup();
    _transcriptController.close();
    _finalController.close();
    _stateController.close();
    _errorController.close();
  }
}
