import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// 테마 상태 클래스
class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;
  final Color accentColor;
  final bool useDynamicColors;
  final double borderRadius;
  final bool useMaterial3;

  const ThemeState({
    required this.themeMode,
    required this.primaryColor,
    required this.accentColor,
    required this.useDynamicColors,
    required this.borderRadius,
    required this.useMaterial3,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Color? accentColor,
    bool? useDynamicColors,
    double? borderRadius,
    bool? useMaterial3,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      borderRadius: borderRadius ?? this.borderRadius,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
    );
  }
}

/// 테마 관리 클래스
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState(
    themeMode: ThemeMode.system,
    primaryColor: AppTheme.primary,
    accentColor: AppTheme.secondary,
    useDynamicColors: true,
    borderRadius: 12.0,
    useMaterial3: true,
  )) {
    _loadThemeSettings();
  }

  /// 테마 설정 로드
  Future<void> _loadThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
      final primaryColorValue = prefs.getInt('primary_color') ?? AppTheme.primary.value;
      final accentColorValue = prefs.getInt('accent_color') ?? AppTheme.secondary.value;
      final useDynamicColors = prefs.getBool('use_dynamic_colors') ?? true;
      final borderRadius = prefs.getDouble('border_radius') ?? 12.0;
      final useMaterial3 = prefs.getBool('use_material3') ?? true;

      state = state.copyWith(
        themeMode: ThemeMode.values[themeModeIndex],
        primaryColor: Color(primaryColorValue),
        accentColor: Color(accentColorValue),
        useDynamicColors: useDynamicColors,
        borderRadius: borderRadius,
        useMaterial3: useMaterial3,
      );
    } catch (e) {
      // 기본값 사용
    }
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', themeMode.index);
      
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      // 에러 처리
    }
  }

  /// 프라이머리 컬러 변경
  Future<void> setPrimaryColor(Color color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('primary_color', color.value);
      
      state = state.copyWith(primaryColor: color);
    } catch (e) {
      // 에러 처리
    }
  }

  /// 액센트 컬러 변경
  Future<void> setAccentColor(Color color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('accent_color', color.value);
      
      state = state.copyWith(accentColor: color);
    } catch (e) {
      // 에러 처리
    }
  }

  /// 동적 컬러 사용 여부 변경
  Future<void> setUseDynamicColors(bool useDynamicColors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_dynamic_colors', useDynamicColors);
      
      state = state.copyWith(useDynamicColors: useDynamicColors);
    } catch (e) {
      // 에러 처리
    }
  }

  /// 테마 설정 전체 업데이트
  Future<void> updateThemeSettings(ThemeState newSettings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', newSettings.themeMode.index);
      await prefs.setInt('primary_color', newSettings.primaryColor.value);
      await prefs.setInt('accent_color', newSettings.accentColor.value);
      await prefs.setBool('use_dynamic_colors', newSettings.useDynamicColors);
      await prefs.setDouble('border_radius', newSettings.borderRadius);
      await prefs.setBool('use_material3', newSettings.useMaterial3);
      
      state = newSettings;
    } catch (e) {
      // 에러 처리
    }
  }

  /// 현재 테마 데이터 가져오기
  ThemeData get currentTheme {
    if (state.themeMode == ThemeMode.dark) {
      return AppTheme.darkTheme;
    } else if (state.themeMode == ThemeMode.light) {
      return AppTheme.lightTheme;
    } else {
      // 시스템 테마
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
  }

  /// 다크 테마 여부
  bool get isDarkMode {
    if (state.themeMode == ThemeMode.dark) return true;
    if (state.themeMode == ThemeMode.light) return false;
    
    // 시스템 테마
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }
}

/// 테마 프로바이더
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// 현재 테마 데이터 프로바이더
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.currentTheme;
});

/// 다크모드 여부 프로바이더
final isDarkModeProvider = Provider<bool>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.isDarkMode;
});
