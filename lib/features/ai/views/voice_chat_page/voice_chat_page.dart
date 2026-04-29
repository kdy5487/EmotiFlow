import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/ai/gemini/gemini_service.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/services/soniox_service.dart';
import '../../../../core/services/usage_limit_service.dart';
import '../../../../shared/widgets/ads/banner_ad_widget.dart';
import '../../../../shared/widgets/ads/reward_ad_button.dart';

// ── 상태 모델 ──────────────────────────────────────────

enum VoicePageState { idle, listening, processing, speaking, error }

class _ChatTurn {
  final String text;
  final bool isUser;
  _ChatTurn({required this.text, required this.isUser});
}

// ── 페이지 ─────────────────────────────────────────────

class VoiceChatPage extends ConsumerStatefulWidget {
  const VoiceChatPage({super.key});

  @override
  ConsumerState<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends ConsumerState<VoiceChatPage>
    with TickerProviderStateMixin {
  VoicePageState _pageState = VoicePageState.idle;

  final List<_ChatTurn> _turns = [];
  String _draftText = '';
  String _statusText = '마이크 버튼을 눌러 시작하세요';
  String? _errorMessage;
  int _remainingVoice = 0;

  // Soniox 구독
  StreamSubscription<String>? _transcriptSub;
  StreamSubscription<String>? _finalSub;
  StreamSubscription<String>? _errorSub;

  // 애니메이션
  late final AnimationController _pulseCtrl;
  late final AnimationController _waveCtrl;
  late final Animation<double> _pulseAnim;

  final _soniox = SonioxService.instance;
  final _scrollCtrl = ScrollController();

  // 더미 데이터 모드 (UI 테스트용)
  bool _isDummyMode = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _subscribeToSoniox();
    _loadUsageCount();
    AdService.instance.loadRewardedAd();
    // 최초 진입 시 사용량 정책 안내
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await UsageLimitService.instance.showPolicyIfNeeded(
          context,
          UsageType.sonioxSession,
        );
      }
    });
  }

  /// 더미 데이터로 UI 시뮬레이션 (테스트용 — 언제든 삭제 가능)
  Future<void> _runDummySession() async {
    setState(() {
      _isDummyMode = true;
      _turns.clear();
      _pageState = VoicePageState.listening;
      _statusText = '더미 세션 실행 중...';
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _turns.add(_ChatTurn(text: '오늘 발표가 잘 됐어. 팀장님이 칭찬해 주셨어.', isUser: true));
      _pageState = VoicePageState.processing;
      _statusText = 'AI가 생각하는 중...';
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final ai = await GeminiService.instance.generateEmotionBasedQuestion(
      '기쁨',
      '오늘 발표가 잘 됐어. 팀장님이 칭찬해 주셨어.',
      [],
    );
    setState(() {
      _turns.add(_ChatTurn(text: ai, isUser: false));
      _pageState = VoicePageState.idle;
      _statusText = '더미 세션 완료 (삭제 버튼으로 초기화)';
      _isDummyMode = true;
    });
    _scrollToBottom();
  }

  void _clearDummySession() {
    setState(() {
      _turns.clear();
      _isDummyMode = false;
      _pageState = VoicePageState.idle;
      _statusText = '마이크 버튼을 눌러 시작하세요';
    });
  }

  Future<void> _loadUsageCount() async {
    final r = await UsageLimitService.instance
        .remainingWithBonus(UsageType.sonioxSession);
    if (!mounted) return;
    setState(() => _remainingVoice = r);
  }

  void _subscribeToSoniox() {
    _transcriptSub = _soniox.onTranscript.listen((text) {
      if (!mounted) return;
      setState(() => _draftText = text);
    });

    _finalSub = _soniox.onFinal.listen((text) async {
      if (!mounted) return;
      setState(() {
        _draftText = '';
        _turns.add(_ChatTurn(text: text, isUser: true));
        _pageState = VoicePageState.processing;
        _statusText = 'AI가 생각하고 있어요...';
      });
      _scrollToBottom();
      await _fetchAiResponse(text);
    });

    _errorSub = _soniox.onError.listen((msg) {
      if (!mounted) return;
      setState(() {
        _pageState = VoicePageState.error;
        _errorMessage = msg;
        _statusText = '오류가 발생했습니다';
      });
      _waveCtrl.stop();
    });
  }

  @override
  void dispose() {
    _transcriptSub?.cancel();
    _finalSub?.cancel();
    _errorSub?.cancel();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _scrollCtrl.dispose();
    _soniox.cancel();
    super.dispose();
  }

  // ── 마이크 버튼 핸들러 ──────────────────────────────

  Future<void> _onMicTap() async {
    if (_pageState == VoicePageState.processing ||
        _pageState == VoicePageState.speaking) return;

    if (_pageState == VoicePageState.listening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    // 권한 확인
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '마이크 권한이 필요합니다. 설정에서 허용해주세요.';
        _pageState = VoicePageState.error;
      });
      return;
    }

    setState(() {
      _pageState = VoicePageState.listening;
      _draftText = '';
      _errorMessage = null;
      _statusText = '말씀해주세요...';
    });
    _waveCtrl.repeat();

    final ok = await _soniox.start(languageHints: const ['ko']);
    if (!ok && mounted) {
      setState(() {
        _pageState = VoicePageState.idle;
        _statusText = '마이크 버튼을 눌러 시작하세요';
      });
      _waveCtrl.stop();
    }
  }

  Future<void> _stopListening() async {
    _waveCtrl.stop();
    setState(() {
      _pageState = VoicePageState.processing;
      _statusText = '처리 중...';
    });
    await _soniox.stop();
  }

  // ── Gemini AI 응답 ───────────────────────────────────

  Future<void> _fetchAiResponse(String userText) async {
    try {
      final history = _turns
          .map((t) => '${t.isUser ? "User" : "AI"}: ${t.text}')
          .toList();

      final response = await GeminiService.instance
          .generateEmotionBasedQuestion('평온', userText, history);

      if (!mounted) return;
      setState(() {
        _turns.add(_ChatTurn(text: response, isUser: false));
        _pageState = VoicePageState.idle;
        _statusText = '마이크 버튼을 눌러 계속 대화하세요';
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pageState = VoicePageState.error;
        _errorMessage = 'AI 응답 오류: $e';
        _statusText = '다시 시도해주세요';
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── UI ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 음성 대화'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // 남은 사용량 배지
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _remainingVoice > 0
                      ? cs.primaryContainer
                      : cs.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '남은 횟수 $_remainingVoice',
                  style: t.labelSmall?.copyWith(
                    color: _remainingVoice > 0
                        ? cs.onPrimaryContainer
                        : cs.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // 더미 데이터 테스트 버튼 (개발용 — 삭제 가능)
          IconButton(
            icon: Icon(
              _isDummyMode
                  ? Icons.delete_outline_rounded
                  : Icons.science_outlined,
            ),
            tooltip: _isDummyMode ? '더미 세션 초기화' : '더미 세션 실행 (테스트용)',
            onPressed: _isDummyMode ? _clearDummySession : _runDummySession,
          ),
          if (_turns.isNotEmpty && !_isDummyMode)
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: '대화 초기화',
              onPressed: () {
                _soniox.cancel();
                setState(() {
                  _turns.clear();
                  _draftText = '';
                  _errorMessage = null;
                  _pageState = VoicePageState.idle;
                  _statusText = '마이크 버튼을 눌러 시작하세요';
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 대화 영역
          Expanded(
            child: _turns.isEmpty && _draftText.isEmpty
                ? _buildEmptyState(cs, t)
                : _buildChatArea(cs, t),
          ),

          // 에러 배너
          if (_errorMessage != null)
            _buildErrorBanner(cs, t),

          // 인식 중 텍스트
          if (_draftText.isNotEmpty)
            _buildDraftBubble(cs, t),

          // 상태 텍스트
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              _statusText,
              style: t.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.45),
              ),
            ),
          ),

          // 사용량 소진 시 보상형 광고 버튼
          if (_remainingVoice <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: RewardAdButton(
                usageType: UsageType.sonioxSession,
                onRewarded: _loadUsageCount,
              ),
            ),

          // 마이크 버튼
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _buildMicButton(cs),
          ),

          // 배너 광고
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, TextTheme t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.record_voice_over_rounded,
              size: 72, color: cs.primary.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(
            'AI에게 오늘 하루를\n음성으로 이야기해보세요',
            style: t.titleMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.4),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(ColorScheme cs, TextTheme t) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _turns.length,
      itemBuilder: (_, i) => _ChatBubble(turn: _turns[i], cs: cs, t: t),
    );
  }

  Widget _buildDraftBubble(ColorScheme cs, TextTheme t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.mic_rounded, size: 16,
              color: const Color(0xFFE05B5B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _draftText,
              style: t.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.65),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme cs, TextTheme t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 18, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: t.bodySmall?.copyWith(color: cs.onErrorContainer),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.close, size: 18, color: cs.onErrorContainer),
            onPressed: () => setState(() {
              _errorMessage = null;
              _pageState = VoicePageState.idle;
              _statusText = '마이크 버튼을 눌러 시작하세요';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton(ColorScheme cs) {
    final isListening = _pageState == VoicePageState.listening;
    final isProcessing = _pageState == VoicePageState.processing;
    final isInteractable =
        _pageState == VoicePageState.idle ||
        _pageState == VoicePageState.listening ||
        _pageState == VoicePageState.error;

    final micColor = isListening
        ? const Color(0xFFE05B5B)
        : isProcessing
            ? cs.secondary
            : cs.primary;

    return GestureDetector(
      onTap: isInteractable ? _onMicTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 파동 (녹음 중)
          if (isListening)
            ..._buildWaveRings(),

          // 펄스 (대기)
          if (_pageState == VoicePageState.idle)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withOpacity(0.1),
                  ),
                ),
              ),
            ),

          // 처리 중 링
          if (isProcessing)
            SizedBox(
              width: 84,
              height: 84,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.secondary.withOpacity(0.5),
              ),
            ),

          // 메인 버튼
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isInteractable ? micColor : micColor.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: micColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              isListening
                  ? Icons.stop_rounded
                  : isProcessing
                      ? Icons.hourglass_top_rounded
                      : Icons.mic_none_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWaveRings() {
    return List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _waveCtrl,
        builder: (_, __) {
          final t = (_waveCtrl.value + i * 0.333) % 1.0;
          final size = 78.0 + t * 90;
          final opacity = (1.0 - t) * 0.38;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE05B5B).withOpacity(opacity),
                width: 2,
              ),
            ),
          );
        },
      );
    });
  }
}

// ── 대화 버블 위젯 ─────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final _ChatTurn turn;
  final ColorScheme cs;
  final TextTheme t;

  const _ChatBubble({required this.turn, required this.cs, required this.t});

  @override
  Widget build(BuildContext context) {
    final isUser = turn.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.psychology_rounded,
                  size: 18, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                turn.text,
                style: t.bodyMedium?.copyWith(
                  color: isUser ? cs.onPrimary : cs.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.person_rounded,
                  size: 18, color: cs.onPrimaryContainer),
            ),
          ],
        ],
      ),
    );
  }
}
