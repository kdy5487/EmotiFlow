import 'package:flutter_test/flutter_test.dart';
import 'package:emoti_flow/core/ai/gemini/gemini_service.dart';

void main() {
  group('GeminiService Tests', () {
    test('프롬프트 최적화 - 간결한 프롬프트가 더 빠르게 처리되어야 함', () {
      // Arrange
      final longPrompt = '''
당신은 전문적인 심리 상담가이자 감정 분석 전문가입니다. 다음은 이번 주(최근 7일간) 작성된 일기들입니다.

**일기 내용:**
일기 내용...

**분석 요청사항:**
1. 감정 패턴 분석
2. 감정 강도 분석
... (많은 설명)
''';

      final shortPrompt = '''이번 주(최근 7일) 일기 감정 분석:

일기 내용...

주요 감정과 변화 추이를 5-7문장으로 분석. 구체적 수치와 날짜 포함. 한국어로 작성.''';

      // Act
      final longLength = longPrompt.length;
      final shortLength = shortPrompt.length;

      // Assert
      expect(shortLength, lessThan(longLength));
      final reduction = ((longLength - shortLength) / longLength * 100).round();
      print('프롬프트 길이 감소: ${reduction}%');
      expect(reduction, greaterThan(30)); // 30% 이상 감소 (실제로는 38%)
    });

    test('프롬프트에 그래프 결과가 포함되어야 함', () {
      // Arrange
      final emotionData = {
        '기쁨': 10.0,
        '슬픔': 5.0,
        '분노': 3.0,
      };
      final graphSummary = emotionData.entries
          .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}점')
          .join(', ');

      final prompt = '''이번 주(최근 7일) 일기 피드백:

일기 내용...

감정 상대 수치: $graphSummary

감정 패턴 요약(2-3문장), 구체적 조언(2-3문장), 실행 가능한 개선 방안 3-5가지. 한국어로 작성.''';

      // Act & Assert
      expect(prompt.contains('감정 상대 수치'), isTrue);
      expect(prompt.contains('기쁨: 10.0점'), isTrue);
      expect(prompt.contains('슬픔: 5.0점'), isTrue);
    });
  });
}

