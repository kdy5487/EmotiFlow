import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';

/// 설정 페이지의 ViewModel
/// UI 로직과 비즈니스 로직을 분리하여 관리
class SettingsViewModel extends ChangeNotifier {
  final WidgetRef ref;
  
  SettingsViewModel(this.ref);

  // 상태 변수들
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// 현재 앱 설정
  AppSettings get currentSettings => ref.read(settingsProvider).settings;
  
  /// 테마 설정
  ThemeSettings get themeSettings => currentSettings.themeSettings;
  
  /// 알림 설정
  NotificationSettings get notificationSettings => currentSettings.notificationSettings;
  
  /// 데이터 설정
  DataSettings get dataSettings => currentSettings.dataSettings;
  
  /// 보안 설정
  SecuritySettings get securitySettings => currentSettings.securitySettings;
  
  /// 접근성 설정
  AccessibilitySettings get accessibilitySettings => currentSettings.accessibilitySettings;

  // Setters
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  /// 설정 새로고침
  Future<void> refreshSettings() async {
    try {
      isLoading = true;
      error = null;
      
      await ref.read(settingsProvider.notifier).refreshSettings();
    } catch (e) {
      error = '설정을 불러올 수 없습니다: $e';
    } finally {
      isLoading = false;
    }
  }

