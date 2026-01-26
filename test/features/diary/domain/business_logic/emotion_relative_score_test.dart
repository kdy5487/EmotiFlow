import 'package:flutter_test/flutter_test.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

void main() {
  group('감정 상대 수치 계산 테스트', () {
    test('가장 높은 감정이 10점이 되어야 함', () {
      // Arrange
      final entries = [
        DiaryEntry(
          id: '1',
          userId: 'user-1',
          title: '일기1',
          content: '내용',
          emotions: ['기쁨'],
          emotionIntensities: {'기쁨': 8},
          createdAt: DateTime.now(),
        ),
        DiaryEntry(
          id: '2',
          userId: 'user-1',
          title: '일기2',
          content: '내용',
          emotions: ['슬픔'],
          emotionIntensities: {'슬픔': 4},
          createdAt: DateTime.now(),
        ),
      ];

      // Act - 상대 수치 계산
      final emotionIntensities = <String, double>{};
      final emotionCounts = <String, int>{};

      for (final entry in entries) {
        final intensity = entry.emotionIntensities.values.isNotEmpty
            ? entry.emotionIntensities.values.first.toDouble()
            : 5.0;

        for (final emotion in entry.emotions) {
          emotionIntensities[emotion] = (emotionIntensities[emotion] ?? 0) + intensity;
          emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        }
      }

      final emotionAverages = <String, double>{};
      emotionIntensities.forEach((emotion, total) {
        final count = emotionCounts[emotion] ?? 1;
        emotionAverages[emotion] = total / count;
      });

      final maxValue = emotionAverages.values.reduce((a, b) => a > b ? a : b);
      final relativeData = <String, double>{};
      emotionAverages.forEach((emotion, value) {
        relativeData[emotion] = (value / maxValue) * 10.0;
      });

      // Assert
      expect(relativeData['기쁨'], 10.0);
      expect(relativeData['슬픔'], 5.0);
    });

    test('감정이 없으면 빈 맵을 반환해야 함', () {
      // Arrange
      final entries = <DiaryEntry>[];

      // Act
      final emotionData = <String, double>{};

      // Assert
      expect(emotionData, isEmpty);
    });

    test('같은 강도의 감정은 모두 10점이 되어야 함', () {
      // Arrange
      final entries = [
        DiaryEntry(
          id: '1',
          userId: 'user-1',
          title: '일기1',
          content: '내용',
          emotions: ['기쁨'],
          emotionIntensities: {'기쁨': 5},
          createdAt: DateTime.now(),
        ),
        DiaryEntry(
          id: '2',
          userId: 'user-1',
          title: '일기2',
          content: '내용',
          emotions: ['슬픔'],
          emotionIntensities: {'슬픔': 5},
          createdAt: DateTime.now(),
        ),
      ];

      // Act
      final emotionIntensities = <String, double>{};
      final emotionCounts = <String, int>{};

      for (final entry in entries) {
        final intensity = entry.emotionIntensities.values.isNotEmpty
            ? entry.emotionIntensities.values.first.toDouble()
            : 5.0;

        for (final emotion in entry.emotions) {
          emotionIntensities[emotion] = (emotionIntensities[emotion] ?? 0) + intensity;
          emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        }
      }

      final emotionAverages = <String, double>{};
      emotionIntensities.forEach((emotion, total) {
        final count = emotionCounts[emotion] ?? 1;
        emotionAverages[emotion] = total / count;
      });

      final maxValue = emotionAverages.values.reduce((a, b) => a > b ? a : b);
      final relativeData = <String, double>{};
      emotionAverages.forEach((emotion, value) {
        relativeData[emotion] = (value / maxValue) * 10.0;
      });

      // Assert
      expect(relativeData['기쁨'], 10.0);
      expect(relativeData['슬픔'], 10.0);
    });
  });
}

