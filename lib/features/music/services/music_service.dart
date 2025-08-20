import 'dart:math';

import '../models/music_track.dart';

/// 감정 기반 음악 추천 서비스 (스켈레톤)
/// 외부 API(Spotify/YouTube Music) 연동 전까지는 로컬 카탈로그를 사용
class MusicService {
  static const Map<String, List<MusicTrack>> _catalogByEmotion = {
    // 감정별 임시 BGM 카탈로그 (무가사 지향)
    '기쁨': [
      MusicTrack(
        id: 'joy_1',
        title: 'Sunny Morning',
        artist: 'Studio BGM',
        duration: Duration(minutes: 3, seconds: 2),
        tags: ['joy', 'bright', 'energy'],
        bpm: 120,
        coverImageUrl: '',
        previewUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      ),
      MusicTrack(
        id: 'joy_2',
        title: 'Happy Stroll',
        artist: 'Loft Instrumentals',
        duration: Duration(minutes: 2, seconds: 42),
        tags: ['joy', 'walk', 'uplifting'],
        bpm: 110,
        coverImageUrl: '',
        previewUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      ),
    ],
    '슬픔': [
      MusicTrack(
        id: 'sad_1',
        title: 'Blue Rain',
        artist: 'Calm Ensemble',
        duration: Duration(minutes: 3, seconds: 40),
        tags: ['sad', 'calm', 'piano'],
        bpm: 70,
        coverImageUrl: '',
        previewUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
      ),
      MusicTrack(
        id: 'sad_2',
        title: 'Distant Lights',
        artist: 'Nocturne Lab',
        duration: Duration(minutes: 4, seconds: 5),
        tags: ['sad', 'ambient'],
        bpm: 65,
        coverImageUrl: '',
        previewUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
      ),
    ],
    '평온': [
      MusicTrack(
        id: 'calm_1',
        title: 'Quiet Meadow',
        artist: 'Ambient Fields',
        duration: Duration(minutes: 3, seconds: 10),
        tags: ['calm', 'nature', 'focus'],
        bpm: 85,
        coverImageUrl: '',
        previewUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      ),
      MusicTrack(
        id: 'calm_2',
        title: 'Soft Breeze',
        artist: 'Meditation Notes',
        duration: Duration(minutes: 2, seconds: 58),
        tags: ['calm', 'relax'],
        bpm: 80,
        coverImageUrl: '',
        previewUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      ),
    ],
    // 필요 시 다른 감정도 추가
  };

  /// 감정/강도/컨텍스트에 따른 추천 리스트 (일별 변동)
  Future<List<MusicTrack>> fetchRecommendations({
    required String emotion,
    required int intensity, // 1-10
    required bool basedOnTodayDiary, // true: 오늘의 감정 기반, false: AI 분석 결과 기반
    DateTime? seedDate, // 없으면 오늘 날짜
  }) async {
    final catalog = _catalogByEmotion[emotion];
    if (catalog == null || catalog.isEmpty) return [];

    // 강도에 따른 템포 정렬(간단 로직): 높은 강도일수록 bpm 높은 트랙 우선
    final sorted = [...catalog]
      ..sort((a, b) => (intensity >= 6 ? b.bpm.compareTo(a.bpm) : a.bpm.compareTo(b.bpm)));

    // 날짜 기반 시드로 일별 변동 보장 (매일 다른 곡)
    final date = seedDate ?? DateTime.now();
    final seed = date.year * 10000 + date.month * 100 + date.day + (basedOnTodayDiary ? 7 : 0);
    final rng = Random(seed);

    // 셔플 후 상위 5곡 반환 (카탈로그가 적으면 있는 만큼)
    final shuffled = [...sorted]..shuffle(rng);
    final takeCount = shuffled.length >= 5 ? 5 : shuffled.length;
    return shuffled.take(takeCount).toList();
  }
}


