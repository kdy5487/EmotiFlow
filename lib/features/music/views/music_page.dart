import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_theme.dart';
import '../providers/music_provider.dart';
import '../models/music_track.dart';

class MusicPage extends ConsumerWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(musicProvider);
    final notifier = ref.read(musicProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('감정 기반 음악'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 소스/감정/강도 요약 및 로드 버튼
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('소스: ${state.emotionSource == EmotionSource.todayDiary ? '오늘의 감정' : 'AI 분석 결과'}'),
                      const SizedBox(height: 4),
                      Text('감정: ${state.currentEmotion ?? '-'}  강도: ${state.currentIntensity}'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          // 데모: 평온 감정 기준, 강도는 5로.
                          notifier.loadRecommendations(
                            emotion: state.currentEmotion ?? '평온',
                            intensity: state.currentIntensity,
                            source: state.emotionSource,
                          );
                        },
                  child: state.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('추천 불러오기'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 추천 리스트
            Expanded(
              child: state.recommendations.isEmpty
                  ? Center(
                      child: Text(
                        state.isLoading ? '로딩 중...' : '추천 곡이 없습니다. 상단에서 불러오기를 눌러보세요.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: state.recommendations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final track = state.recommendations[index];
                        return _TrackTile(
                          track: track,
                          isNowPlaying: state.nowPlaying?.id == track.id,
                          onTap: () => notifier.play(track),
                        );
                      },
                    ),
            ),

            // 미니 플레이어
            if (state.nowPlaying != null) _MiniPlayer(
              track: state.nowPlaying!,
              onNext: notifier.next,
              onPrev: notifier.previous,
              onPlay: () => notifier.play(state.nowPlaying!),
              onPause: notifier.pause,
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('오류: ${state.errorMessage}', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final MusicTrack track;
  final bool isNowPlaying;
  final VoidCallback onTap;
  const _TrackTile({required this.track, required this.isNowPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.primary.withOpacity(0.15),
        child: const Icon(Icons.music_note, color: AppTheme.primary),
      ),
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${track.artist} • ${track.bpm} BPM'),
      trailing: isNowPlaying ? const Icon(Icons.equalizer, color: AppTheme.primary) : const Icon(Icons.play_arrow),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  final MusicTrack track;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  const _MiniPlayer({required this.track, required this.onNext, required this.onPrev, required this.onPlay, required this.onPause});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.album, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${track.artist} • ${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(onPressed: onPlay, icon: const Icon(Icons.play_arrow)),
          IconButton(onPressed: onPause, icon: const Icon(Icons.pause)),
          IconButton(onPressed: onPrev, icon: const Icon(Icons.skip_previous)),
          IconButton(onPressed: onNext, icon: const Icon(Icons.skip_next)),
        ],
      ),
    );
  }
}


