import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class DiaryListUiNotifier extends StateNotifier<DiaryListUiState> {
  DiaryListUiNotifier() : super(const DiaryListUiState());

  void toggleViewMode() => state = state.copyWith(isGridView: !state.isGridView);
  void toggleSearch() => state = state.copyWith(isSearchActive: !state.isSearchActive);
  void enterDeleteMode() => state = state.copyWith(isDeleteMode: true, selectedEntryIds: {});
  void exitDeleteMode() => state = state.copyWith(isDeleteMode: false, selectedEntryIds: {});

  void toggleSelect(String id) {
    final next = Set<String>.from(state.selectedEntryIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedEntryIds: next);
  }

  void clearSelection() => state = state.copyWith(selectedEntryIds: {});

  void setFilter(String key, dynamic value) {
    final next = Map<String, dynamic>.from(state.currentFilters);
    next[key] = value;
    state = state.copyWith(currentFilters: next);
  }

  void removeFilter(String key) {
    final next = Map<String, dynamic>.from(state.currentFilters)..remove(key);
    state = state.copyWith(currentFilters: next);
  }

  void clearAllFilters() => state = state.copyWith(currentFilters: {});
  void setSortBy(String sort) => state = state.copyWith(currentSortBy: sort);

  void setFilters(Map<String, dynamic> filters) {
    state = state.copyWith(currentFilters: Map<String, dynamic>.from(filters));
  }
}

final diaryListUiProvider = StateNotifierProvider<DiaryListUiNotifier, DiaryListUiState>((ref) {
  return DiaryListUiNotifier();
});


