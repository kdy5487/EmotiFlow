import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoti_flow/features/diary/data/models/diary_model.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

void main() {
  group('DiaryModel Tests', () {
    test('fromFirestore로 올바르게 변환되어야 함', () {
      // Arrange
      final data = {
        'userId': 'user-1',
        'title': '테스트 일기',
        'content': '내용',
        'emotions': ['기쁨', '슬픔'],
        'emotionIntensities': {'기쁨': 8, '슬픔': 3},
        'createdAt': Timestamp.now(),
        'updatedAt': null,
        'mediaFiles': [],
        'aiAnalysis': null,
        'chatHistory': [],
        'weather': '맑음',
        'location': '서울',
        'tags': ['태그1'],
        'isPublic': false,
        'diaryType': 'free',
        'metadata': null,
      };

      // Act
      final snapshot = FakeDocumentSnapshot(id: 'test-id', data: data);
      final model = DiaryModel.fromFirestore(snapshot as DocumentSnapshot);

      // Assert
      expect(model.id, 'test-id');
      expect(model.userId, 'user-1');
      expect(model.title, '테스트 일기');
      expect(model.content, '내용');
      expect(model.emotions, ['기쁨', '슬픔']);
      expect(model.emotionIntensities['기쁨'], 8);
      expect(model.weather, '맑음');
      expect(model.location, '서울');
      expect(model.tags, ['태그1']);
      expect(model.isPublic, false);
      expect(model.diaryType, DiaryType.free);
    });

    test('toMap으로 올바르게 변환되어야 함', () {
      // Arrange
      final model = DiaryModel(
        id: 'test-id',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: ['기쁨'],
        emotionIntensities: {'기쁨': 8},
        createdAt: DateTime(2024, 1, 1),
        diaryType: DiaryType.free,
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(map['userId'], 'user-1');
      expect(map['title'], '테스트 일기');
      expect(map['content'], '내용');
      expect(map['emotions'], ['기쁨']);
      expect(map['emotionIntensities'], {'기쁨': 8});
      expect(map['diaryType'], 'free');
      expect(map['isPublic'], false);
    });

    test('fromEntity로 올바르게 변환되어야 함', () {
      // Arrange
      final entity = DiaryEntry(
        id: 'test-id',
        userId: 'user-1',
        title: '테스트 일기',
        content: '내용',
        emotions: ['기쁨'],
        emotionIntensities: {'기쁨': 8},
        createdAt: DateTime.now(),
      );

      // Act
      final model = DiaryModel.fromEntity(entity);

      // Assert
      expect(model.id, entity.id);
      expect(model.userId, entity.userId);
      expect(model.title, entity.title);
      expect(model.content, entity.content);
      expect(model.emotions, entity.emotions);
      expect(model.emotionIntensities, entity.emotionIntensities);
    });
  });
}

// 테스트용 가짜 DocumentSnapshot
class FakeDocumentSnapshot implements DocumentSnapshot {
  @override
  final String id;
  final Map<String, dynamic> _data;

  FakeDocumentSnapshot({required this.id, required Map<String, dynamic> data}) : _data = data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic get(Object? field) => _data[field];

  @override
  dynamic operator [](Object? field) => _data[field];

  @override
  bool get exists => true;

  @override
  DocumentReference get reference => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
}

