import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

/// 설정 상태 클래스
class SettingsState {
  final AppSettings settings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 설정 관리 클래스
class SettingsProvider extends StateNotifier<SettingsState> {
  final SettingsService _settingsService = SettingsService();
  
  SettingsProvider() : super(SettingsState(settings: AppSettings.defaultSettings())) {
    _init();
  }

  /// 초기화
  void _init() {
    _loadSettings();
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final settings = await _settingsService.getAppSettings();
      state = state.copyWith(settings: settings);
    } catch (e) {
      state = state.copyWith(error: '설정 로드 실패: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 설정 새로고침
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  /// 전체 설정 업데이트
  Future<bool> updateSettings(AppSettings newSettings) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _settingsService.saveAppSettings(newSettings);
      
      if (success) {
        state = state.copyWith(settings: newSettings);
        return true;
      } else {
        state = state.copyWith(error: '설정 저장 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '설정 저장 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 테마 설정 업데이트
  Future<bool> updateThemeSettings(ThemeSettings themeSettings) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _settingsService.saveThemeSettings(themeSettings);
      
      if (success) {
        final newSettings = state.settings.copyWith(themeSettings: themeSettings);
        state = state.copyWith(settings: newSettings);
        return true;
      } else {
        state = state.copyWith(error: '테마 설정 저장 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '테마 설정 저장 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 알림 설정 업데이트
  Future<bool> updateNotificationSettings(NotificationSettings notificationSettings) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _settingsService.saveNotificationSettings(notificationSettings);
      
      if (success) {
        final newSettings = state.settings.copyWith(notificationSettings: notificationSettings);
        state = state.copyWith(settings: newSettings);
        return true;
      } else {
        state = state.copyWith(error: '알림 설정 저장 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '알림 설정 저장 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 데이터 설정 업데이트
  Future<bool> updateDataSettings(DataSettings dataSettings) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _settingsService.saveDataSettings(dataSettings);
      
      if (success) {
        final newSettings = state.settings.copyWith(dataSettings: dataSettings);
        state = state.copyWith(settings: newSettings);
        return true;
      } else {
        state = state.copyWith(error: '데이터 설정 저장 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '데이터 설정 저장 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 보안 설정 업데이트
  Future<bool> updateSecuritySettings(SecuritySettings securitySettings) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _settingsService.saveSecuritySettings(securitySettings);
      
      if (success) {
        final newSettings = state.settings.copyWith(securitySettings: securitySettings);
        state = state.copyWith(settings: newSettings);
        return true;
      } else {
        state = state.copyWith(error: '보안 설정 저장 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '보안 설정 저장 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 접근성 설정 업데이트
  Future<bool> updateAccessibilitySettings(AccessibilitySettings accessibilitySettings) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _settingsService.saveAccessibilitySettings(accessibilitySettings);
      
      if (success) {
        final newSettings = state.settings.copyWith(accessibilitySettings: accessibilitySettings);
        state = state.copyWith(settings: newSettings);
        return true;
      } else {
        state = state.copyWith(error: '접근성 설정 저장 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '접근성 설정 저장 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 특정 설정 값 업데이트
  Future<bool> updateSettingValue<T>(String key, T value) async {
    try {
      final success = await _settingsService.setSettingValue(key, value);
      if (success) {
        // 설정이 변경되었으므로 새로고침
        await _loadSettings();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: '설정 값 업데이트 실패: $e');
      return false;
    }
  }

  /// 테마 모드 변경
  Future<bool> changeThemeMode(ThemeMode themeMode) async {
    final currentThemeSettings = state.settings.themeSettings;
    final newThemeSettings = currentThemeSettings.copyWith(themeMode: themeMode);
    
    return await updateThemeSettings(newThemeSettings);
  }

  /// 기본 색상 변경
  Future<bool> changePrimaryColor(Color primaryColor) async {
    final currentThemeSettings = state.settings.themeSettings;
    final newThemeSettings = currentThemeSettings.copyWith(primaryColor: primaryColor);
    
    return await updateThemeSettings(newThemeSettings);
  }

  /// 보조 색상 변경
  Future<bool> changeAccentColor(Color accentColor) async {
    final currentThemeSettings = state.settings.themeSettings;
    final newThemeSettings = currentThemeSettings.copyWith(accentColor: accentColor);
    
    return await updateThemeSettings(newThemeSettings);
  }

  /// 동적 색상 사용 여부 변경
  Future<bool> toggleDynamicColors(bool useDynamicColors) async {
    final currentThemeSettings = state.settings.themeSettings;
    final newThemeSettings = currentThemeSettings.copyWith(useDynamicColors: useDynamicColors);
    
    return await updateThemeSettings(newThemeSettings);
  }

  /// 테두리 반경 변경
  Future<bool> changeBorderRadius(double borderRadius) async {
    final currentThemeSettings = state.settings.themeSettings;
    final newThemeSettings = currentThemeSettings.copyWith(borderRadius: borderRadius);
    
    return await updateThemeSettings(newThemeSettings);
  }

  /// Material 3 사용 여부 변경
  Future<bool> toggleMaterial3(bool useMaterial3) async {
    final currentThemeSettings = state.settings.themeSettings;
    final newThemeSettings = currentThemeSettings.copyWith(useMaterial3: useMaterial3);
    
    return await updateThemeSettings(newThemeSettings);
  }

  /// 푸시 알림 토글
  Future<bool> togglePushNotifications(bool enabled) async {
    final currentNotificationSettings = state.settings.notificationSettings;
    final newNotificationSettings = currentNotificationSettings.copyWith(
      pushNotificationsEnabled: enabled,
    );
    
    return await updateNotificationSettings(newNotificationSettings);
  }

  /// 이메일 알림 토글
  Future<bool> toggleEmailNotifications(bool enabled) async {
    final currentNotificationSettings = state.settings.notificationSettings;
    final newNotificationSettings = currentNotificationSettings.copyWith(
      emailNotificationsEnabled: enabled,
    );
    
    return await updateNotificationSettings(newNotificationSettings);
  }

  /// 일일 리마인더 토글
  Future<bool> toggleDailyReminder(bool enabled) async {
    final currentNotificationSettings = state.settings.notificationSettings;
    final newNotificationSettings = currentNotificationSettings.copyWith(
      dailyReminderEnabled: enabled,
    );
    
    return await updateNotificationSettings(newNotificationSettings);
  }

  /// 일일 리마인더 시간 변경
  Future<bool> changeDailyReminderTime(TimeOfDay time) async {
    final currentNotificationSettings = state.settings.notificationSettings;
    final newNotificationSettings = currentNotificationSettings.copyWith(
      dailyReminderTime: time,
    );
    
    return await updateNotificationSettings(newNotificationSettings);
  }

  /// 자동 백업 토글
  Future<bool> toggleAutoBackup(bool enabled) async {
    final currentDataSettings = state.settings.dataSettings;
    final newDataSettings = currentDataSettings.copyWith(
      autoBackupEnabled: enabled,
    );
    
    return await updateDataSettings(newDataSettings);
  }

  /// 클라우드 동기화 토글
  Future<bool> toggleCloudSync(bool enabled) async {
    final currentDataSettings = state.settings.dataSettings;
    final newDataSettings = currentDataSettings.copyWith(
      cloudSyncEnabled: enabled,
    );
    
    return await updateDataSettings(newDataSettings);
  }

  /// 생체 인증 토글
  Future<bool> toggleBiometricAuth(bool enabled) async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      biometricAuthEnabled: enabled,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// 앱 잠금 토글
  Future<bool> toggleAppLock(bool enabled) async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      appLockEnabled: enabled,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// 앱 잠금 타임아웃 변경
  Future<bool> changeAppLockTimeout(int timeout) async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      appLockTimeout: timeout,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// PIN 코드 설정
  Future<bool> setPinCode(String pinCode) async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      pinCodeEnabled: true,
      pinCode: pinCode,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// PIN 코드 제거
  Future<bool> removePinCode() async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      pinCodeEnabled: false,
      pinCode: null,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// 패턴 잠금 설정
  Future<bool> setPatternLock(String pattern) async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      patternLockEnabled: true,
      patternLock: pattern,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// 패턴 잠금 제거
  Future<bool> removePatternLock() async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      patternLockEnabled: false,
      patternLock: null,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// 자동 로그아웃 토글
  Future<bool> toggleAutoLogout(bool enabled) async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      autoLogoutEnabled: enabled,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// 자동 로그아웃 타임아웃 변경
  Future<bool> changeAutoLogoutTimeout(int timeout) async {
    final currentSecuritySettings = state.settings.securitySettings;
    final newSecuritySettings = currentSecuritySettings.copyWith(
      autoLogoutTimeout: timeout,
    );
    
    return await updateSecuritySettings(newSecuritySettings);
  }

  /// 스크린 리더 토글
  Future<bool> toggleScreenReader(bool enabled) async {
    final currentAccessibilitySettings = state.settings.accessibilitySettings;
    final newAccessibilitySettings = currentAccessibilitySettings.copyWith(
      screenReaderEnabled: enabled,
    );
    
    return await updateAccessibilitySettings(newAccessibilitySettings);
  }

  /// 텍스트 크기 변경
  Future<bool> changeTextScaleFactor(double scaleFactor) async {
    final currentAccessibilitySettings = state.settings.accessibilitySettings;
    final newAccessibilitySettings = currentAccessibilitySettings.copyWith(
      textScaleFactor: scaleFactor,
    );
    
    return await updateAccessibilitySettings(newAccessibilitySettings);
  }

  /// 고대비 모드 토글
  Future<bool> toggleHighContrast(bool enabled) async {
    final currentAccessibilitySettings = state.settings.accessibilitySettings;
    final newAccessibilitySettings = currentAccessibilitySettings.copyWith(
      highContrastEnabled: enabled,
    );
    
    return await updateAccessibilitySettings(newAccessibilitySettings);
  }

  /// 모션 감소 토글
  Future<bool> toggleReduceMotion(bool enabled) async {
    final currentAccessibilitySettings = state.settings.accessibilitySettings;
    final newAccessibilitySettings = currentAccessibilitySettings.copyWith(
      reduceMotionEnabled: enabled,
    );
    
    return await updateAccessibilitySettings(newAccessibilitySettings);
  }

  /// 모든 설정 초기화
  Future<bool> resetAllSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _settingsService.resetAllSettings();
      
      if (success) {
        final defaultSettings = AppSettings.defaultSettings();
        state = state.copyWith(settings: defaultSettings);
        return true;
      } else {
        state = state.copyWith(error: '설정 초기화 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '설정 초기화 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 설정 백업
  Future<Map<String, dynamic>?> backupSettings() async {
    try {
      return await _settingsService.backupSettings();
    } catch (e) {
      state = state.copyWith(error: '설정 백업 실패: $e');
      return null;
    }
  }

  /// 설정 복원
  Future<bool> restoreSettings(Map<String, dynamic> backup) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _settingsService.restoreSettings(backup);
      
      if (success) {
        await _loadSettings(); // 복원된 설정 로드
        return true;
      } else {
        state = state.copyWith(error: '설정 복원 실패');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: '설정 복원 실패: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

/// SettingsProvider를 위한 Riverpod provider
final settingsProvider = StateNotifierProvider<SettingsProvider, SettingsState>((ref) {
  return SettingsProvider();
});

/// 테마 설정만 가져오는 provider
final themeSettingsProvider = Provider<ThemeSettings>((ref) {
  return ref.watch(settingsProvider).settings.themeSettings;
});

/// 알림 설정만 가져오는 provider
final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  return ref.watch(settingsProvider).settings.notificationSettings;
});

/// 데이터 설정만 가져오는 provider
final dataSettingsProvider = Provider<DataSettings>((ref) {
  return ref.watch(settingsProvider).settings.dataSettings;
});

/// 보안 설정만 가져오는 provider
final securitySettingsProvider = Provider<SecuritySettings>((ref) {
  return ref.watch(settingsProvider).settings.securitySettings;
});

/// 접근성 설정만 가져오는 provider
final accessibilitySettingsProvider = Provider<AccessibilitySettings>((ref) {
  return ref.watch(settingsProvider).settings.accessibilitySettings;
});

/// 설정 로딩 상태 provider
final settingsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).isLoading;
});

/// 설정 에러 provider
final settingsErrorProvider = Provider<String?>((ref) {
  return ref.watch(settingsProvider).error;
});
