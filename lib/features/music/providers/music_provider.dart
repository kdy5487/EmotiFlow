import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/music_track.dart';
import '../services/music_service.dart';
import '../services/audio_player_service.dart';
import '../../settings/providers/settings_provider.dart';

/// 감정 소스 유형: 오늘의 일기 vs AI 분석
enum EmotionSource { todayDiary, aiAnalysis }

/// 음악 상태
class MusicState {
  final bool isLoading;
  final List<MusicTrack> recommendations;
  final MusicTrack? nowPlaying;
  final String? currentEmotion;
  final int currentIntensity; // 1-10
  final EmotionSource emotionSource;
  final String? errorMessage;

  const MusicState({
    this.isLoading = false,
    this.recommendations = const [],
    this.nowPlaying,
    this.currentEmotion,
    this.currentIntensity = 5,
    this.emotionSource = EmotionSource.todayDiary,
    this.errorMessage,
  });

  MusicState copyWith({
    bool? isLoading,
    List<MusicTrack>? recommendations,
    MusicTrack? nowPlaying,
    String? currentEmotion,
    int? currentIntensity,
    EmotionSource? emotionSource,
    String? errorMessage,
  }) {
    return MusicState(
      isLoading: isLoading ?? this.isLoading,
      recommendations: recommendations ?? this.recommendations,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      currentEmotion: currentEmotion ?? this.currentEmotion,
      currentIntensity: currentIntensity ?? this.currentIntensity,
      emotionSource: emotionSource ?? this.emotionSource,
      errorMessage: errorMessage,
    );
  }
}

class MusicNotifier extends StateNotifier<MusicState> {
  final MusicService _service;
  final AudioPlayerService _audio;
  final Ref _ref;
  MusicNotifier(this._service, this._audio, this._ref) : super(const MusicState());

  Future<void> loadRecommendations({
    required String emotion,
    required int intensity,
    required EmotionSource source,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _service.fetchRecommendations(
        emotion: emotion,
        intensity: intensity,
        basedOnTodayDiary: source == EmotionSource.todayDiary,
      );
      state = state.copyWith(
        isLoading: false,
        recommendations: list,
        currentEmotion: emotion,
        currentIntensity: intensity,
        emotionSource: source,
        nowPlaying: list.isNotEmpty ? list.first : null,
      );
      // 자동재생 설정이면 첫 곡 재생
      if (list.isNotEmpty) {
        final settings = _ref.read(settingsProvider).settings.musicSettings;
        if (settings.enabled && settings.autoPlay) {
          final ok = await _audio.playUrl(list.first.previewUrl, volume: settings.volume);
          if (!ok) {
            // ignore: avoid_print
            print('Failed to auto play: ${list.first.previewUrl}');
          }
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void play(MusicTrack track) {
    state = state.copyWith(nowPlaying: track);
    final settings = _ref.read(settingsProvider).settings.musicSettings;
    if (settings.enabled) {
      _audio.playUrl(track.previewUrl, volume: settings.volume);
    }
  }

  void pause() {
    _audio.pause();
  }

  void stop() {
    _audio.stop();
  }

  void setVolume(double volume) {
    _audio.setVolume(volume);
  }

  void next() {
    final list = state.recommendations;
    if (state.nowPlaying == null || list.isEmpty) return;
    final idx = list.indexWhere((t) => t.id == state.nowPlaying!.id);
    final nextIdx = (idx + 1) % list.length;
    state = state.copyWith(nowPlaying: list[nextIdx]);
    final settings = _ref.read(settingsProvider).settings.musicSettings;
    if (settings.enabled) {
      _audio.playUrl(list[nextIdx].previewUrl, volume: settings.volume);
    }
  }

  void previous() {
    final list = state.recommendations;
    if (state.nowPlaying == null || list.isEmpty) return;
    final idx = list.indexWhere((t) => t.id == state.nowPlaying!.id);
    final prevIdx = (idx - 1 + list.length) % list.length;
    state = state.copyWith(nowPlaying: list[prevIdx]);
    final settings = _ref.read(settingsProvider).settings.musicSettings;
    if (settings.enabled) {
      _audio.playUrl(list[prevIdx].previewUrl, volume: settings.volume);
    }
  }
}

final musicServiceProvider = Provider<MusicService>((ref) => MusicService());
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) => AudioPlayerService());

final musicProvider = StateNotifierProvider<MusicNotifier, MusicState>((ref) {
  final service = ref.watch(musicServiceProvider);
  final audio = ref.watch(audioPlayerServiceProvider);
  return MusicNotifier(service, audio, ref);
});


