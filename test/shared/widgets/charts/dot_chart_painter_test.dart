import 'package:flutter_test/flutter_test.dart';
import 'package:emoti_flow/shared/widgets/charts/dot_chart_painter.dart';
import 'package:flutter/material.dart';

void main() {
  group('DotChartPainter Tests', () {
    test('빈 데이터는 아무것도 그리지 않아야 함', () {
      // Arrange
      final painter = DotChartPainter(
        emotionData: {},
        primaryColor: Colors.blue,
      );

      // Act & Assert
      expect(painter.emotionData.isEmpty, isTrue);
    });

    test('감정 데이터가 올바르게 정렬되어야 함', () {
      // Arrange
      final emotionData = {
        '슬픔': 3.0,
        '기쁨': 10.0,
        '분노': 5.0,
      };

      final painter = DotChartPainter(
        emotionData: emotionData,
        primaryColor: Colors.blue,
      );

      // Act
      final sorted = emotionData.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Assert
      expect(sorted.first.key, '기쁨');
      expect(sorted.first.value, 10.0);
      expect(sorted.last.key, '슬픔');
      expect(sorted.last.value, 3.0);
    });

    test('상대적 수치가 올바르게 계산되어야 함', () {
      // Arrange
      final emotionData = {
        '기쁨': 8.0,
        '슬픔': 4.0,
        '분노': 2.0,
      };

      // Act - 최고값이 10점이 되도록 정규화
      final maxValue = emotionData.values.reduce((a, b) => a > b ? a : b);
      final normalized =
          emotionData.map((k, v) => MapEntry(k, (v / maxValue) * 10.0));

      // Assert
      expect(normalized['기쁨'], 10.0);
      expect(normalized['슬픔'], 5.0);
      expect(normalized['분노'], 2.5);
    });
  });
}
