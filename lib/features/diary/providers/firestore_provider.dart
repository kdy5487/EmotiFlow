import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_entry.dart';

/// Firestore 실시간 데이터 Provider
class FirestoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 일기 컬렉션 실시간 스트림
  Stream<QuerySnapshot> getDiariesStream(String userId) {
    return _firestore
        .collection('diaries')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  /// 일기 컬렉션 일회성 조회
  Future<QuerySnapshot> getDiaries(String userId) async {
    return await _firestore
        .collection('diaries')
        .where('userId', isEqualTo: userId)
        .get();
  }

  /// 일기 저장
  Future<void> saveDiary(DiaryEntry entry) async {
    try {
      final collection = _firestore.collection('diaries');
      final docRef = entry.id.isEmpty ? collection.doc() : collection.doc(entry.id);
      final data = {
        ...entry.toFirestore(),
        // 저장 시점에 createdAt이 비어있지 않도록 보장
        'createdAt': entry.createdAt == null
            ? Timestamp.fromDate(DateTime.now())
            : Timestamp.fromDate(entry.createdAt),
        // 문서 ID 동기화
        'id': docRef.id,
      };
      await docRef.set(data);
      print('✅ 일기 저장 성공: ${entry.id}');
    } catch (e) {
      print('❌ 일기 저장 실패: $e');
      rethrow;
    }
  }

  /// 일기 업데이트
  Future<void> updateDiary(DiaryEntry entry) async {
    try {
      await _firestore
          .collection('diaries')
          .doc(entry.id)
          .update(entry.toFirestore());
      print('✅ 일기 업데이트 성공: ${entry.id}');
    } catch (e) {
      print('❌ 일기 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 일기 삭제
  Future<void> deleteDiary(String entryId) async {
    try {
      await _firestore
          .collection('diaries')
          .doc(entryId)
          .delete();
      print('✅ 일기 삭제 성공: $entryId');
    } catch (e) {
      print('❌ 일기 삭제 실패: $e');
      rethrow;
    }
  }

  /// 특정 일기 조회
  Future<DiaryEntry?> getDiary(String entryId) async {
    try {
      final doc = await _firestore
          .collection('diaries')
          .doc(entryId)
          .get();
      
      if (doc.exists) {
        return DiaryEntry.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ 일기 조회 실패: $e');
      return null;
    }
  }

  /// 개발용 더미 데이터 시드
  Future<void> seedDummyDiaries(String userId) async {
    final col = _firestore.collection('diaries');
    // 자유형
    final free = DiaryEntry(
      userId: userId,
      title: '봄 산책의 기억',
      content: '따뜻한 햇살 아래 공원을 산책했다. 벤치에 앉아 있자니 바람이 살짝 스쳤고, 마음이 한결 가벼워졌다.',
      emotions: ['평온', '감사'],
      emotionIntensities: {'평온': 8, '감사': 7},
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      diaryType: DiaryType.free,
      mediaFiles: [
        MediaFile(id: 'm1', url: 'https://picsum.photos/seed/park/800/600', type: MediaType.image),
        MediaFile(id: 'm2', url: 'https://picsum.photos/seed/sketch/800/600', type: MediaType.drawing),
      ],
      tags: ['산책', '봄', '휴식'],
    );

    // AI 대화형
    final ai = DiaryEntry(
      userId: userId,
      title: '면접 준비로 인한 긴장',
      content: '다가오는 면접이 걱정되지만 스스로를 믿고 준비해나가기로 했다. 조금씩 정리하다 보니 설렘도 함께 느껴진다.',
      emotions: ['걱정', '설렘'],
      emotionIntensities: {'걱정': 7, '설렘': 6},
      createdAt: DateTime.now(),
      diaryType: DiaryType.aiChat,
      mediaFiles: [
        MediaFile(id: 'm3', url: 'https://picsum.photos/seed/office/800/600', type: MediaType.image),
        MediaFile(id: 'm4', url: 'https://picsum.photos/seed/notes/800/600', type: MediaType.drawing),
      ],
      chatHistory: [
        ChatMessage(id: 'c1', content: '면접이 다가오는데 떨리고 걱정돼요.', isFromAI: false, timestamp: DateTime.now()),
        ChatMessage(id: 'c2', content: '그 마음 충분히 이해해요. 어떤 부분이 가장 걱정되나요?', isFromAI: true, timestamp: DateTime.now()),
      ],
      tags: ['면접', '준비', '목표'],
    );

    await col.doc(free.id).set(free.toFirestore());
    await col.doc(ai.id).set(ai.toFirestore());
  }
}

/// Firestore Provider 인스턴스
final firestoreProvider = Provider<FirestoreProvider>((ref) {
  return FirestoreProvider();
});

/// 일기 실시간 스트림 Provider
final diariesStreamProvider = StreamProvider.family<QuerySnapshot, String>((ref, userId) {
  final firestore = ref.read(firestoreProvider);
  return firestore.getDiariesStream(userId);
});

/// 일기 일회성 조회 Provider
final diariesFutureProvider = FutureProvider.family<QuerySnapshot, String>((ref, userId) async {
  final firestore = ref.read(firestoreProvider);
  return await firestore.getDiaries(userId);
});

/// 특정 일기 조회 Provider
final diaryDetailProvider = FutureProvider.family<DiaryEntry?, String>((ref, entryId) async {
  final firestore = ref.read(firestoreProvider);
  return await firestore.getDiary(entryId);
});
