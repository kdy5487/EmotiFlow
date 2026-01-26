import 'package:flutter_test/flutter_test.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';
import 'package:emoti_flow/features/diary/domain/entities/ai_analysis.dart';
import 'package:emoti_flow/features/diary/domain/entities/media_file.dart';

void main() {
  group('DiaryEntry Entity Tests', () {
    test('가장 강한 감정을 올바르게 추출해야 함', () {
      // Arrange
      final entry = DiaryEntry(
        id: 'test-id',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: ['기쁨', '슬픔'],
        emotionIntensities: {
          '기쁨': 8,
          '슬픔': 3,
        },
        createdAt: DateTime.now(),
      );

      // Act
      final strongest = entry.strongestEmotion;

      // Assert
      expect(strongest, '기쁨');
      expect(entry.emotionIntensities[strongest], 8);
    });

    test('감정 강도가 없으면 null을 반환해야 함', () {
      // Arrange
      final entry = DiaryEntry(
        id: 'test-id',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: [],
        emotionIntensities: {},
        createdAt: DateTime.now(),
      );

      // Act
      final strongest = entry.strongestEmotion;

      // Assert
      expect(strongest, isNull);
    });

    test('미디어 파일 개수를 올바르게 반환해야 함', () {
      // Arrange
      final entry = DiaryEntry(
        id: 'test-id',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: [],
        emotionIntensities: {},
        createdAt: DateTime.now(),
        mediaFiles: [
          MediaFile(
            id: 'media-1',
            url: 'https://example.com/image1.jpg',
            type: MediaType.image,
          ),
          MediaFile(
            id: 'media-2',
            url: 'https://example.com/image2.jpg',
            type: MediaType.image,
          ),
        ],
      );

      // Act
      final count = entry.mediaCount;

      // Assert
      expect(count, 2);
    });

    test('커버 이미지 URL을 올바르게 반환해야 함', () {
      // Arrange
      final entry = DiaryEntry(
        id: 'test-id',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: [],
        emotionIntensities: {},
        createdAt: DateTime.now(),
        mediaFiles: [
          MediaFile(
            id: 'media-1',
            url: 'https://example.com/image1.jpg',
            type: MediaType.image,
          ),
          MediaFile(
            id: 'media-2',
            url: 'https://example.com/video1.mp4',
            type: MediaType.video,
          ),
        ],
      );

      // Act
      final coverUrl = entry.coverImageUrl;

      // Assert
      expect(coverUrl, 'https://example.com/image1.jpg');
    });

    test('이미지가 없으면 null을 반환해야 함', () {
      // Arrange
      final entry = DiaryEntry(
        id: 'test-id',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: [],
        emotionIntensities: {},
        createdAt: DateTime.now(),
        mediaFiles: [
          MediaFile(
            id: 'media-1',
            url: 'https://example.com/video1.mp4',
            type: MediaType.video,
          ),
        ],
      );

      // Act
      final coverUrl = entry.coverImageUrl;

      // Assert
      expect(coverUrl, isNull);
    });

    test('AI 분석 결과 존재 여부를 올바르게 확인해야 함', () {
      // Arrange
      final entryWithAnalysis = DiaryEntry(
        id: 'test-id',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: [],
        emotionIntensities: {},
        createdAt: DateTime.now(),
        aiAnalysis: AIAnalysis(
          id: 'analysis-1',
          summary: '요약',
          keywords: [],
          emotionScores: {},
          advice: '조언',
          actionItems: [],
          moodTrend: '트렌드',
          analyzedAt: DateTime.now(),
        ),
      );

      final entryWithoutAnalysis = DiaryEntry(
        id: 'test-id-2',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: [],
        emotionIntensities: {},
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(entryWithAnalysis.hasAIAnalysis, isTrue);
      expect(entryWithoutAnalysis.hasAIAnalysis, isFalse);
    });
  });
}

