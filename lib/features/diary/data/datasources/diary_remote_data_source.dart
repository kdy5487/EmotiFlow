import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_model.dart';

class DiaryRemoteDataSource {
  final FirebaseFirestore firestore;

  DiaryRemoteDataSource(this.firestore);

  Future<List<DiaryModel>> getDiaries(String userId, {int limit = 20, String? startAfterId}) async {
    Query query = firestore.collection('diaries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfterId != null) {
      final lastDoc = await firestore.collection('diaries').doc(startAfterId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => DiaryModel.fromFirestore(doc)).toList();
  }

  Future<void> createDiary(DiaryModel diary) async {
    await firestore.collection('diaries').doc(diary.id).set(diary.toMap());
  }

  Future<void> updateDiary(DiaryModel diary) async {
    await firestore.collection('diaries').doc(diary.id).update(diary.toMap());
  }

  Future<void> deleteDiary(String diaryId) async {
    await firestore.collection('diaries').doc(diaryId).delete();
  }

  Future<void> deleteDiaries(List<String> diaryIds) async {
    final batch = firestore.batch();
    for (final id in diaryIds) {
      batch.delete(firestore.collection('diaries').doc(id));
    }
    await batch.commit();
  }

  Future<DiaryModel?> getDiaryById(String diaryId) async {
    final doc = await firestore.collection('diaries').doc(diaryId).get();
    if (doc.exists) {
      return DiaryModel.fromFirestore(doc);
    }
    return null;
  }
}

