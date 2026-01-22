import 'package:flutter/material.dart';

/// 감정별 캐릭터 이미지 매핑
///
/// EmotiFlow의 각 감정에 대응하는 캐릭터 이미지 경로를 관리합니다.
class EmotionCharacterMap {
  // Private constructor to prevent instantiation
  EmotionCharacterMap._();

  /// 대표 캐릭터 (감정 선택 전 기본 캐릭터)
  static const String defaultCharacter =
      'assets/images/characters/Emoti_logo_big.png';

  /// 감정별 캐릭터 이미지 매핑
  ///
  /// 각 감정에 대응하는 캐릭터 이미지 파일 경로
  /// assets/images/emotions 폴더의 이미지 사용
  static const Map<String, String> characterAssets = {
    // 긍정적 감정
    '기쁨': 'assets/images/emotions/happy.PNG',
    '설렘': 'assets/images/emotions/excited.PNG',
    '감사': 'assets/images/emotions/love.PNG',
    '평온': 'assets/images/emotions/calm.PNG',

    // 부정적 감정
    '슬픔': 'assets/images/emotions/sad.PNG',
    '분노': 'assets/images/emotions/grumpy.PNG',
    '걱정': 'assets/images/emotions/scared.PNG',

    // 중립적 감정
    '지루함': 'assets/images/emotions/neutral.PNG',
    '놀람': 'assets/images/emotions/surprised.PNG',
    '혼란': 'assets/images/emotions/confused.PNG',
  };

  /// 감정별 배경 색상 (선택적 - 추후 UI 개선 시 사용)
  static const Map<String, int> emotionBackgroundColors = {
    '기쁨': 0xFFFFF9E6, // 따뜻한 노란색 배경
    '설렘': 0xFFFFE6F0, // 분홍빛 배경
    '감사': 0xFFE6F9FF, // 밝은 하늘색 배경
    '평온': 0xFFE6F9E6, // 연한 초록 배경
    '슬픔': 0xFFE6E6F9, // 연한 보라 배경
    '분노': 0xFFFFE6E6, // 연한 빨강 배경
    '걱정': 0xFFFFF0E6, // 연한 주황 배경
    '지루함': 0xFFF0F0F0, // 회색 배경
    '놀람': 0xFFFFF9E6, // 밝은 노란색 배경
    '혼란': 0xFFF0E6FF, // 연한 보라 배경
  };

  /// 감정별 포인트 컬러 (일기 목록 카드 그라데이션용)
  static const Map<String, Color> emotionPointColors = {
    '설렘': Color(0xFFFFD6C9),
    '기쁨': Color(0xFFFFE8A3),
    '평온': Color(0xFFCFF5E7),
    '슬픔': Color(0xFFDCE9FF),
    '분노': Color(0xFFE7D9FF),
    '감사': Color(0xFFE6F9FF),
    '걱정': Color(0xFFFFF0E6),
    '지루함': Color(0xFFF0F0F0),
    '놀람': Color(0xFFFFF9E6),
    '혼란': Color(0xFFF0E6FF),
  };

  /// 감정에 해당하는 포인트 컬러 가져오기
  static Color getPointColor(String? emotion) {
    if (emotion == null || emotion.isEmpty) {
      return const Color(0xFFF0F0F0);
    }
    final emotionKorean = emotionIdToKorean[emotion] ?? emotion;
    return emotionPointColors[emotionKorean] ?? const Color(0xFFF0F0F0);
  }

  /// 영문 emotion ID를 한글로 변환
  static const Map<String, String> emotionIdToKorean = {
    'joy': '기쁨',
    'sadness': '슬픔',
    'anger': '분노',
    'calm': '평온',
    'excitement': '설렘',
    'worry': '걱정',
    'gratitude': '감사',
    'boredom': '지루함',
    'surprise': '놀람',
    'confusion': '혼란',
  };

  /// 감정에 해당하는 캐릭터 이미지 경로 가져오기
  ///
  /// [emotion] 감정 이름 (한글 또는 영문 ID)
  /// 반환: 캐릭터 이미지 경로 (없으면 기본 캐릭터)
  static String getCharacterAsset(String? emotion) {
    if (emotion == null || emotion.isEmpty) {
      return defaultCharacter;
    }

    // 영문 ID인 경우 한글로 변환
    final emotionKorean = emotionIdToKorean[emotion] ?? emotion;

    // 매핑된 캐릭터 반환, 없으면 기본 캐릭터
    return characterAssets[emotionKorean] ?? defaultCharacter;
  }

  /// 감정에 해당하는 배경 색상 가져오기
  ///
  /// [emotion] 감정 이름 (한글 또는 영문 ID)
  /// 반환: 배경 색상 코드 (없으면 기본 흰색)
  static int getBackgroundColor(String? emotion) {
    if (emotion == null || emotion.isEmpty) {
      return 0xFFFFFFFF; // 기본 흰색
    }

    // 영문 ID인 경우 한글로 변환
    final emotionKorean = emotionIdToKorean[emotion] ?? emotion;

    // 매핑된 배경색 반환, 없으면 흰색
    return emotionBackgroundColors[emotionKorean] ?? 0xFFFFFFFF;
  }

  /// 모든 사용 가능한 감정 목록 (한글)
  static List<String> get availableEmotions => characterAssets.keys.toList();

  /// 캐릭터 이미지가 존재하는지 확인
  static bool hasCharacter(String emotion) {
    final emotionKorean = emotionIdToKorean[emotion] ?? emotion;
    return characterAssets.containsKey(emotionKorean);
  }

  /// 감정별 테마 색상 가져오기 (primary, secondary)
  static Map<String, Color> getEmotionColors(String? emotion) {
    if (emotion == null || emotion.isEmpty) {
      return {
        'primary': const Color(0xFF8B7FF6),
        'secondary': const Color(0xFFDA77F2),
      };
    }

    final emotionKorean = emotionIdToKorean[emotion] ?? emotion;

    switch (emotionKorean) {
      case '기쁨':
        return {
          'primary': const Color(0xFFFFD700),
          'secondary': const Color(0xFFFFA500),
        };
      case '설렘':
        return {
          'primary': const Color(0xFFFF69B4),
          'secondary': const Color(0xFFDA77F2),
        };
      case '감사':
        return {
          'primary': const Color(0xFF87CEEB),
          'secondary': const Color(0xFF6B73FF),
        };
      case '평온':
        return {
          'primary': const Color(0xFF87CEEB),
          'secondary': const Color(0xFF90EE90),
        };
      case '슬픔':
        return {
          'primary': const Color(0xFF6B73FF),
          'secondary': const Color(0xFF9370DB),
        };
      case '분노':
        return {
          'primary': const Color(0xFFFF6B6B),
          'secondary': const Color(0xFFFF4500),
        };
      case '걱정':
        return {
          'primary': const Color(0xFF9370DB),
          'secondary': const Color(0xFF8B7FF6),
        };
      default:
        return {
          'primary': const Color(0xFF8B7FF6),
          'secondary': const Color(0xFFDA77F2),
        };
    }
  }
}
