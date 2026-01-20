import 'package:flutter_test/flutter_test.dart';
import 'package:emoti_flow/shared/constants/emotion_character_map.dart';

void main() {
  group('EmotionCharacterMap Tests', () {
    test('감정-캐릭터 매핑이 올바르게 되어있는지 확인', () {
      // Arrange
      const emotion = '기쁨';

      // Act
      final characterAsset = EmotionCharacterMap.getCharacterAsset(emotion);

      // Assert
      expect(characterAsset, 'assets/images/emotions/happy.PNG');
    });

    test('null 감정은 기본 캐릭터를 반환해야 함', () {
      // Act
      final characterAsset = EmotionCharacterMap.getCharacterAsset(null);

      // Assert
      expect(characterAsset, EmotionCharacterMap.defaultCharacter);
    });

    test('빈 문자열 감정은 기본 캐릭터를 반환해야 함', () {
      // Act
      final characterAsset = EmotionCharacterMap.getCharacterAsset('');

      // Assert
      expect(characterAsset, EmotionCharacterMap.defaultCharacter);
    });

    test('매핑되지 않은 감정은 기본 캐릭터를 반환해야 함', () {
      // Act
      final characterAsset = EmotionCharacterMap.getCharacterAsset('알 수 없음');

      // Assert
      expect(characterAsset, EmotionCharacterMap.defaultCharacter);
    });

    test('영문 ID가 한글로 변환되어야 함', () {
      // Act
      final characterAsset = EmotionCharacterMap.getCharacterAsset('joy');

      // Assert
      expect(characterAsset, 'assets/images/emotions/happy.PNG');
    });

    test('모든 사용 가능한 감정 목록을 반환해야 함', () {
      // Act
      final emotions = EmotionCharacterMap.availableEmotions;

      // Assert
      expect(emotions, isNotEmpty);
      expect(emotions.length, 10); // 10개의 감정
      expect(emotions, contains('기쁨'));
      expect(emotions, contains('슬픔'));
    });

    test('감정별 배경색이 올바르게 반환되어야 함', () {
      // Act
      final backgroundColor = EmotionCharacterMap.getBackgroundColor('기쁨');

      // Assert
      expect(backgroundColor, 0xFFFFF9E6); // 따뜻한 노란색
    });

    test('null 감정은 기본 배경색(흰색)을 반환해야 함', () {
      // Act
      final backgroundColor = EmotionCharacterMap.getBackgroundColor(null);

      // Assert
      expect(backgroundColor, 0xFFFFFFFF); // 흰색
    });

    test('캐릭터 존재 여부를 확인할 수 있어야 함', () {
      // Assert
      expect(EmotionCharacterMap.hasCharacter('기쁨'), isTrue);
      expect(EmotionCharacterMap.hasCharacter('알 수 없음'), isFalse);
    });
  });
}
