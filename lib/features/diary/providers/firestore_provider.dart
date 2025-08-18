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
      throw e;
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
      throw e;
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
      throw e;
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
