import 'package:flutter/foundation.dart';

/// 앱 환경 설정을 관리하는 클래스
class AppConfig {
  static const String _devApiUrl = 'https://dev-api.emoti-flow.com';
  static const String _prodApiUrl = 'https://api.emoti-flow.com';
  static const String _stagingApiUrl = 'https://staging-api.emoti-flow.com';

  /// 현재 빌드 모드
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;

  /// 현재 환경
  static Environment get environment {
    if (isDebug) return Environment.development;
    if (isProfile) return Environment.staging;
    return Environment.production;
  }

  /// API URL
  static String get apiUrl {
    switch (environment) {
      case Environment.development:
        return _devApiUrl;
      case Environment.staging:
        return _stagingApiUrl;
      case Environment.production:
        return _prodApiUrl;
    }
  }

  /// Firebase 프로젝트 ID
  static String get firebaseProjectId {
    switch (environment) {
      case Environment.development:
        return 'emoti-flow-dev';
      case Environment.staging:
        return 'emoti-flow-staging';
      case Environment.production:
        return 'emoti-flow-prod';
    }
  }

  /// 로그 레벨
  static LogLevel get logLevel {
    switch (environment) {
      case Environment.development:
        return LogLevel.debug;
      case Environment.staging:
        return LogLevel.info;
      case Environment.production:
        return LogLevel.warning;
    }
  }

  /// 기능 플래그
  static bool get enableAnalytics => environment != Environment.development;
  static bool get enableCrashReporting =>
      environment != Environment.development;
  static bool get enablePerformanceMonitoring =>
      environment != Environment.development;

  /// 디버그 기능
  static bool get enableDebugMenu => environment == Environment.development;
  static bool get enableHotReload => environment == Environment.development;
  static bool get enableDevTools => environment == Environment.development;

  /// 앱 정보
  static const String appName = 'EmotiFlow';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  /// 지원하는 플랫폼
  static const List<String> supportedPlatforms = ['android', 'ios', 'web'];

  /// 최소 지원 버전
  static const Map<String, String> minSupportedVersions = {
    'android': '5.0',
    'ios': '12.0',
  };
}

/// 앱 환경
enum Environment {
  development,
  staging,
  production,
}

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 환경별 설정 값
extension EnvironmentExtension on Environment {
  String get displayName {
    switch (this) {
      case Environment.development:
        return '개발';
      case Environment.staging:
        return '스테이징';
      case Environment.production:
        return '운영';
    }
  }

  String get shortName {
    switch (this) {
      case Environment.development:
        return 'DEV';
      case Environment.staging:
        return 'STG';
      case Environment.production:
        return 'PROD';
    }
  }

  bool get isProduction => this == Environment.production;
  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
}
