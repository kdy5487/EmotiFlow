import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// 환경별 로그 레벨을 관리하는 로거 클래스
class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  /// 디버그 로그
  static void debug(String message, [String? tag]) {
    if (_shouldLog(LogLevel.debug)) {
      _log('DEBUG', message, tag);
    }
  }

  /// 정보 로그
  static void info(String message, [String? tag]) {
    if (_shouldLog(LogLevel.info)) {
      _log('INFO', message, tag);
    }
  }

  /// 경고 로그
  static void warning(String message, [String? tag]) {
    if (_shouldLog(LogLevel.warning)) {
      _log('WARNING', message, tag);
    }
  }

  /// 오류 로그
  static void error(String message,
      [String? tag, dynamic error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.error)) {
      _log('ERROR', message, tag);
      if (error != null) {
        _log('ERROR', 'Error: $error', tag);
      }
      if (stackTrace != null) {
        _log('ERROR', 'StackTrace: $stackTrace', tag);
      }
    }
  }

  /// 로그 출력 여부 확인
  static bool _shouldLog(LogLevel level) {
    final currentLevel = AppConfig.logLevel;

    switch (currentLevel) {
      case LogLevel.debug:
        return true;
      case LogLevel.info:
        return level != LogLevel.debug;
      case LogLevel.warning:
        return level == LogLevel.warning || level == LogLevel.error;
      case LogLevel.error:
        return level == LogLevel.error;
    }
  }

  /// 실제 로그 출력
  static void _log(String level, String message, String? tag) {
    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag]' : '';
    final logMessage = '[$timestamp] $level$tagStr: $message';

    if (kDebugMode) {
      // 디버그 모드에서는 print 사용
      print(logMessage);
    } else {
      // 릴리즈 모드에서는 시스템 로그 사용
      // Android: Log.d, iOS: os_log
      // 실제 구현에서는 플랫폼별 로깅 사용
    }
  }

  /// 성능 측정 시작
  static Stopwatch _startTimer(String operation) {
    return Stopwatch()..start();
  }

  /// 성능 측정 종료
  static void endTimer(Stopwatch stopwatch, String operation) {
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    info('$operation completed in ${duration}ms');
  }

  /// 성능 측정 래퍼
  static Future<T> measurePerformance<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    final stopwatch = _startTimer(operation);
    try {
      final result = await function();
      endTimer(stopwatch, operation);
      return result;
    } catch (e, stackTrace) {
      endTimer(stopwatch, operation);
      error('$operation failed', null, e, stackTrace);
      rethrow;
    }
  }

  /// 동기 성능 측정 래퍼
  static T measurePerformanceSync<T>(
    String operation,
    T Function() function,
  ) {
    final stopwatch = _startTimer(operation);
    try {
      final result = function();
      endTimer(stopwatch, operation);
      return result;
    } catch (e, stackTrace) {
      endTimer(stopwatch, operation);
      error('$operation failed', null, e, stackTrace);
      rethrow;
    }
  }
}

/// 로그 태그 상수
class LogTags {
  static const String auth = 'AUTH';
  static const String database = 'DATABASE';
  static const String network = 'NETWORK';
  static const String ui = 'UI';
  static const String music = 'MUSIC';
  static const String ai = 'AI';
  static const String diary = 'DIARY';
  static const String settings = 'SETTINGS';
  static const String performance = 'PERFORMANCE';
  static const String error = 'ERROR';
}

/// 로그 사용 예시를 위한 확장 메서드
extension LoggerExtension on Object {
  void logDebug(String message) =>
      Logger.debug(message, runtimeType.toString());
  void logInfo(String message) => Logger.info(message, runtimeType.toString());
  void logWarning(String message) =>
      Logger.warning(message, runtimeType.toString());
  void logError(String message, [dynamic error, StackTrace? stackTrace]) =>
      Logger.error(message, runtimeType.toString(), error, stackTrace);
}
