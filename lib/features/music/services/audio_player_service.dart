import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  Future<void> _ensureSession() async {
    if (_initialized) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _initialized = true;
  }

  Future<bool> playUrl(String url, {double volume = 0.7}) async {
    await _ensureSession();
    try {
      await _player.setUrl(url);
      await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.play();
      return true;
    } catch (e) {
      // 간단 로깅
      // 무음/네트워크 문제/코덱 문제 등
      // ignore: avoid_print
      print('Audio play error: $e');
      return false;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> setVolume(double volume) async {
    final safe = volume.clamp(0.0, 1.0);
    await _player.setVolume(safe);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}


