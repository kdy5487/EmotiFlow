import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_typography.dart';
import '../../providers/diary_provider.dart';
import '../../domain/entities/diary_entry.dart';
import 'diary_list_view_model.dart';

import 'widgets/diary_search_section.dart';
import 'widgets/diary_filter_tags_bar.dart';
import 'widgets/filter_dialog.dart';
import 'widgets/diary_grid_card.dart';
import 'widgets/diary_empty_state.dart';
import 'widgets/diary_error_state.dart';
import 'widgets/diary_fab.dart';
import 'widgets/diary_list_card.dart';
import 'widgets/diary_list_app_bar.dart';
import 'widgets/write_options_dialog.dart';

/// 일기 목록 페이지
class DiaryListPage extends ConsumerStatefulWidget {
  const DiaryListPage({super.key});

  @override
  ConsumerState<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends ConsumerState<DiaryListPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(diaryListUiProvider.notifier).loadPrefs();
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        ref
            .read(diaryProvider.notifier)
            .refreshDiaryEntries(authState.user!.uid);
      }
      _applySearchAndFilter();
    });

    _listScrollController.addListener(() {
      final position = _listScrollController.position;
      if (position.pixels > position.maxScrollExtent - 300) {
        ref.read(diaryProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryProvider);
    final ui = ref.watch(diaryListUiProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DiaryListAppBar(
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onApplySearch: _applySearchAndFilter,
        onShowFilter: _showFilterDialog,
        onShowSort: _showSortDialog,
        onConfirmDelete: _confirmAndDeleteSelected,
      ),
      body: Column(
        children: [
          if (ui.isSearchActive)
            DiarySearchSection(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (_) => _applySearchAndFilter(),
              onClear: () {
                _searchController.clear();
                _applySearchAndFilter();
              },
            ),
          if (ui.currentFilters.isNotEmpty)
            DiaryFilterTagsBar(
              currentFilters: ui.currentFilters,
              onRemoveFilter: (key) {
                ref.read(diaryListUiProvider.notifier).removeFilter(key);
                _applySearchAndFilter();
              },
              onClearAll: () {
                ref.read(diaryListUiProvider.notifier).clearAllFilters();
                _applySearchAndFilter();
              },
              getFilterLabel: _getFilterLabel,
            ),
          // 정렬 및 그리드/일반 보기 버튼 (앱바 아래)
          if (!ui.isDeleteMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 정렬 버튼 (왼쪽)
                  IconButton(
                    onPressed: _showSortDialog,
                    icon: const Icon(Icons.sort),
                    tooltip: '정렬',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  // 그리드/일반 보기 버튼 (오른쪽)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 일반 보기 (왼쪽)
                        _buildViewModeButton(
                          context,
                          icon: Icons.view_list,
                          isSelected: !ui.isGridView,
                          onTap: () {
                            if (ui.isGridView) {
                              ref
                                  .read(diaryListUiProvider.notifier)
                                  .toggleViewMode();
                            }
                          },
                        ),
                        // 그리드 보기 (오른쪽)
                        _buildViewModeButton(
                          context,
                          icon: Icons.grid_view,
                          isSelected: ui.isGridView,
                          onTap: () {
                            if (!ui.isGridView) {
                              ref
                                  .read(diaryListUiProvider.notifier)
                                  .toggleViewMode();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ui.isGridView
                ? _buildDiaryGrid(diaryState)
                : _buildDiaryList(diaryState),
          ),
        ],
      ),
      floatingActionButton:
          DiaryFAB(onPressed: () => _showWriteOptionsDialog(context)),
    );
  }

  /// 그리드뷰 빌더
  Widget _buildDiaryGrid(DiaryState diaryState) {
    if (diaryState.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (diaryState.errorMessage != null)
      return DiaryErrorState(message: diaryState.errorMessage!);

    final entries = diaryState.filteredEntries;
    if (entries.isEmpty)
      return DiaryEmptyState(
          onPrimaryAction: () => _showWriteOptionsDialog(context));

    final ui = ref.watch(diaryListUiProvider);

    return GridView.builder(
      controller: _listScrollController,
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65, // 세로 크기 더 줄임
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return DiaryGridCard(
          entry: entry,
          isSelected: ui.selectedEntryIds.contains(entry.id),
          isDeleteMode: ui.isDeleteMode,
          onTap: () => ui.isDeleteMode
              ? _toggleSelect(entry.id)
              : _navigateToDetail(entry),
          onLongPress: () {
            if (!ui.isDeleteMode) {
              ref.read(diaryListUiProvider.notifier).enterDeleteMode();
              _toggleSelect(entry.id);
            }
          },
          onToggleSelect: () => _toggleSelect(entry.id),
          formatDate: _formatDate,
          formatTime: _formatTime,
        );
      },
    );
  }

  /// 리스트뷰 빌더
  Widget _buildDiaryList(DiaryState diaryState) {
    if (diaryState.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (diaryState.errorMessage != null)
      return DiaryErrorState(message: diaryState.errorMessage!);

    final entries = diaryState.filteredEntries;
    if (entries.isEmpty)
      return DiaryEmptyState(
          onPrimaryAction: () => _showWriteOptionsDialog(context));

    final ui = ref.watch(diaryListUiProvider);

    return ListView.builder(
      controller: _listScrollController,
      padding: const EdgeInsets.all(20),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return DiaryListCard(
          entry: entry,
          isSelected: ui.selectedEntryIds.contains(entry.id),
          isDeleteMode: ui.isDeleteMode,
          onTap: () => ui.isDeleteMode
              ? _toggleSelect(entry.id)
              : _navigateToDetail(entry),
          onLongPress: () {
            if (!ui.isDeleteMode) {
              ref.read(diaryListUiProvider.notifier).enterDeleteMode();
              _toggleSelect(entry.id);
            }
          },
          formatDate: _formatDate,
          formatTime: _formatTime,
        );
      },
    );
  }

  void _applySearchAndFilter() {
    final ui = ref.read(diaryListUiProvider);
    ref.read(diaryProvider.notifier).searchAndFilter(
          searchQuery: _searchController.text.trim(),
          filters: ui.currentFilters,
          sortBy: ui.currentSortBy,
        );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        currentFilters: ref.read(diaryListUiProvider).currentFilters,
        onFiltersChanged: (filters) {
          ref.read(diaryListUiProvider.notifier).setFilters(filters);
          _applySearchAndFilter();
        },
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sort, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('정렬 기준', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOptionDialog(
                title: '최신순',
                subtitle: '최근 작성된 순서대로',
                value: 'date',
                icon: Icons.schedule),
            _buildSortOptionDialog(
                title: '오래된순',
                subtitle: '오래된 순서대로',
                value: 'dateOldest',
                icon: Icons.history),
            _buildSortOptionDialog(
                title: '감정순',
                subtitle: '감정 강도 순서대로',
                value: 'emotion',
                icon: Icons.emoji_emotions),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기')),
        ],
      ),
    );
  }

  Widget _buildSortOptionDialog(
      {required String title,
      required String subtitle,
      required String value,
      required IconData icon}) {
    final ui = ref.watch(diaryListUiProvider);
    final isSelected = ui.currentSortBy == value;
    return ListTile(
      leading:
          Icon(icon, color: isSelected ? AppTheme.primary : Colors.grey[600]),
      title: Text(title,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.primary : AppTheme.textPrimary)),
      subtitle: Text(subtitle,
          style:
              AppTypography.bodySmall.copyWith(color: AppTheme.textSecondary)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.primary)
          : null,
      onTap: () {
        ref.read(diaryListUiProvider.notifier).setSortBy(value);
        _applySearchAndFilter();
        Navigator.of(context).pop();
      },
    );
  }

  void _toggleSelect(String entryId) =>
      ref.read(diaryListUiProvider.notifier).toggleSelect(entryId);

  Future<void> _confirmAndDeleteSelected() async {
    final ui = ref.read(diaryListUiProvider);
    final toDelete = ui.selectedEntryIds.toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('선택 삭제'),
        content: Text('${toDelete.length}개의 일기를 삭제하시겠어요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(diaryProvider.notifier).deleteDiaryEntries(toDelete);
      ref.read(diaryListUiProvider.notifier).exitDeleteMode();
    }
  }

  void _showWriteOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const WriteOptionsDialog(),
    );
  }

  void _navigateToDetail(DiaryEntry entry) =>
      context.push('/diaries/${entry.id}');

  String _getFilterLabel(String key, dynamic value) {
    switch (key) {
      case 'diaryType':
        return value == 'free' ? '자유' : 'AI';
      case 'emotion':
        return value;
      case 'hasMedia':
        return '미디어 있음';
      default:
        return value.toString();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day)
      return '오늘';
    return '${date.month}월 ${date.day}일';
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  /// 뷰 모드 버튼 빌더
  Widget _buildViewModeButton(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}