  /// 테마 모드 변경
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      final updatedThemeSettings = themeSettings.copyWith(themeMode: themeMode);
      await ref.read(settingsProvider.notifier).updateThemeSettings(updatedThemeSettings);
    } catch (e) {
      error = '테마 모드를 변경할 수 없습니다: $e';
    }
  }

  /// 기본 색상 변경
  Future<void> updatePrimaryColor(Color color) async {
    try {
      final updatedThemeSettings = themeSettings.copyWith(primaryColor: color);
      await ref.read(settingsProvider.notifier).updateThemeSettings(updatedThemeSettings);
    } catch (e) {
      error = '기본 색상을 변경할 수 없습니다: $e';
    }
  }

  /// 보조 색상 변경
  Future<void> updateAccentColor(Color color) async {
    try {
      final updatedThemeSettings = themeSettings.copyWith(accentColor: color);
      await ref.read(settingsProvider.notifier).updateThemeSettings(updatedThemeSettings);
    } catch (e) {
      error = '보조 색상을 변경할 수 없습니다: $e';
    }
  }

  /// 동적 색상 사용 여부 변경
  Future<void> toggleDynamicColors(bool useDynamicColors) async {
    try {
      final updatedThemeSettings = themeSettings.copyWith(useDynamicColors: useDynamicColors);
      await ref.read(settingsProvider.notifier).updateThemeSettings(updatedThemeSettings);
    } catch (e) {
      error = '동적 색상 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 테두리 반경 변경
  Future<void> updateBorderRadius(double borderRadius) async {
    try {
      final updatedThemeSettings = themeSettings.copyWith(borderRadius: borderRadius);
      await ref.read(settingsProvider.notifier).updateThemeSettings(updatedThemeSettings);
    } catch (e) {
      error = '테두리 반경을 변경할 수 없습니다: $e';
    }
  }

  /// Material 3 사용 여부 변경
  Future<void> toggleMaterial3(bool useMaterial3) async {
    try {
      final updatedThemeSettings = themeSettings.copyWith(useMaterial3: useMaterial3);
      await ref.read(settingsProvider.notifier).updateThemeSettings(updatedThemeSettings);
    } catch (e) {
      error = 'Material 3 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 푸시 알림 사용 여부 변경
  Future<void> togglePushNotifications(bool enabled) async {
    try {
      final updatedNotificationSettings = notificationSettings.copyWith(
        pushNotificationsEnabled: enabled,
      );
      await ref.read(settingsProvider.notifier).updateNotificationSettings(updatedNotificationSettings);
    } catch (e) {
      error = '푸시 알림 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 이메일 알림 사용 여부 변경
  Future<void> toggleEmailNotifications(bool enabled) async {
    try {
      final updatedNotificationSettings = notificationSettings.copyWith(
        emailNotificationsEnabled: enabled,
      );
      await ref.read(settingsProvider.notifier).updateNotificationSettings(updatedNotificationSettings);
    } catch (e) {
      error = '이메일 알림 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 알림 시간 변경
  Future<void> updateNotificationTime(TimeOfDay time) async {
    try {
      final updatedNotificationSettings = notificationSettings.copyWith(
        dailyReminderTime: time,
      );
      await ref.read(settingsProvider.notifier).updateNotificationSettings(updatedNotificationSettings);
    } catch (e) {
      error = '알림 시간을 변경할 수 없습니다: $e';
    }
  }

  /// 자동 백업 사용 여부 변경
  Future<void> toggleAutoBackup(bool enabled) async {
    try {
      final updatedDataSettings = dataSettings.copyWith(autoBackupEnabled: enabled);
      await ref.read(settingsProvider.notifier).updateDataSettings(updatedDataSettings);
    } catch (e) {
      error = '자동 백업 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 동기화 사용 여부 변경
  Future<void> toggleSync(bool enabled) async {
    try {
      final updatedDataSettings = dataSettings.copyWith(cloudSyncEnabled: enabled);
      await ref.read(settingsProvider.notifier).updateDataSettings(updatedDataSettings);
    } catch (e) {
      error = '동기화 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 생체 인증 사용 여부 변경
  Future<void> toggleBiometricAuth(bool enabled) async {
    try {
      final updatedSecuritySettings = securitySettings.copyWith(biometricAuthEnabled: enabled);
      await ref.read(settingsProvider.notifier).updateSecuritySettings(updatedSecuritySettings);
    } catch (e) {
      error = '생체 인증 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 앱 잠금 사용 여부 변경
  Future<void> toggleAppLock(bool enabled) async {
    try {
      final updatedSecuritySettings = securitySettings.copyWith(appLockEnabled: enabled);
      await ref.read(settingsProvider.notifier).updateSecuritySettings(updatedSecuritySettings);
    } catch (e) {
      error = '앱 잠금 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 스크린 리더 사용 여부 변경
  Future<void> toggleScreenReader(bool enabled) async {
    try {
      final updatedAccessibilitySettings = accessibilitySettings.copyWith(
        screenReaderEnabled: enabled,
      );
      await ref.read(settingsProvider.notifier).updateAccessibilitySettings(updatedAccessibilitySettings);
    } catch (e) {
      error = '스크린 리더 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 고대비 모드 사용 여부 변경
  Future<void> toggleHighContrast(bool enabled) async {
    try {
      final updatedAccessibilitySettings = accessibilitySettings.copyWith(
        highContrastEnabled: enabled,
      );
      await ref.read(settingsProvider.notifier).updateAccessibilitySettings(updatedAccessibilitySettings);
    } catch (e) {
      error = '고대비 모드 설정을 변경할 수 없습니다: $e';
    }
  }

  /// 폰트 크기 변경
  Future<void> updateFontSize(double fontSize) async {
    try {
      final updatedAccessibilitySettings = accessibilitySettings.copyWith(textScaleFactor: fontSize);
      await ref.read(settingsProvider.notifier).updateAccessibilitySettings(updatedAccessibilitySettings);
    } catch (e) {
      error = '폰트 크기를 변경할 수 없습니다: $e';
    }
  }

  /// 설정 백업
  Future<void> backupSettings() async {
    try {
      isLoading = true;
      error = null;
      
      await ref.read(settingsProvider.notifier).backupSettings();
    } catch (e) {
      error = '설정을 백업할 수 없습니다: $e';
    } finally {
      isLoading = false;
    }
  }

  /// 설정 복원 (백업 데이터로부터)
  Future<void> restoreSettingsFromBackup(Map<String, dynamic> backup) async {
    try {
      isLoading = true;
      error = null;
      
      await ref.read(settingsProvider.notifier).restoreSettings(backup);
    } catch (e) {
      error = '설정을 복원할 수 없습니다: $e';
    } finally {
      isLoading = false;
    }
  }

  /// 설정 초기화
  Future<void> resetAllSettings() async {
    try {
      isLoading = true;
      error = null;
      
      await ref.read(settingsProvider.notifier).resetAllSettings();
    } catch (e) {
      error = '설정을 초기화할 수 없습니다: $e';
    } finally {
      isLoading = false;
    }
  }

  /// 테마 모드 텍스트 변환
  String getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return '시스템';
      case ThemeMode.light:
        return '라이트';
      case ThemeMode.dark:
        return '다크';
    }
  }

  /// 시간 형식 변환
  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 설정 변경사항이 있는지 확인
  bool get hasChanges {
    // 현재 설정과 저장된 설정을 비교하여 변경사항 확인
    // 실제 구현에서는 더 정교한 비교 로직이 필요할 수 있음
    return false;
  }
}
