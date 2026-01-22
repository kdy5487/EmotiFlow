import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../diary_list_view_model.dart';

class DiaryListAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onApplySearch;
  final VoidCallback onShowFilter;
  final VoidCallback onShowSort;
  final VoidCallback onConfirmDelete;

  const DiaryListAppBar({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onApplySearch,
    required this.onShowFilter,
    required this.onShowSort,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(diaryListUiProvider);
    final uiNotifier = ref.read(diaryListUiProvider.notifier);

    final theme = Theme.of(context);

    return AppBar(
      leading: ui.isDeleteMode
          ? IconButton(
              onPressed: uiNotifier.exitDeleteMode,
              icon: const Icon(Icons.close),
              tooltip: '삭제 모드 종료',
              color: theme.colorScheme.onSurface,
            )
          : null,
      title: Text(
        ui.isDeleteMode ? '${ui.selectedEntryIds.length}개 선택' : '일기 목록',
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
      ),
      actions: ui.isDeleteMode
          ? [
              IconButton(
                onPressed: ui.selectedEntryIds.isEmpty ? null : onConfirmDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: '선택 삭제',
              ),
            ]
          : [
              IconButton(
                onPressed: () {
                  uiNotifier.toggleSearch();
                  if (!ui.isSearchActive) {
                    searchController.clear();
                    onApplySearch();
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      searchFocusNode.requestFocus();
                    });
                  }
                },
                icon: Icon(
                  ui.isSearchActive ? Icons.close : Icons.search,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: ui.isSearchActive ? '검색 닫기' : '검색',
              ),
              IconButton(
                onPressed: uiNotifier.toggleViewMode,
                icon: Icon(
                  ui.isGridView ? Icons.view_list : Icons.grid_view,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: ui.isGridView ? '리스트뷰로 전환' : '그리드뷰로 전환',
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'filter':
                        onShowFilter();
                        break;
                      case 'sort':
                        onShowSort();
                        break;
                      case 'delete_mode':
                        uiNotifier.enterDeleteMode();
                        break;
                    }
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'filter',
                      child: Row(
                        children: [
                          Icon(Icons.filter_list, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('필터'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'sort',
                      child: Row(
                        children: [
                          Icon(Icons.sort, size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('정렬'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete_mode',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('삭제 모드', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  tooltip: '설정',
                ),
              ),
            ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
