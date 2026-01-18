import '../entities/diary_entry.dart';

abstract class IDiaryRepository {
  Future<List<DiaryEntry>> getDiaries(String userId, {int limit, String? startAfterId});
  Future<void> createDiary(DiaryEntry diary);
  Future<void> updateDiary(DiaryEntry diary);
  Future<void> deleteDiary(String diaryId);
  Future<void> deleteDiaries(List<String> diaryIds);
  Future<DiaryEntry?> getDiaryById(String diaryId);
}

