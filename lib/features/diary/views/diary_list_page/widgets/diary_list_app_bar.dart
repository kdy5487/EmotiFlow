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

    return PopScope(
      canPop: !ui.isDeleteMode, // 삭제 모드에서는 뒤로가기 차단
      onPopInvoked: (didPop) {
        if (!didPop && ui.isDeleteMode) {
          uiNotifier.exitDeleteMode(); // 삭제 모드 해제
        }
      },
      child: AppBar(
        leading: ui.isDeleteMode
            ? IconButton(
                onPressed: uiNotifier.exitDeleteMode,
                icon: const Icon(Icons.arrow_back),
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
                // 삭제 모드: 작은 삭제 버튼 (우측 하단)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed:
                        ui.selectedEntryIds.isEmpty ? null : onConfirmDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: ui.selectedEntryIds.isEmpty
                          ? Colors.grey[400]
                          : const Color(0xFFDC2626), // 빨간색
                      size: 22,
                    ),
                    tooltip: '선택 삭제',
                  ),
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
                // 설정 메뉴 (삭제 모드만 포함)
                PopupMenuButton<String>(
                  key: ValueKey(ui.isDeleteMode), // 상태 변경 시 메뉴 닫기
                  onSelected: (value) {
                    if (value == 'delete_mode') {
                      uiNotifier.enterDeleteMode();
                    }
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete_mode',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: const Color(0xFFDC2626), // 빨간색
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '삭제 모드',
                            style: TextStyle(color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  tooltip: '설정',
                ),
              ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
