import '../repositories/diary_repository.dart';

class DeleteDiaryUseCase {
  final IDiaryRepository repository;

  DeleteDiaryUseCase(this.repository);

  Future<void> execute(String diaryId) {
    return repository.deleteDiary(diaryId);
  }
}

