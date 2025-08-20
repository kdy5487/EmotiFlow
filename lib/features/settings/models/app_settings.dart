import 'package:flutter/material.dart';

/// 앱 설정 모델
class AppSettings {
  final ThemeSettings themeSettings;
  final NotificationSettings notificationSettings;
  final DataSettings dataSettings;
  final SecuritySettings securitySettings;
  final AccessibilitySettings accessibilitySettings;
  final DateTime lastUpdated;

  const AppSettings({
    required this.themeSettings,
    required this.notificationSettings,
    required this.dataSettings,
    required this.securitySettings,
    required this.accessibilitySettings,
    required this.lastUpdated,
  });

  /// 기본 설정으로 AppSettings 생성
  factory AppSettings.defaultSettings() {
    return AppSettings(
      themeSettings: ThemeSettings.defaultSettings(),
      notificationSettings: NotificationSettings.defaultSettings(),
      dataSettings: DataSettings.defaultSettings(),
      securitySettings: SecuritySettings.defaultSettings(),
      accessibilitySettings: AccessibilitySettings.defaultSettings(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Map에서 AppSettings 생성
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeSettings: ThemeSettings.fromMap(map['themeSettings'] ?? {}),
      notificationSettings: NotificationSettings.fromMap(map['notificationSettings'] ?? {}),
      dataSettings: DataSettings.fromMap(map['dataSettings'] ?? {}),
      securitySettings: SecuritySettings.fromMap(map['securitySettings'] ?? {}),
      accessibilitySettings: AccessibilitySettings.fromMap(map['accessibilitySettings'] ?? {}),
      lastUpdated: map['lastUpdated'] != null 
          ? DateTime.parse(map['lastUpdated']) 
          : DateTime.now(),
    );
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'themeSettings': themeSettings.toMap(),
      'notificationSettings': notificationSettings.toMap(),
      'dataSettings': dataSettings.toMap(),
      'securitySettings': securitySettings.toMap(),
      'accessibilitySettings': accessibilitySettings.toMap(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// 설정 복사본 생성
  AppSettings copyWith({
    ThemeSettings? themeSettings,
    NotificationSettings? notificationSettings,
    DataSettings? dataSettings,
    SecuritySettings? securitySettings,
    AccessibilitySettings? accessibilitySettings,
    DateTime? lastUpdated,
  }) {
    return AppSettings(
      themeSettings: themeSettings ?? this.themeSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      dataSettings: dataSettings ?? this.dataSettings,
      securitySettings: securitySettings ?? this.securitySettings,
      accessibilitySettings: accessibilitySettings ?? this.accessibilitySettings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 테마 설정
class ThemeSettings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final Color accentColor;
  final bool useDynamicColors;
  final double borderRadius;
  final bool useMaterial3;

  const ThemeSettings({
    required this.themeMode,
    required this.primaryColor,
    required this.accentColor,
    required this.useDynamicColors,
    required this.borderRadius,
    required this.useMaterial3,
  });

  factory ThemeSettings.defaultSettings() {
    return const ThemeSettings(
      themeMode: ThemeMode.system,
      primaryColor: Color(0xFF8B7FF6),
      accentColor: Color(0xFFDA77F2),
      useDynamicColors: true,
      borderRadius: 12.0,
      useMaterial3: true,
    );
  }

  factory ThemeSettings.fromMap(Map<String, dynamic> map) {
    return ThemeSettings(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      primaryColor: Color(map['primaryColor'] ?? 0xFF8B7FF6),
      accentColor: Color(map['accentColor'] ?? 0xFFDA77F2),
      useDynamicColors: map['useDynamicColors'] ?? true,
      borderRadius: (map['borderRadius'] ?? 12.0).toDouble(),
      useMaterial3: map['useMaterial3'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'primaryColor': primaryColor.value,
      'accentColor': accentColor.value,
      'useDynamicColors': useDynamicColors,
      'borderRadius': borderRadius,
      'useMaterial3': useMaterial3,
    };
  }

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Color? accentColor,
    bool? useDynamicColors,
    double? borderRadius,
    bool? useMaterial3,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      borderRadius: borderRadius ?? this.borderRadius,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
    );
  }
}

/// 알림 설정
class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool dailyReminderEnabled;
  final TimeOfDay dailyReminderTime;
  final bool weeklyReportEnabled;
  final bool emotionAnalysisEnabled;
  final bool achievementNotificationsEnabled;
  final List<String> quietHours;
  final bool doNotDisturbEnabled;

  const NotificationSettings({
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.dailyReminderEnabled,
    required this.dailyReminderTime,
    required this.weeklyReportEnabled,
    required this.emotionAnalysisEnabled,
    required this.achievementNotificationsEnabled,
    required this.quietHours,
    required this.doNotDisturbEnabled,
  });

  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings(
      pushNotificationsEnabled: true,
      emailNotificationsEnabled: false,
      dailyReminderEnabled: true,
      dailyReminderTime: TimeOfDay(hour: 20, minute: 0),
      weeklyReportEnabled: true,
      emotionAnalysisEnabled: true,
      achievementNotificationsEnabled: true,
      quietHours: ['22:00', '08:00'],
      doNotDisturbEnabled: false,
    );
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushNotificationsEnabled: map['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: map['emailNotificationsEnabled'] ?? false,
      dailyReminderEnabled: map['dailyReminderEnabled'] ?? true,
      dailyReminderTime: TimeOfDay(
        hour: map['dailyReminderHour'] ?? 20,
        minute: map['dailyReminderMinute'] ?? 0,
      ),
      weeklyReportEnabled: map['weeklyReportEnabled'] ?? true,
      emotionAnalysisEnabled: map['emotionAnalysisEnabled'] ?? true,
      achievementNotificationsEnabled: map['achievementNotificationsEnabled'] ?? true,
      quietHours: List<String>.from(map['quietHours'] ?? ['22:00', '08:00']),
      doNotDisturbEnabled: map['doNotDisturbEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyReminderHour': dailyReminderTime.hour,
      'dailyReminderMinute': dailyReminderTime.minute,
      'weeklyReportEnabled': weeklyReportEnabled,
      'emotionAnalysisEnabled': emotionAnalysisEnabled,
      'achievementNotificationsEnabled': achievementNotificationsEnabled,
      'quietHours': quietHours,
      'doNotDisturbEnabled': doNotDisturbEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? dailyReminderEnabled,
    TimeOfDay? dailyReminderTime,
    bool? weeklyReportEnabled,
    bool? emotionAnalysisEnabled,
    bool? achievementNotificationsEnabled,
    List<String>? quietHours,
    bool? doNotDisturbEnabled,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
      emotionAnalysisEnabled: emotionAnalysisEnabled ?? this.emotionAnalysisEnabled,
      achievementNotificationsEnabled: achievementNotificationsEnabled ?? this.achievementNotificationsEnabled,
      quietHours: quietHours ?? this.quietHours,
      doNotDisturbEnabled: doNotDisturbEnabled ?? this.doNotDisturbEnabled,
    );
  }
}

/// 데이터 설정
class DataSettings {
  final bool autoBackupEnabled;
  final int backupFrequency; // 일 단위
  final bool cloudSyncEnabled;
  final int dataRetentionPeriod; // 개월 단위
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool performanceMonitoringEnabled;
  final int maxCacheSize; // MB 단위
  final bool autoCleanupEnabled;

  const DataSettings({
    required this.autoBackupEnabled,
    required this.backupFrequency,
    required this.cloudSyncEnabled,
    required this.dataRetentionPeriod,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.performanceMonitoringEnabled,
    required this.maxCacheSize,
    required this.autoCleanupEnabled,
  });

  factory DataSettings.defaultSettings() {
    return const DataSettings(
      autoBackupEnabled: true,
      backupFrequency: 7, // 7일마다
      cloudSyncEnabled: true,
      dataRetentionPeriod: 12, // 12개월
      analyticsEnabled: true,
      crashReportingEnabled: true,
      performanceMonitoringEnabled: true,
      maxCacheSize: 100, // 100MB
      autoCleanupEnabled: true,
    );
  }

  factory DataSettings.fromMap(Map<String, dynamic> map) {
    return DataSettings(
      autoBackupEnabled: map['autoBackupEnabled'] ?? true,
      backupFrequency: map['backupFrequency'] ?? 7,
      cloudSyncEnabled: map['cloudSyncEnabled'] ?? true,
      dataRetentionPeriod: map['dataRetentionPeriod'] ?? 12,
      analyticsEnabled: map['analyticsEnabled'] ?? true,
      crashReportingEnabled: map['crashReportingEnabled'] ?? true,
      performanceMonitoringEnabled: map['performanceMonitoringEnabled'] ?? true,
      maxCacheSize: map['maxCacheSize'] ?? 100,
      autoCleanupEnabled: map['autoCleanupEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoBackupEnabled': autoBackupEnabled,
      'backupFrequency': backupFrequency,
      'cloudSyncEnabled': cloudSyncEnabled,
      'dataRetentionPeriod': dataRetentionPeriod,
      'analyticsEnabled': analyticsEnabled,
      'crashReportingEnabled': crashReportingEnabled,
      'performanceMonitoringEnabled': performanceMonitoringEnabled,
      'maxCacheSize': maxCacheSize,
      'autoCleanupEnabled': autoCleanupEnabled,
    };
  }

  DataSettings copyWith({
    bool? autoBackupEnabled,
    int? backupFrequency,
    bool? cloudSyncEnabled,
    int? dataRetentionPeriod,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? performanceMonitoringEnabled,
    int? maxCacheSize,
    bool? autoCleanupEnabled,
  }) {
    return DataSettings(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      dataRetentionPeriod: dataRetentionPeriod ?? this.dataRetentionPeriod,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      performanceMonitoringEnabled: performanceMonitoringEnabled ?? this.performanceMonitoringEnabled,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      autoCleanupEnabled: autoCleanupEnabled ?? this.autoCleanupEnabled,
    );
  }
}

/// 보안 설정
class SecuritySettings {
  final bool biometricAuthEnabled;
  final bool appLockEnabled;
  final int appLockTimeout; // 분 단위
  final bool pinCodeEnabled;
  final String? pinCode;
  final bool patternLockEnabled;
  final String? patternLock;
  final bool sensitiveDataEncryption;
  final bool autoLogoutEnabled;
  final int autoLogoutTimeout; // 분 단위

  const SecuritySettings({
    required this.biometricAuthEnabled,
    required this.appLockEnabled,
    required this.appLockTimeout,
    required this.pinCodeEnabled,
    this.pinCode,
    required this.patternLockEnabled,
    this.patternLock,
    required this.sensitiveDataEncryption,
    required this.autoLogoutEnabled,
    required this.autoLogoutTimeout,
  });

  factory SecuritySettings.defaultSettings() {
    return const SecuritySettings(
      biometricAuthEnabled: false,
      appLockEnabled: false,
      appLockTimeout: 5,
      pinCodeEnabled: false,
      pinCode: null,
      patternLockEnabled: false,
      patternLock: null,
      sensitiveDataEncryption: true,
      autoLogoutEnabled: false,
      autoLogoutTimeout: 30,
    );
  }

  factory SecuritySettings.fromMap(Map<String, dynamic> map) {
    return SecuritySettings(
      biometricAuthEnabled: map['biometricAuthEnabled'] ?? false,
      appLockEnabled: map['appLockEnabled'] ?? false,
      appLockTimeout: map['appLockTimeout'] ?? 5,
      pinCodeEnabled: map['pinCodeEnabled'] ?? false,
      pinCode: map['pinCode'],
      patternLockEnabled: map['patternLockEnabled'] ?? false,
      patternLock: map['patternLock'],
      sensitiveDataEncryption: map['sensitiveDataEncryption'] ?? true,
      autoLogoutEnabled: map['autoLogoutEnabled'] ?? false,
      autoLogoutTimeout: map['autoLogoutTimeout'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'biometricAuthEnabled': biometricAuthEnabled,
      'appLockEnabled': appLockEnabled,
      'appLockTimeout': appLockTimeout,
      'pinCodeEnabled': pinCodeEnabled,
      'pinCode': pinCode,
      'patternLockEnabled': patternLockEnabled,
      'patternLock': patternLock,
      'sensitiveDataEncryption': sensitiveDataEncryption,
      'autoLogoutEnabled': autoLogoutEnabled,
      'autoLogoutTimeout': autoLogoutTimeout,
    };
  }

  SecuritySettings copyWith({
    bool? biometricAuthEnabled,
    bool? appLockEnabled,
    int? appLockTimeout,
    bool? pinCodeEnabled,
    String? pinCode,
    bool? patternLockEnabled,
    String? patternLock,
    bool? sensitiveDataEncryption,
    bool? autoLogoutEnabled,
    int? autoLogoutTimeout,
  }) {
    return SecuritySettings(
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      appLockTimeout: appLockTimeout ?? this.appLockTimeout,
      pinCodeEnabled: pinCodeEnabled ?? this.pinCodeEnabled,
      pinCode: pinCode ?? this.pinCode,
      patternLockEnabled: patternLockEnabled ?? this.patternLockEnabled,
      patternLock: patternLock ?? this.patternLock,
      sensitiveDataEncryption: sensitiveDataEncryption ?? this.sensitiveDataEncryption,
      autoLogoutEnabled: autoLogoutEnabled ?? this.autoLogoutEnabled,
      autoLogoutTimeout: autoLogoutTimeout ?? this.autoLogoutTimeout,
    );
  }
}

/// 접근성 설정
class AccessibilitySettings {
  final bool screenReaderEnabled;
  final double textScaleFactor;
  final bool highContrastEnabled;
  final bool reduceMotionEnabled;
  final bool boldTextEnabled;
  final bool largeTextEnabled;
  final bool colorBlindSupportEnabled;
  final String? colorBlindType;
  final bool keyboardNavigationEnabled;
  final bool soundEffectsEnabled;

  const AccessibilitySettings({
    required this.screenReaderEnabled,
    required this.textScaleFactor,
    required this.highContrastEnabled,
    required this.reduceMotionEnabled,
    required this.boldTextEnabled,
    required this.largeTextEnabled,
    required this.colorBlindSupportEnabled,
    this.colorBlindType,
    required this.keyboardNavigationEnabled,
    required this.soundEffectsEnabled,
  });

  factory AccessibilitySettings.defaultSettings() {
    return const AccessibilitySettings(
      screenReaderEnabled: false,
      textScaleFactor: 1.0,
      highContrastEnabled: false,
      reduceMotionEnabled: false,
      boldTextEnabled: false,
      largeTextEnabled: false,
      colorBlindSupportEnabled: false,
      colorBlindType: null,
      keyboardNavigationEnabled: false,
      soundEffectsEnabled: true,
    );
  }

  factory AccessibilitySettings.fromMap(Map<String, dynamic> map) {
    return AccessibilitySettings(
      screenReaderEnabled: map['screenReaderEnabled'] ?? false,
      textScaleFactor: (map['textScaleFactor'] ?? 1.0).toDouble(),
      highContrastEnabled: map['highContrastEnabled'] ?? false,
      reduceMotionEnabled: map['reduceMotionEnabled'] ?? false,
      boldTextEnabled: map['boldTextEnabled'] ?? false,
      largeTextEnabled: map['largeTextEnabled'] ?? false,
      colorBlindSupportEnabled: map['colorBlindSupportEnabled'] ?? false,
      colorBlindType: map['colorBlindType'],
      keyboardNavigationEnabled: map['keyboardNavigationEnabled'] ?? false,
      soundEffectsEnabled: map['soundEffectsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'screenReaderEnabled': screenReaderEnabled,
      'textScaleFactor': textScaleFactor,
      'highContrastEnabled': highContrastEnabled,
      'reduceMotionEnabled': reduceMotionEnabled,
      'boldTextEnabled': boldTextEnabled,
      'largeTextEnabled': largeTextEnabled,
      'colorBlindSupportEnabled': colorBlindSupportEnabled,
      'colorBlindType': colorBlindType,
      'keyboardNavigationEnabled': keyboardNavigationEnabled,
      'soundEffectsEnabled': soundEffectsEnabled,
    };
  }

  AccessibilitySettings copyWith({
    bool? screenReaderEnabled,
    double? textScaleFactor,
    bool? highContrastEnabled,
    bool? reduceMotionEnabled,
    bool? boldTextEnabled,
    bool? largeTextEnabled,
    bool? colorBlindSupportEnabled,
    String? colorBlindType,
    bool? keyboardNavigationEnabled,
    bool? soundEffectsEnabled,
  }) {
    return AccessibilitySettings(
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
      reduceMotionEnabled: reduceMotionEnabled ?? this.reduceMotionEnabled,
      boldTextEnabled: boldTextEnabled ?? this.boldTextEnabled,
      largeTextEnabled: largeTextEnabled ?? this.largeTextEnabled,
      colorBlindSupportEnabled: colorBlindSupportEnabled ?? this.colorBlindSupportEnabled,
      colorBlindType: colorBlindType ?? this.colorBlindType,
      keyboardNavigationEnabled: keyboardNavigationEnabled ?? this.keyboardNavigationEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
    );
  }
}
