import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';

/// 설정 서비스 클래스
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _settingsKey = 'app_settings';
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _accentColorKey = 'accent_color';
  static const String _useDynamicColorsKey = 'use_dynamic_colors';
  static const String _borderRadiusKey = 'border_radius';
  static const String _useMaterial3Key = 'use_material3';

  /// 앱 설정 가져오기
  Future<AppSettings> getAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        // JSON 파싱 시도
        try {
          final Map<String, dynamic> settingsMap = 
              Map<String, dynamic>.from(settingsJson as Map);
          return AppSettings.fromMap(settingsMap);
        } catch (e) {
          print('❌ 설정 JSON 파싱 실패, 기본값 사용: $e');
        }
      }
      
      // 기본 설정 반환
      return AppSettings.defaultSettings();
    } catch (e) {
      print('❌ 설정 가져오기 실패: $e');
      return AppSettings.defaultSettings();
    }
  }

  /// 앱 설정 저장
  Future<bool> saveAppSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsMap = settings.toMap();
      
      // SharedPreferences에 저장
      await prefs.setString(_settingsKey, settingsMap.toString());
      
      print('✅ 앱 설정 저장 성공');
      return true;
    } catch (e) {
      print('❌ 앱 설정 저장 실패: $e');
      return false;
    }
  }

  /// 테마 설정 가져오기
  Future<ThemeSettings> getThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return ThemeSettings(
        themeMode: ThemeMode.values[prefs.getInt(_themeModeKey) ?? 0],
        primaryColor: Color(prefs.getInt(_primaryColorKey) ?? 0xFF8B7FF6),
        accentColor: Color(prefs.getInt(_accentColorKey) ?? 0xFFDA77F2),
        useDynamicColors: prefs.getBool(_useDynamicColorsKey) ?? true,
        borderRadius: prefs.getDouble(_borderRadiusKey) ?? 12.0,
        useMaterial3: prefs.getBool(_useMaterial3Key) ?? true,
      );
    } catch (e) {
      print('❌ 테마 설정 가져오기 실패: $e');
      return ThemeSettings.defaultSettings();
    }
  }

  /// 테마 설정 저장
  Future<bool> saveThemeSettings(ThemeSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt(_themeModeKey, settings.themeMode.index);
      await prefs.setInt(_primaryColorKey, settings.primaryColor.value);
      await prefs.setInt(_accentColorKey, settings.accentColor.value);
      await prefs.setBool(_useDynamicColorsKey, settings.useDynamicColors);
      await prefs.setDouble(_borderRadiusKey, settings.borderRadius);
      await prefs.setBool(_useMaterial3Key, settings.useMaterial3);
      
      print('✅ 테마 설정 저장 성공');
      return true;
    } catch (e) {
      print('❌ 테마 설정 저장 실패: $e');
      return false;
    }
  }

  /// 알림 설정 가져오기
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return NotificationSettings(
        pushNotificationsEnabled: prefs.getBool('push_notifications_enabled') ?? true,
        emailNotificationsEnabled: prefs.getBool('email_notifications_enabled') ?? false,
        dailyReminderEnabled: prefs.getBool('daily_reminder_enabled') ?? true,
        dailyReminderTime: TimeOfDay(
          hour: prefs.getInt('daily_reminder_hour') ?? 20,
          minute: prefs.getInt('daily_reminder_minute') ?? 0,
        ),
        weeklyReportEnabled: prefs.getBool('weekly_report_enabled') ?? true,
        emotionAnalysisEnabled: prefs.getBool('emotion_analysis_enabled') ?? true,
        achievementNotificationsEnabled: prefs.getBool('achievement_notifications_enabled') ?? true,
        quietHours: prefs.getStringList('quiet_hours') ?? ['22:00', '08:00'],
        doNotDisturbEnabled: prefs.getBool('do_not_disturb_enabled') ?? false,
      );
    } catch (e) {
      print('❌ 알림 설정 가져오기 실패: $e');
      return NotificationSettings.defaultSettings();
    }
  }

  /// 알림 설정 저장
  Future<bool> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('push_notifications_enabled', settings.pushNotificationsEnabled);
      await prefs.setBool('email_notifications_enabled', settings.emailNotificationsEnabled);
      await prefs.setBool('daily_reminder_enabled', settings.dailyReminderEnabled);
      await prefs.setInt('daily_reminder_hour', settings.dailyReminderTime.hour);
      await prefs.setInt('daily_reminder_minute', settings.dailyReminderTime.minute);
      await prefs.setBool('weekly_report_enabled', settings.weeklyReportEnabled);
      await prefs.setBool('emotion_analysis_enabled', settings.emotionAnalysisEnabled);
      await prefs.setBool('achievement_notifications_enabled', settings.achievementNotificationsEnabled);
      await prefs.setStringList('quiet_hours', settings.quietHours);
      await prefs.setBool('do_not_disturb_enabled', settings.doNotDisturbEnabled);
      
      print('✅ 알림 설정 저장 성공');
      return true;
    } catch (e) {
      print('❌ 알림 설정 저장 실패: $e');
      return false;
    }
  }

  /// 데이터 설정 가져오기
  Future<DataSettings> getDataSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return DataSettings(
        autoBackupEnabled: prefs.getBool('auto_backup_enabled') ?? true,
        backupFrequency: prefs.getInt('backup_frequency') ?? 7,
        cloudSyncEnabled: prefs.getBool('cloud_sync_enabled') ?? true,
        dataRetentionPeriod: prefs.getInt('data_retention_period') ?? 12,
        analyticsEnabled: prefs.getBool('analytics_enabled') ?? true,
        crashReportingEnabled: prefs.getBool('crash_reporting_enabled') ?? true,
        performanceMonitoringEnabled: prefs.getBool('performance_monitoring_enabled') ?? true,
        maxCacheSize: prefs.getInt('max_cache_size') ?? 100,
        autoCleanupEnabled: prefs.getBool('auto_cleanup_enabled') ?? true,
      );
    } catch (e) {
      print('❌ 데이터 설정 가져오기 실패: $e');
      return DataSettings.defaultSettings();
    }
  }

  /// 데이터 설정 저장
  Future<bool> saveDataSettings(DataSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('auto_backup_enabled', settings.autoBackupEnabled);
      await prefs.setInt('backup_frequency', settings.backupFrequency);
      await prefs.setBool('cloud_sync_enabled', settings.cloudSyncEnabled);
      await prefs.setInt('data_retention_period', settings.dataRetentionPeriod);
      await prefs.setBool('analytics_enabled', settings.analyticsEnabled);
      await prefs.setBool('crash_reporting_enabled', settings.crashReportingEnabled);
      await prefs.setBool('performance_monitoring_enabled', settings.performanceMonitoringEnabled);
      await prefs.setInt('max_cache_size', settings.maxCacheSize);
      await prefs.setBool('auto_cleanup_enabled', settings.autoCleanupEnabled);
      
      print('✅ 데이터 설정 저장 성공');
      return true;
    } catch (e) {
      print('❌ 데이터 설정 저장 실패: $e');
      return false;
    }
  }

  /// 보안 설정 가져오기
  Future<SecuritySettings> getSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return SecuritySettings(
        biometricAuthEnabled: prefs.getBool('biometric_auth_enabled') ?? false,
        appLockEnabled: prefs.getBool('app_lock_enabled') ?? false,
        appLockTimeout: prefs.getInt('app_lock_timeout') ?? 5,
        pinCodeEnabled: prefs.getBool('pin_code_enabled') ?? false,
        pinCode: prefs.getString('pin_code'),
        patternLockEnabled: prefs.getBool('pattern_lock_enabled') ?? false,
        patternLock: prefs.getString('pattern_lock'),
        sensitiveDataEncryption: prefs.getBool('sensitive_data_encryption') ?? true,
        autoLogoutEnabled: prefs.getBool('auto_logout_enabled') ?? false,
        autoLogoutTimeout: prefs.getInt('auto_logout_timeout') ?? 30,
      );
    } catch (e) {
      print('❌ 보안 설정 가져오기 실패: $e');
      return SecuritySettings.defaultSettings();
    }
  }

  /// 보안 설정 저장
  Future<bool> saveSecuritySettings(SecuritySettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('biometric_auth_enabled', settings.biometricAuthEnabled);
      await prefs.setBool('app_lock_enabled', settings.appLockEnabled);
      await prefs.setInt('app_lock_timeout', settings.appLockTimeout);
      await prefs.setBool('pin_code_enabled', settings.pinCodeEnabled);
      if (settings.pinCode != null) {
        await prefs.setString('pin_code', settings.pinCode!);
      }
      await prefs.setBool('pattern_lock_enabled', settings.patternLockEnabled);
      if (settings.patternLock != null) {
        await prefs.setString('pattern_lock', settings.patternLock!);
      }
      await prefs.setBool('sensitive_data_encryption', settings.sensitiveDataEncryption);
      await prefs.setBool('auto_logout_enabled', settings.autoLogoutEnabled);
      await prefs.setInt('auto_logout_timeout', settings.autoLogoutTimeout);
      
      print('✅ 보안 설정 저장 성공');
      return true;
    } catch (e) {
      print('❌ 보안 설정 저장 실패: $e');
      return false;
    }
  }

  /// 접근성 설정 가져오기
  Future<AccessibilitySettings> getAccessibilitySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return AccessibilitySettings(
        screenReaderEnabled: prefs.getBool('screen_reader_enabled') ?? false,
        textScaleFactor: prefs.getDouble('text_scale_factor') ?? 1.0,
        highContrastEnabled: prefs.getBool('high_contrast_enabled') ?? false,
        reduceMotionEnabled: prefs.getBool('reduce_motion_enabled') ?? false,
        boldTextEnabled: prefs.getBool('bold_text_enabled') ?? false,
        largeTextEnabled: prefs.getBool('large_text_enabled') ?? false,
        colorBlindSupportEnabled: prefs.getBool('color_blind_support_enabled') ?? false,
        colorBlindType: prefs.getString('color_blind_type'),
        keyboardNavigationEnabled: prefs.getBool('keyboard_navigation_enabled') ?? false,
        soundEffectsEnabled: prefs.getBool('sound_effects_enabled') ?? true,
      );
    } catch (e) {
      print('❌ 접근성 설정 가져오기 실패: $e');
      return AccessibilitySettings.defaultSettings();
    }
  }

  /// 접근성 설정 저장
  Future<bool> saveAccessibilitySettings(AccessibilitySettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('screen_reader_enabled', settings.screenReaderEnabled);
      await prefs.setDouble('text_scale_factor', settings.textScaleFactor);
      await prefs.setBool('high_contrast_enabled', settings.highContrastEnabled);
      await prefs.setBool('reduce_motion_enabled', settings.reduceMotionEnabled);
      await prefs.setBool('bold_text_enabled', settings.boldTextEnabled);
      await prefs.setBool('large_text_enabled', settings.largeTextEnabled);
      await prefs.setBool('color_blind_support_enabled', settings.colorBlindSupportEnabled);
      if (settings.colorBlindType != null) {
        await prefs.setString('color_blind_type', settings.colorBlindType!);
      }
      await prefs.setBool('keyboard_navigation_enabled', settings.keyboardNavigationEnabled);
      await prefs.setBool('sound_effects_enabled', settings.soundEffectsEnabled);
      
      print('✅ 접근성 설정 저장 성공');
      return true;
    } catch (e) {
      print('❌ 접근성 설정 저장 실패: $e');
      return false;
    }
  }

  /// 특정 설정 값 가져오기
  Future<T?> getSettingValue<T>(String key, T defaultValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (T == bool) {
        return prefs.getBool(key) as T? ?? defaultValue;
      } else if (T == int) {
        return prefs.getInt(key) as T? ?? defaultValue;
      } else if (T == double) {
        return prefs.getDouble(key) as T? ?? defaultValue;
      } else if (T == String) {
        return prefs.getString(key) as T? ?? defaultValue;
      } else if (T == List<String>) {
        return prefs.getStringList(key) as T? ?? defaultValue;
      }
      
      return defaultValue;
    } catch (e) {
      print('❌ 설정 값 가져오기 실패: $e');
      return defaultValue;
    }
  }

  /// 특정 설정 값 저장
  Future<bool> setSettingValue<T>(String key, T value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else {
        print('❌ 지원하지 않는 설정 타입: ${value.runtimeType}');
        return false;
      }
      
      return true;
    } catch (e) {
      print('❌ 설정 값 저장 실패: $e');
      return false;
    }
  }

  /// 모든 설정 초기화
  Future<bool> resetAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      print('✅ 모든 설정 초기화 성공');
      return true;
    } catch (e) {
      print('❌ 설정 초기화 실패: $e');
      return false;
    }
  }

  /// 설정 백업
  Future<Map<String, dynamic>?> backupSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final backup = <String, dynamic>{};
      
      for (final key in keys) {
        final value = prefs.get(key);
        if (value != null) {
          backup[key] = value;
        }
      }
      
      print('✅ 설정 백업 성공');
      return backup;
    } catch (e) {
      print('❌ 설정 백업 실패: $e');
      return null;
    }
  }

  /// 설정 복원
  Future<bool> restoreSettings(Map<String, dynamic> backup) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (final entry in backup.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
        }
      }
      
      print('✅ 설정 복원 성공');
      return true;
    } catch (e) {
      print('❌ 설정 복원 실패: $e');
      return false;
    }
  }
}
