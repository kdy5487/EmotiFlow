import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class GetDiariesUseCase {
  final IDiaryRepository repository;

  GetDiariesUseCase(this.repository);

  Future<List<DiaryEntry>> execute(String userId, {int limit = 20, String? startAfterId}) {
    return repository.getDiaries(userId, limit: limit, startAfterId: startAfterId);
  }
}

