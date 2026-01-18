import '../repositories/diary_repository.dart';

class DeleteDiariesUseCase {
  final IDiaryRepository repository;

  DeleteDiariesUseCase(this.repository);

  Future<void> execute(List<String> diaryIds) {
    return repository.deleteDiaries(diaryIds);
  }
}

