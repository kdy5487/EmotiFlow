import 'package:flutter/material.dart';

/// EmotiFlow 앱의 컬러 팔레트
/// UI/UX 가이드에 정의된 모든 색상을 포함
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors (주요 브랜드 색상)
  static const Color primary = Color(0xFF6366F1);      // 인디고 - 신뢰와 안정감
  static const Color primaryLight = Color(0xFF818CF8); // 밝은 인디고
  static const Color primaryDark = Color(0xFF4F46E5);  // 어두운 인디고

  // Secondary Brand Colors (보조 브랜드 색상)
  static const Color secondary = Color(0xFFEC4899);    // 핑크 - 따뜻함과 공감
  static const Color secondaryLight = Color(0xFFF472B6); // 밝은 핑크
  static const Color secondaryDark = Color(0xFFDB2777);  // 어두운 핑크

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

  // Neutral Colors (중성 색상)
  static const Color background = Color(0xFFF8FAFC);   // 슬레이트 - 깔끔함
  static const Color backgroundSecondary = Color(0xFFF1F5F9); // 보조 배경
  static const Color backgroundTertiary = Color(0xFFE2E8F0);  // 3차 배경

  static const Color surface = Color(0xFFFFFFFF);      // 화이트 - 순수함
  static const Color surfaceSecondary = Color(0xFFF8FAFC);    // 보조 표면
  static const Color surfaceTertiary = Color(0xFFF1F5F9);    // 3차 표면

  static const Color textPrimary = Color(0xFF1E293B);  // 슬레이트 - 가독성
  static const Color textSecondary = Color(0xFF64748B); // 슬레이트 - 부가 정보
  static const Color textTertiary = Color(0xFF94A3B8);  // 3차 텍스트
  static const Color textInverse = Color(0xFFFFFFFF);   // 반전 텍스트

  static const Color border = Color(0xFFE2E8F0);       // 테두리 기본
  static const Color borderSecondary = Color(0xFFCBD5E1); // 보조 테두리
  static const Color borderFocus = Color(0xFF6366F1);   // 포커스 테두리

  // Dark Theme Colors (다크 테마 색상)
  static const Color darkBackground = Color(0xFF0F172A); // 다크 배경
  static const Color darkSurface = Color(0xFF1E293B);   // 다크 표면
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // 다크 텍스트
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // 다크 보조 텍스트
  static const Color darkBorder = Color(0xFF334155);    // 다크 테두리

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
