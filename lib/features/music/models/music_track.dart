import 'package:flutter/foundation.dart';

/// 감정 기반 음악 트랙 메타데이터
@immutable
class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final Duration duration;
  final List<String> tags; // 예: calm, focus, relax, joy, sad
  final int bpm; // 대략적인 템포
  final String coverImageUrl; // 썸네일 (선택)
  final String previewUrl; // 미리듣기/전체 재생 URL (미구현 시 placeholder)

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.tags,
    required this.bpm,
    required this.coverImageUrl,
    required this.previewUrl,
  });
}



