import 'package:flutter/material.dart';

/// EmotiFlow 앱의 컬러 팔레트
/// UI/UX 가이드에 정의된 모든 색상을 포함
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors — 세이지 그린 (자연, 성장, 안정)
  static const Color primary = Color(0xFF6B8F71);
  static const Color primaryLight = Color(0xFF8FAF95);
  static const Color primaryDark = Color(0xFF4A6B50);

  // Secondary Brand Colors — 웜 클레이 (따뜻함, 손으로 쓴 일기)
  static const Color secondary = Color(0xFFAB8B6B);
  static const Color secondaryLight = Color(0xFFC9A98A);
  static const Color secondaryDark = Color(0xFF8A6A4E);

  // Semantic Colors (의미론적 색상)
  static const Color success = Color(0xFF10B981);      // 에메랄드 - 성장과 긍정
  static const Color successLight = Color(0xFF34D399); // 밝은 에메랄드
  static const Color successDark = Color(0xFF059669);  // 어두운 에메랄드

  static const Color warning = Color(0xFFF59E0B);      // 앰버 - 주의와 경계
  static const Color warningLight = Color(0xFFFBBF24); // 밝은 앰버
  static const Color warningDark = Color(0xFFD97706);  // 어두운 앰버

  static const Color error = Color(0xFFEF4444);        // 레드 - 위험과 경고
  static const Color errorLight = Color(0xFFF87171);   // 밝은 레드
  static const Color errorDark = Color(0xFFDC2626);    // 어두운 레드

  static const Color info = Color(0xFF3B82F6);         // 블루 - 정보와 안내
  static const Color infoLight = Color(0xFF60A5FA);    // 밝은 블루
  static const Color infoDark = Color(0xFF2563EB);     // 어두운 블루

  // Neutral Colors — 따뜻한 파피루스 계열 (차가운 슬레이트 대신)
  static const Color background = Color(0xFFFAF8F5);
  static const Color backgroundSecondary = Color(0xFFF2EDE8);
  static const Color backgroundTertiary = Color(0xFFE8E0D8);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFAF8F5);
  static const Color surfaceTertiary = Color(0xFFF2EDE8);

  static const Color textPrimary = Color(0xFF1C1917);   // 따뜻한 거의 검정
  static const Color textSecondary = Color(0xFF57534E);  // 따뜻한 중간 회색
  static const Color textTertiary = Color(0xFF78716C);   // 3차 텍스트
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE7E0D8);
  static const Color borderSecondary = Color(0xFFD6CEC4);
  static const Color borderFocus = primary;

  // Dark Theme Colors — 따뜻한 다크 (차가운 슬레이트 대신)
  static const Color darkBackground = Color(0xFF1A1C18);  // 따뜻한 다크 그린-블랙
  static const Color darkSurface = Color(0xFF22261F);
  static const Color darkTextPrimary = Color(0xFFE8E6E0);
  static const Color darkTextSecondary = Color(0xFFB5B0A8);
  static const Color darkBorder = Color(0xFF3A3F35);

  // Emotion Colors (감정별 색상)
  static const Map<String, Map<String, Color>> emotions = {
    'joy': {
      'primary': Color(0xFFFBBF24),      // 기쁨 - 노랑
      'light': Color(0xFFFCD34D),        // 밝은 노랑
      'dark': Color(0xFFF59E0B),         // 어두운 노랑
      'background': Color(0xFFFEF3C7),   // 배경 노랑
    },
    'gratitude': {
      'primary': Color(0xFFF97316),      // 감사 - 주황
      'light': Color(0xFFFB923C),        // 밝은 주황
      'dark': Color(0xFFEA580C),         // 어두운 주황
      'background': Color(0xFFFFEDD5),   // 배경 주황
    },
    'excitement': {
      'primary': Color(0xFFEC4899),      // 설렘 - 핑크
      'light': Color(0xFFF472B6),        // 밝은 핑크
      'dark': Color(0xFFDB2777),         // 어두운 핑크
      'background': Color(0xFFFCE7F3),   // 배경 핑크
    },
    'calm': {
      'primary': Color(0xFF10B981),      // 평온 - 초록
      'light': Color(0xFF34D399),        // 밝은 초록
      'dark': Color(0xFF059669),         // 어두운 초록
      'background': Color(0xFFD1FAE5),   // 배경 초록
    },
    'love': {
      'primary': Color(0xFFEF4444),      // 사랑 - 빨강
      'light': Color(0xFFF87171),        // 밝은 빨강
      'dark': Color(0xFFDC2626),         // 어두운 빨강
      'background': Color(0xFFFEE2E2),   // 배경 빨강
    },
    'sadness': {
      'primary': Color(0xFF3B82F6),      // 슬픔 - 파랑
      'light': Color(0xFF60A5FA),        // 밝은 파랑
      'dark': Color(0xFF2563EB),         // 어두운 파랑
      'background': Color(0xFFDBEAFE),   // 배경 파랑
    },
    'anger': {
      'primary': Color(0xFF7C3AED),      // 분노 - 보라
      'light': Color(0xFFA78BFA),        // 밝은 보라
      'dark': Color(0xFF5B21B6),         // 어두운 보라
      'background': Color(0xFFEDE9FE),   // 배경 보라
    },
    'fear': {
      'primary': Color(0xFF6B7280),      // 두려움 - 회색
      'light': Color(0xFF9CA3AF),        // 밝은 회색
      'dark': Color(0xFF374151),         // 어두운 회색
      'background': Color(0xFFF3F4F6),   // 배경 회색
    },
  };

  /// 감정 색상 가져오기
  static Color getEmotionColor(String emotion, String variant) {
    return emotions[emotion]?[variant] ?? textSecondary;
  }

  /// 감정 기본 색상 가져오기
  static Color getEmotionPrimary(String emotion) {
    return emotions[emotion]?['primary'] ?? textSecondary;
  }

  /// 감정 배경 색상 가져오기
  static Color getEmotionBackground(String emotion) {
    return emotions[emotion]?['background'] ?? surface;
  }
}
