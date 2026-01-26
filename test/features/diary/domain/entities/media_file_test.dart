import 'package:flutter_test/flutter_test.dart';
import 'package:emoti_flow/features/diary/domain/entities/media_file.dart';

void main() {
  group('MediaFile Entity Tests', () {
    test('이미지 타입이 올바르게 설정되어야 함', () {
      // Arrange & Act
      final imageFile = MediaFile(
        id: 'media-1',
        url: 'https://example.com/image.jpg',
        type: MediaType.image,
      );

      // Assert
      expect(imageFile.type, MediaType.image);
      expect(imageFile.url, 'https://example.com/image.jpg');
    });

    test('비디오 타입이 올바르게 설정되어야 함', () {
      // Arrange & Act
      final videoFile = MediaFile(
        id: 'media-2',
        url: 'https://example.com/video.mp4',
        type: MediaType.video,
        duration: 60,
      );

      // Assert
      expect(videoFile.type, MediaType.video);
      expect(videoFile.duration, 60);
    });

    test('썸네일 URL이 올바르게 설정되어야 함', () {
      // Arrange & Act
      final file = MediaFile(
        id: 'media-3',
        url: 'https://example.com/video.mp4',
        type: MediaType.video,
        thumbnailUrl: 'https://example.com/thumb.jpg',
      );

      // Assert
      expect(file.thumbnailUrl, 'https://example.com/thumb.jpg');
    });
  });
}

