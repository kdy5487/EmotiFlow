import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/diary_entry.dart';
import '../domain/usecases/get_diaries_usecase.dart';
import '../domain/usecases/create_diary_usecase.dart';
import '../domain/usecases/delete_diary_usecase.dart';
import '../domain/usecases/delete_diaries_usecase.dart';
import 'diary_repository_provider.dart';

/// 일기 UI 상태 관리 클래스
class DiaryState {
  final List<DiaryEntry> diaryEntries;
  final List<DiaryEntry> filteredEntries;
  final bool isLoading;
  final String? errorMessage;
  final DiaryEntry? currentEntry;

  const DiaryState({
    this.diaryEntries = const [],
    this.filteredEntries = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentEntry,
  });

  DiaryState copyWith({
    List<DiaryEntry>? diaryEntries,
    List<DiaryEntry>? filteredEntries,
    bool? isLoading,
    String? errorMessage,
    DiaryEntry? currentEntry,
  }) {
    return DiaryState(
      diaryEntries: diaryEntries ?? this.diaryEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentEntry: currentEntry ?? this.currentEntry,
    );
  }
}

/// 일기 ViewModel (상태 관리)
class DiaryProvider extends StateNotifier<DiaryState> {
  final GetDiariesUseCase _getDiariesUseCase;
  final CreateDiaryUseCase _createDiaryUseCase;
  final DeleteDiaryUseCase _deleteDiaryUseCase;
  final DeleteDiariesUseCase _deleteDiariesUseCase;
  String? _lastUserId;

  DiaryProvider({
    required GetDiariesUseCase getDiariesUseCase,
    required CreateDiaryUseCase createDiaryUseCase,
    required DeleteDiaryUseCase deleteDiaryUseCase,
    required DeleteDiariesUseCase deleteDiariesUseCase,
  }) : _getDiariesUseCase = getDiariesUseCase,
       _createDiaryUseCase = createDiaryUseCase,
       _deleteDiaryUseCase = deleteDiaryUseCase,
       _deleteDiariesUseCase = deleteDiariesUseCase,
       super(const DiaryState());

  /// 일기 목록 새로고침
  Future<void> refreshDiaryEntries(String userId) async {
    _lastUserId = userId;
    state = state.copyWith(isLoading: true);
    
    try {
      final entries = await _getDiariesUseCase.execute(userId);
      state = state.copyWith(
        diaryEntries: entries,
        filteredEntries: entries,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '데이터를 불러오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 일기 생성
  Future<void> createDiaryEntry(DiaryEntry entry) async {
    state = state.copyWith(isLoading: true);
    try {
      await _createDiaryUseCase.execute(entry);
      if (_lastUserId != null) {
        await refreshDiaryEntries(_lastUserId!);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// 일기 삭제
  Future<void> deleteDiaryEntry(String diaryId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _deleteDiaryUseCase.execute(diaryId);
      if (_lastUserId != null) {
        await refreshDiaryEntries(_lastUserId!);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// 여러 일기 삭제
  Future<void> deleteDiaryEntries(List<String> diaryIds) async {
    state = state.copyWith(isLoading: true);
    try {
      await _deleteDiariesUseCase.execute(diaryIds);
      if (_lastUserId != null) {
        await refreshDiaryEntries(_lastUserId!);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// 무한 스크롤을 위한 추가 로딩 (추후 구현)
  Future<void> loadMore() async {
    // TODO: 구현 예정
  }

  /// 검색 및 필터링
  void searchAndFilter({
    String searchQuery = '',
    Map<String, dynamic> filters = const {},
    String sortBy = 'date',
  }) {
    var entries = List<DiaryEntry>.from(state.diaryEntries);

    // 1. 검색어 필터링
    if (searchQuery.isNotEmpty) {
      entries = entries.where((e) => 
        e.title.contains(searchQuery) || e.content.contains(searchQuery)
      ).toList();
    }

    // 2. 추가 필터링 (간단 구현)
    if (filters.containsKey('diaryType')) {
      entries = entries.where((e) => e.diaryType.name == filters['diaryType']).toList();
    }
    if (filters.containsKey('emotion')) {
      entries = entries.where((e) => e.emotions.contains(filters['emotion'])).toList();
    }
    if (filters['hasMedia'] == true) {
      entries = entries.where((e) => e.mediaFiles.isNotEmpty).toList();
    }

    // 3. 정렬 (간단 구현)
    if (sortBy == 'date') {
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortBy == 'dateOldest') {
      entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (sortBy == 'title') {
      entries.sort((a, b) => a.title.compareTo(b.title));
    }

    state = state.copyWith(filteredEntries: entries);
  }

  /// 단순 검색 필터링 (하위 호환성을 위해 유지)
  void searchDiaries(String query) {
    searchAndFilter(searchQuery: query);
  }
}

/// DiaryProvider 인스턴스 (UseCase 주입)
final diaryProvider = StateNotifierProvider<DiaryProvider, DiaryState>((ref) {
  final getDiaries = ref.watch(getDiariesUseCaseProvider);
  final createDiary = ref.watch(createDiaryUseCaseProvider);
  final deleteDiary = ref.watch(deleteDiaryUseCaseProvider);
  final deleteDiaries = ref.watch(deleteDiariesUseCaseProvider);
  
  return DiaryProvider(
    getDiariesUseCase: getDiaries,
    createDiaryUseCase: createDiary,
    deleteDiaryUseCase: deleteDiary,
    deleteDiariesUseCase: deleteDiaries,
  );
});
