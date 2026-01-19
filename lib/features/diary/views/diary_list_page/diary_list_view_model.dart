import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 일기 목록의 UI 상태를 정의합니다.
class DiaryListUiState {
  final bool isGridView;
  final bool isSearchActive;
  final bool isDeleteMode;
  final Set<String> selectedEntryIds;
  final Map<String, dynamic> currentFilters;
  final String currentSortBy;

  const DiaryListUiState({
    this.isGridView = false,
    this.isSearchActive = false,
    this.isDeleteMode = false,
    this.selectedEntryIds = const {},
    this.currentFilters = const {},
    this.currentSortBy = 'date',
  });

  DiaryListUiState copyWith({
    bool? isGridView,
    bool? isSearchActive,
    bool? isDeleteMode,
    Set<String>? selectedEntryIds,
    Map<String, dynamic>? currentFilters,
    String? currentSortBy,
  }) {
    return DiaryListUiState(
      isGridView: isGridView ?? this.isGridView,
      isSearchActive: isSearchActive ?? this.isSearchActive,
      isDeleteMode: isDeleteMode ?? this.isDeleteMode,
      selectedEntryIds: selectedEntryIds ?? this.selectedEntryIds,
      currentFilters: currentFilters ?? this.currentFilters,
      currentSortBy: currentSortBy ?? this.currentSortBy,
    );
  }
}

/// 일기 목록의 UI 로직과 상태를 관리하는 ViewModel입니다.
class DiaryListViewModel extends StateNotifier<DiaryListUiState> {
  DiaryListViewModel() : super(const DiaryListUiState());

  /// 설정된 뷰 모드와 정렬 기준을 불러옵니다.
  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isGrid = prefs.getBool('diary_isGrid') ?? false;
    final sort = prefs.getString('diary_sort') ?? 'date';
    state = state.copyWith(isGridView: isGrid, currentSortBy: sort);
  }

  /// 설정을 저장합니다.
  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('diary_isGrid', state.isGridView);
    await prefs.setString('diary_sort', state.currentSortBy);
  }

  /// 그리드/리스트 뷰 모드를 전환합니다.
  void toggleViewMode() {
    state = state.copyWith(isGridView: !state.isGridView);
    _savePrefs();
  }

  /// 검색바를 토글합니다.
  void toggleSearch() =>
      state = state.copyWith(isSearchActive: !state.isSearchActive);

  /// 삭제 모드로 진입합니다.
  void enterDeleteMode() =>
      state = state.copyWith(isDeleteMode: true, selectedEntryIds: {});

  /// 삭제 모드를 종료합니다.
  void exitDeleteMode() =>
      state = state.copyWith(isDeleteMode: false, selectedEntryIds: {});

  /// 항목 선택을 토글합니다.
  void toggleSelect(String id) {
    final next = Set<String>.from(state.selectedEntryIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedEntryIds: next);
  }

  /// 선택된 모든 항목을 해제합니다.
  void clearSelection() => state = state.copyWith(selectedEntryIds: {});

  /// 필터를 설정합니다.
  void setFilters(Map<String, dynamic> filters) {
    state = state.copyWith(currentFilters: Map<String, dynamic>.from(filters));
  }

  /// 특정 필터를 제거합니다.
  void removeFilter(String key) {
    final next = Map<String, dynamic>.from(state.currentFilters)..remove(key);
    state = state.copyWith(currentFilters: next);
  }

  /// 모든 필터를 초기화합니다.
  void clearAllFilters() => state = state.copyWith(currentFilters: {});

  /// 정렬 기준을 설정합니다.
  void setSortBy(String sort) {
    state = state.copyWith(currentSortBy: sort);
    _savePrefs();
  }
}

/// DiaryListViewModel 제공자
final diaryListUiProvider =
    StateNotifierProvider<DiaryListViewModel, DiaryListUiState>((ref) {
  return DiaryListViewModel();
});
