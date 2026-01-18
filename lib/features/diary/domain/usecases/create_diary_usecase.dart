import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class CreateDiaryUseCase {
  final IDiaryRepository repository;

  CreateDiaryUseCase(this.repository);

  Future<void> execute(DiaryEntry diary) {
    // 저장 전 비즈니스 유효성 검사
    if (diary.content.isEmpty && diary.diaryType == DiaryType.free) {
      throw Exception('일기 내용은 비어둘 수 없습니다.');
    }
    return repository.createDiary(diary);
  }
}

