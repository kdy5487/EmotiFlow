import 'package:flutter_test/flutter_test.dart';
import 'package:emoti_flow/features/diary/domain/entities/ai_analysis.dart';

void main() {
  group('AIAnalysis Entity Tests', () {
    test('모든 필드가 올바르게 초기화되어야 함', () {
      // Arrange & Act
      final analysis = AIAnalysis(
        id: 'analysis-1',
        summary: '일기 요약',
        keywords: ['키워드1', '키워드2'],
        emotionScores: {'기쁨': 0.8, '슬픔': 0.2},
        advice: '조언 내용',
        actionItems: ['액션1', '액션2'],
        moodTrend: '상승',
        analyzedAt: DateTime(2024, 1, 1),
      );

      // Assert
      expect(analysis.id, 'analysis-1');
      expect(analysis.summary, '일기 요약');
      expect(analysis.keywords.length, 2);
      expect(analysis.emotionScores['기쁨'], 0.8);
      expect(analysis.advice, '조언 내용');
      expect(analysis.actionItems.length, 2);
      expect(analysis.moodTrend, '상승');
      expect(analysis.analyzedAt, DateTime(2024, 1, 1));
    });

    test('빈 키워드와 액션 아이템을 허용해야 함', () {
      // Arrange & Act
      final analysis = AIAnalysis(
        id: 'analysis-2',
        summary: '요약',
        keywords: [],
        emotionScores: {},
        advice: '조언',
        actionItems: [],
        moodTrend: '중립',
        analyzedAt: DateTime.now(),
      );

      // Assert
      expect(analysis.keywords, isEmpty);
      expect(analysis.actionItems, isEmpty);
      expect(analysis.emotionScores, isEmpty);
    });
  });
}

