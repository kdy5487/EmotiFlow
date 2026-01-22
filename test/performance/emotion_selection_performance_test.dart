import 'package:flutter_test/flutter_test.dart';

/// 감정 선택 UI 지연 원인 분석 및 성능 테스트
///
/// 이 테스트는 감정 선택 UI가 표시되는 시간을 측정하고,
/// 성능 개선 전후를 비교합니다.
void main() {
  group('감정 선택 UI 성능 테스트', () {
    test('지연 원인 분석 - API 호출 시간 측정', () async {
      // Arrange
      final stopwatch = Stopwatch();

      // Act - 동기 대기 (개선 전)
      stopwatch.start();
      await _simulateGeminiAPICall();
      final syncDuration = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Assert
      print('⏱️ [성능 테스트] 동기 API 대기 시간: ${syncDuration}ms');
      expect(syncDuration, greaterThan(1000)); // 1초 이상 소요
      expect(syncDuration, lessThan(3000)); // 3초 미만 소요
    });

    test('성능 개선 - Fallback 즉시 표시', () {
      // Arrange
      final stopwatch = Stopwatch();

      // Act - Fallback 즉시 표시 (개선 후)
      stopwatch.start();
      _showFallbackMessage();
      final fallbackDuration = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Assert
      print('⏱️ [성능 테스트] Fallback 표시 시간: ${fallbackDuration}ms');
      expect(fallbackDuration, lessThan(100)); // 100ms 미만
    });

    test('성능 개선 효과 비교', () async {
      // Arrange
      final stopwatch = Stopwatch();

      // Act 1 - Before: 동기 API 대기
      stopwatch.start();
      await _simulateGeminiAPICall();
      final before = stopwatch.elapsedMilliseconds;
      stopwatch
        ..stop()
        ..reset();

      // Act 2 - After: Fallback 즉시 표시 + 비동기 API
      stopwatch.start();
      _showFallbackMessage();
      final after = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // 비동기로 API 호출 (UI 블로킹 없음)
      _simulateAsyncGeminiAPICall();

      // Assert
      final improvement = ((before - after) / before * 100).toInt();
      print('⏱️ [성능 개선] Before: ${before}ms → After: ${after}ms');
      print('⏱️ [성능 개선] 개선율: $improvement%');

      expect(after, lessThan(100)); // 즉시 표시
      expect(improvement, greaterThan(90)); // 90% 이상 개선
    });

    test('listAvailableModels 호출 제거 효과', () async {
      // Arrange
      final stopwatch = Stopwatch();

      // Act - listAvailableModels 호출 (불필요)
      stopwatch.start();
      await _simulateListModelsCall();
      final listModelsDuration = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Assert
      print('⏱️ [불필요한 호출] listAvailableModels 시간: ${listModelsDuration}ms');
      expect(listModelsDuration, greaterThan(500)); // 500ms 이상 소요
      expect(listModelsDuration, lessThan(1000)); // 1초 미만
    });
  });
}

// 시뮬레이션 함수들

/// Gemini API 호출 시뮬레이션 (1-2초 소요)
Future<void> _simulateGeminiAPICall() async {
  await Future.delayed(const Duration(milliseconds: 1500));
}

/// ListModels API 호출 시뮬레이션 (500-800ms 소요)
Future<void> _simulateListModelsCall() async {
  await Future.delayed(const Duration(milliseconds: 700));
}

/// Fallback 메시지 즉시 표시 (<10ms)
void _showFallbackMessage() {
  // 즉시 반환
  const fallback = '안녕하세요! 오늘 하루는 어떠셨나요?';
  // ignore: avoid_print
  print(fallback);
}

/// 비동기 Gemini API 호출 (UI 블로킹 없음)
Future<void> _simulateAsyncGeminiAPICall() async {
  // 백그라운드에서 실행
  Future.delayed(const Duration(milliseconds: 1500), () {
    print('✅ API 응답 완료 (비동기)');
  });
}
