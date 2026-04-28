import 'package:flutter/material.dart';
import 'app_typography.dart';

class AppTheme {
  // Primary — 세이지 그린 (자연, 성장, 안정)
  static const Color primary = Color(0xFF6B8F71);
  static const Color primaryLight = Color(0xFF8FAF95);
  static const Color primaryDark = Color(0xFF4A6B50);

  // Secondary — 웜 클레이 (따뜻함, 손으로 쓴 일기)
  static const Color secondary = Color(0xFFAB8B6B);
  static const Color secondaryLight = Color(0xFFC9A98A);
  static const Color secondaryDark = Color(0xFF8A6A4E);
  
  // Emotion-based Colors
  static const Color joy = Color(0xFFFFD700);          // 기쁨 - 골드
  static const Color love = Color(0xFFFF69B4);         // 사랑 - 핑크
  static const Color calm = Color(0xFF87CEEB);         // 평온 - 하늘색
  static const Color sadness = Color(0xFF6B73FF);      // 슬픔 - 블루
  static const Color anger = Color(0xFFFF6B6B);        // 분노 - 레드
  static const Color fear = Color(0xFF9370DB);         // 두려움 - 퍼플
  static const Color surprise = Color(0xFFFFA500);     // 놀람 - 오렌지
  static const Color neutral = Color(0xFF9CA3AF);      // 중립 - 그레이
  
  // Neutral — 따뜻한 파피루스 계열
  static const Color background = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF57534E);
  static const Color textTertiary = Color(0xFF78716C);
  static const Color border = Color(0xFFE7E0D8);
  static const Color divider = Color(0xFFF2EDE8);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Dark Theme — 따뜻한 다크 (숲속 밤 느낌)
  static const Color darkBackground = Color(0xFF1A1C18);
  static const Color darkSurface = Color(0xFF22261F);
  static const Color darkSurfaceVariant = Color(0xFF2E3329);
  static const Color darkTextPrimary = Color(0xFFE8E6E0);
  static const Color darkTextSecondary = Color(0xFFB5B0A8);
  static const Color darkBorder = Color(0xFF3A3F35);
  static const Color darkDivider = Color(0xFF2A2E26);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD4E8DA),
        onPrimaryContainer: Color(0xFF1B3C21),
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFECDDD0),
        onSecondaryContainer: Color(0xFF3A2012),
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: Color(0xFFEFE8E0),
        outline: Color(0xFFB0A89E),
        outlineVariant: Color(0xFFE7E0D8),
        error: error,
        onError: Colors.white,
      ),
      // fontFamily: 'Pretendard', // 나중에 폰트 추가 시 활성화
      textTheme: AppTypography.lightTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(
          color: textTertiary.withOpacity(0.6),
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        onPrimary: Color(0xFF003917),
        primaryContainer: Color(0xFF1E4D26),
        onPrimaryContainer: Color(0xFFB5DFB9),
        secondary: secondaryLight,
        onSecondary: Color(0xFF2A1400),
        secondaryContainer: Color(0xFF4A2E1A),
        onSecondaryContainer: Color(0xFFE8D0BA),
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceVariant,
        outline: Color(0xFF8A8580),
        outlineVariant: Color(0xFF3A3F35),
        error: error,
        onError: Colors.white,
      ),
      // fontFamily: 'Pretendard', // 나중에 폰트 추가 시 활성화
      textTheme: AppTypography.darkTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: TextStyle(
          color: darkTextSecondary.withOpacity(0.6),
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical:16),
      ),
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: darkTextPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
