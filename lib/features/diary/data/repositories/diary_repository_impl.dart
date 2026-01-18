import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_remote_data_source.dart';
import '../models/diary_model.dart';

class DiaryRepositoryImpl implements IDiaryRepository {
  final DiaryRemoteDataSource remoteDataSource;

  DiaryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DiaryEntry>> getDiaries(String userId, {int limit = 20, String? startAfterId}) async {
    return await remoteDataSource.getDiaries(userId, limit: limit, startAfterId: startAfterId);
  }

  @override
  Future<void> createDiary(DiaryEntry diary) async {
    final model = DiaryModel.fromEntity(diary);
    await remoteDataSource.createDiary(model);
  }

  @override
  Future<void> updateDiary(DiaryEntry diary) async {
    final model = DiaryModel.fromEntity(diary);
    await remoteDataSource.updateDiary(model);
  }

  @override
  Future<void> deleteDiary(String diaryId) async {
    await remoteDataSource.deleteDiary(diaryId);
  }

  @override
  Future<void> deleteDiaries(List<String> diaryIds) async {
    await remoteDataSource.deleteDiaries(diaryIds);
  }

  @override
  Future<DiaryEntry?> getDiaryById(String diaryId) async {
    return await remoteDataSource.getDiaryById(diaryId);
  }
}

