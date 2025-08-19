import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/diary_provider.dart';
import '../providers/firestore_provider.dart';
import '../models/diary_entry.dart';
import '../models/emotion.dart';
import '../../../shared/widgets/cards/emoti_card.dart';
import '../../../shared/widgets/inputs/emoti_text_field.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import 'widgets/delete_selection_sheet.dart';


/// 일기 목록 페이지
class DiaryListPage extends ConsumerStatefulWidget {
  const DiaryListPage({super.key});

  @override
  ConsumerState<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends ConsumerState<DiaryListPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  
  // String _currentSearchQuery = ''; // 검색 기능에서 _searchController.text를 직접 사용
  Map<String, dynamic> _currentFilters = {};
  String _currentSortBy = 'date'; // date, emotion, moodType
  bool _isGridView = false; // 그리드뷰 전환 상태
  bool _isSearchActive = false; // 검색 활성화 상태
  bool _isDeleteMode = false; // 삭제 선택 모드
  final Set<String> _selectedEntryIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryProvider);
    final diaryNotifier = ref.read(diaryProvider.notifier);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: _isDeleteMode
            ? IconButton(
                onPressed: _exitDeleteMode,
                icon: const Icon(Icons.close),
                tooltip: '삭제 모드 종료',
              )
            : null,
        title: _isDeleteMode
            ? Text(
                '${_selectedEntryIds.length}개 선택',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            : const Text(
                '일기 목록',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _isDeleteMode
            ? [
                IconButton(
                  onPressed: _selectedEntryIds.isEmpty ? null : _confirmAndDeleteSelected,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '선택 삭제',
                ),
              ]
            : [
          // 검색 버튼
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearchActive ? Icons.close : Icons.search,
            ),
            tooltip: _isSearchActive ? '검색 닫기' : '검색',
          ),
          // 그리드뷰/리스트뷰 전환 버튼
          IconButton(
            onPressed: _toggleViewMode,
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
            ),
            tooltip: _isGridView ? '리스트뷰로 전환' : '그리드뷰로 전환',
          ),
          // 설정 메뉴 버튼 (필터/정렬/삭제 모드 진입 분리)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              icon: Stack(
                children: [
                  const Icon(Icons.more_vert),
                  if (_currentFilters.isNotEmpty || _currentSortBy != 'date')
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${_getActiveSettingsCount()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'filter',
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 20),
                      SizedBox(width: 8),
                      Text('필터'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sort',
                  child: Row(
                    children: [
                      Icon(Icons.sort, size: 20),
                      SizedBox(width: 8),
                      Text('정렬'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete_mode',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
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
      ),
      body: Column(
        children: [
          // 검색 섹션 (검색이 활성화되었을 때만 표시)
          if (_isSearchActive)
            _buildSearchSection(),
          
          // 필터 태그 표시
          if (_currentFilters.isNotEmpty) _buildFilterTags(diaryNotifier),
          
          // 일기 목록
          Expanded(
            child: _isGridView 
                ? _buildDiaryGridFromStream()
                : _buildDiaryList(diaryState, diaryNotifier),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 활성 설정 개수 계산
  int _getActiveSettingsCount() {
    int count = 0;
    if (_currentFilters.isNotEmpty) count++;
    if (_currentSortBy != 'date') count++;
    return count;
  }

  /// 통합 필터 및 정렬 설정 다이얼로그
  void _showFilterAndSortSettings() {
    showDialog(
      context: context,
      builder: (context) => _buildFilterAndSortDialog(),
    );
  }

  /// 그리드뷰 빌더
  Widget _buildDiaryGrid(DiaryState diaryState, DiaryProvider diaryNotifier) {
    if (diaryState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (diaryState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              diaryState.errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final entries = diaryState.filteredEntries.isNotEmpty 
        ? diaryState.filteredEntries 
        : diaryState.diaryEntries;
        
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '아직 작성된 일기가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 일기를 작성해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _buildDiaryGridCard(entries[index], index);
      },
    );
  }

  /// Firestore Stream을 사용하는 그리드뷰 (DB 데이터 기반)
  Widget _buildDiaryGridFromStream() {
    final authState = ref.read(authProvider);
    final userId = authState.user?.uid ?? 'demo_user';

    return Consumer(
      builder: (context, ref, child) {
        final diariesAsync = ref.watch(diariesStreamProvider(userId));

        return diariesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 12),
                Text('그리드 데이터를 불러오는 중 오류가 발생했습니다',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          data: (snapshot) {
            if (snapshot.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('아직 작성된 일기가 없습니다',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              );
            }

            final docs = snapshot.docs;
            final entries = <DiaryEntry>[];
            for (final doc in docs) {
              try {
                entries.add(DiaryEntry.fromFirestore(doc));
              } catch (_) {}
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) => _buildDiaryGridCard(entries[index], index),
            );
          },
        );
      },
    );
  }

  /// 그리드뷰용 일기 카드 (사진 없는 버전, 가독성 중심)
  Widget _buildDiaryGridCard(DiaryEntry entry, int index) {
    final bool isSelected = _selectedEntryIds.contains(entry.id);
    return InkWell(
      onTap: () {
        if (_isDeleteMode) {
          _toggleSelect(entry.id);
        } else {
          _navigateToDetail(entry);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (날짜, 감정)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(entry.createdAt),
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          _formatTime(entry.createdAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 감정 표시 (첫 번째만)
                  if (entry.emotions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Emotion.findByName(entry.emotions.first)?.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Emotion.findByName(entry.emotions.first)?.emoji ?? '😊',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 제목
              if (entry.title.isNotEmpty) ...[
                Text(
                  entry.title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
              ],
              
              // 내용
              Expanded(
                child: Text(
                  entry.content,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 하단 정보
              Row(
                children: [
                  // 태그 (첫 번째만)
                  if (entry.tags.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.tags.first,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  
                  const SizedBox(width: 8),
                  
                  // 미디어 개수
                  if (entry.mediaCount > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 2),
                        Text(
                          '${entry.mediaCount}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(width: 4),
                  
                  // 일기 종류
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: entry.diaryType == DiaryType.aiChat 
                          ? AppColors.secondary.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      entry.diaryType == DiaryType.aiChat ? 'AI' : '자유',
                      style: TextStyle(
                        color: entry.diaryType == DiaryType.aiChat 
                            ? AppColors.secondary
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
            ),
            if (_isDeleteMode)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleSelect(entry.id),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: isSelected ? Colors.red : Colors.white,
                    foregroundColor: isSelected ? Colors.white : Colors.grey[600],
                    child: Icon(
                      isSelected ? Icons.check : Icons.radio_button_unchecked,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 일기 삭제 다이얼로그
  void _showDeleteEntriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('일기 삭제'),
          ],
        ),
        content: const Text(
          '삭제할 일기를 선택하세요.\n삭제된 일기는 복구할 수 없습니다.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteSelectionView();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('선택하기'),
          ),
        ],
      ),
    );
  }

  /// 삭제할 일기 선택 뷰
  void _showDeleteSelectionView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DeleteSelectionSheet(
          scrollController: scrollController,
          onDeleteSelected: (selectedEntries) {
            _deleteSelectedEntries(selectedEntries);
          },
        ),
      ),
    );
  }

  /// 선택된 일기들 삭제
  void _deleteSelectedEntries(List<DiaryEntry> selectedEntries) async {
    try {
      final diaryNotifier = ref.read(diaryProvider.notifier);
      
      // 각 일기를 개별적으로 삭제
      for (final entry in selectedEntries) {
        await diaryNotifier.deleteDiaryEntry(entry.id);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedEntries.length}개의 일기가 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 통합 필터 및 정렬 다이얼로그 UI
  Widget _buildFilterAndSortDialog() {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.tune, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('필터 및 정렬 설정'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                tabs: [
                  Tab(text: '필터'),
                  Tab(text: '정렬'),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _buildFilterTab(),
                    _buildSortTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _resetAllSettings(),
          child: const Text('초기화'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            _applyAllSettings();
            Navigator.of(context).pop();
          },
          child: const Text('적용'),
        ),
      ],
    );
  }

  /// 필터 탭 UI
  Widget _buildFilterTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 일기 종류 필터
          _buildFilterSection(
            title: '일기 종류',
            children: [
              _buildFilterChip(
                label: '자유 일기',
                value: 'diaryType',
                filterValue: DiaryType.free.name,
                icon: Icon(Icons.edit),
              ),
              _buildFilterChip(
                label: 'AI 채팅 일기',
                value: 'diaryType',
                filterValue: DiaryType.aiChat.name,
                icon: Icon(Icons.chat),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 감정 필터
          _buildFilterSection(
            title: '감정',
            children: Emotion.basicEmotions.map((emotion) => 
              _buildFilterChip(
                label: emotion.name,
                value: 'emotion',
                filterValue: emotion.name,
                icon: Text(emotion.emoji, style: const TextStyle(fontSize: 16)),
              ),
            ).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // 미디어 필터
          _buildFilterSection(
            title: '미디어',
            children: [
              _buildFilterChip(
                label: '사진/그림 있음',
                value: 'hasMedia',
                filterValue: 'true',
                icon: Icon(Icons.image),
              ),
              _buildFilterChip(
                label: 'AI 생성 이미지',
                value: 'hasAIImage',
                filterValue: 'true',
                icon: Icon(Icons.auto_awesome),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 날짜 범위 필터
          _buildFilterSection(
            title: '날짜 범위',
            children: [
              _buildFilterChip(
                label: '최근 7일',
                value: 'dateRange',
                filterValue: '7days',
                icon: Icon(Icons.calendar_today),
              ),
              _buildFilterChip(
                label: '최근 30일',
                value: 'dateRange',
                filterValue: '30days',
                icon: Icon(Icons.calendar_month),
              ),
              _buildFilterChip(
                label: '이번 달',
                value: 'dateRange',
                filterValue: 'thisMonth',
                icon: Icon(Icons.calendar_view_month),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 정렬 탭 UI
  Widget _buildSortTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSortOption(
            title: '최신순 (기본)',
            subtitle: '작성일 기준 최신순',
            value: 'date',
            icon: Icons.access_time,
          ),
          _buildSortOption(
            title: '오래된순',
            subtitle: '작성일 기준 오래된순',
            value: 'date_old',
            icon: Icons.history,
          ),
          _buildSortOption(
            title: '제목순',
            subtitle: '제목 알파벳순',
            value: 'title',
            icon: Icons.sort_by_alpha,
          ),
          _buildSortOption(
            title: '감정 개수순',
            subtitle: '감정 개수 많은순',
            value: 'emotionCount',
            icon: Icons.emoji_emotions,
          ),
          _buildSortOption(
            title: '미디어 개수순',
            subtitle: '미디어 개수 많은순',
            value: 'mediaCount',
            icon: Icons.image,
          ),
        ],
      ),
    );
  }

  /// 필터 섹션 UI
  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }

  /// 필터 칩 UI
  Widget _buildFilterChip({
    required String label,
    required String value,
    required String filterValue,
    required Widget icon,
  }) {
    final isSelected = _currentFilters[value] == filterValue;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _currentFilters[value] = filterValue;
          } else {
            _currentFilters.remove(value);
          }
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  /// 정렬 옵션 UI
  Widget _buildSortOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _currentSortBy == value;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          _currentSortBy = value;
        });
      },
    );
  }

  /// 모든 설정 초기화
  void _resetAllSettings() {
    setState(() {
      _currentFilters.clear();
      _currentSortBy = 'date';
    });
  }

  /// 모든 설정 적용
  void _applyAllSettings() {
    _applySearchAndFilter(ref.read(diaryProvider.notifier));
  }

  /// 검색 토글
  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _applySearchAndFilter(ref.read(diaryProvider.notifier));
      } else {
        // 검색이 활성화되면 포커스 요청
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  /// 뷰 모드 토글 (리스트뷰 ↔ 그리드뷰)
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  /// 메뉴 선택 핸들러
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'filter':
        _showFilterDialog();
        break;
      case 'sort':
        _showSortDialog();
        break;
      case 'delete_mode':
        _enterDeleteMode();
        break;
    }
  }

  /// 플로팅 액션 버튼
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showWriteOptionsDialog(context),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add),
    );
  }

  /// 검색 섹션
  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: EmotiTextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hintText: '제목, 내용, 태그로 검색...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _applySearchAndFilter(ref.read(diaryProvider.notifier));
                },
              )
            : null,
        onChanged: (value) {
          _applySearchAndFilter(ref.read(diaryProvider.notifier));
        },
        onSubmitted: (value) {
          _applySearchAndFilter(ref.read(diaryProvider.notifier));
        },
      ),
    );
  }

  /// 검색 및 필터 섹션 (기존)
  Widget _buildSearchAndFilterSection(DiaryProvider diaryNotifier) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 검색 입력 필드
          EmotiTextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            hintText: '제목, 내용, 태그로 검색...',
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _applySearchAndFilter(diaryNotifier);
                    },
                  )
                : null,
            onChanged: (value) {
              _applySearchAndFilter(diaryNotifier);
            },
            onSubmitted: (value) {
              _searchFocusNode.unfocus();
              _applySearchAndFilter(diaryNotifier);
            },
          ),
          
          // 검색 힌트
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '제목, 내용, 태그에서 "${_searchController.text}"를 검색합니다',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          
          // 빠른 필터 버튼들
          if (_searchController.text.isNotEmpty || _currentFilters.isNotEmpty) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickFilterChip('전체', null, diaryNotifier),
                  _buildQuickFilterChip('자유 일기', DiaryType.free.name, diaryNotifier, filterKey: 'diaryType'),
                  _buildQuickFilterChip('AI 채팅', DiaryType.aiChat.name, diaryNotifier, filterKey: 'diaryType'),
                  _buildQuickFilterChip('미디어 있음', true, diaryNotifier, filterKey: 'hasMedia'),
                  _buildQuickFilterChip('AI 이미지', true, diaryNotifier, filterKey: 'hasAIImage'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 빠른 필터 칩
  Widget _buildQuickFilterChip(String label, dynamic value, DiaryProvider diaryNotifier, {String? filterKey}) {
    final key = filterKey ?? 'moodType';
    final isSelected = _currentFilters[key] == value;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _currentFilters[key] = value;
          } else {
            _currentFilters.remove(key);
          }
          _applySearchAndFilter(diaryNotifier);
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// 필터 태그 표시
  Widget _buildFilterTags(DiaryProvider diaryNotifier) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _currentFilters.entries.map((entry) {
                return Chip(
                  label: Text(
                    _getFilterLabel(entry.key, entry.value),
                    style: const TextStyle(fontSize: 11),
                  ),
                  onDeleted: () {
                    _currentFilters.remove(entry.key);
                    _applySearchAndFilter(diaryNotifier);
                  },
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentFilters.clear();
              });
              _applySearchAndFilter(diaryNotifier);
            },
            child: Text(
              '모두 지우기',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 라벨 생성
  String _getFilterLabel(String key, dynamic value) {
    switch (key) {
      case 'moodType':
        return value == 'positive' ? '긍정' : '부정';
      case 'hasAIAnalysis':
        return value == true ? 'AI 분석' : 'AI 분석 없음';
      case 'hasMedia':
        return value == true ? '미디어 있음' : '미디어 없음';
      case 'emotion':
        return value;
      default:
        return value.toString();
    }
  }

  /// 일기 목록 (Riverpod StreamProvider 사용)
  Widget _buildDiaryList(DiaryState diaryState, DiaryProvider diaryNotifier) {
    print('=== 일기 목록 빌드 ===');
    
    final authState = ref.read(authProvider);
    final userId = authState.user?.uid ?? 'demo_user';
    
    // Riverpod StreamProvider 사용
    return Consumer(
      builder: (context, ref, child) {
        final diariesAsync = ref.watch(diariesStreamProvider(userId));
        
        return diariesAsync.when(
          // 로딩 중
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('일기 목록을 불러오는 중...'),
              ],
            ),
          ),
          
          // 오류 발생 시
          error: (error, stackTrace) {
            print('❌ StreamProvider 오류: $error');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    "데이터를 불러오는 중 오류가 발생했습니다",
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "잠시 후 다시 시도해주세요",
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // 페이지 새로고침
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          },
          
          // 데이터 표시
          data: (snapshot) {
            if (snapshot.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      '아직 작성된 일기가 없습니다',
                      style: AppTypography.titleLarge.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '첫 번째 일기를 작성해보세요',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _showWriteOptionsDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('일기 작성하기'),
                    ),
                  ],
                ),
              );
            }
            
            // 실제 Firestore 데이터 표시
            final docs = snapshot.docs;
            print('✅ StreamProvider에서 ${docs.length}개 문서 가져옴');
            
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                
                // Firestore 데이터를 DiaryEntry로 변환
                try {
                  final entry = DiaryEntry.fromFirestore(doc);
                  return _buildDiaryCard(entry, index);
                } catch (e) {
                  print('문서 변환 실패: $e, 문서 ID: ${doc.id}');
                  // 변환 실패 시 간단한 에러 카드 표시
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: EmotiCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '데이터 변환 실패',
                                    style: AppTypography.titleLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '오류',
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.red[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '문서 ID: ${doc.id}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.grey[600],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  /// 일기 카드 (가로형 레이아웃)
  Widget _buildDiaryCard(DiaryEntry entry, int index) {
    final bool isSelected = _selectedEntryIds.contains(entry.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 1), // 카드 간격 더 줄임 (2 → 1)
      child: EmotiCard(
        child: InkWell(
          onTap: () {
            if (_isDeleteMode) {
              _toggleSelect(entry.id);
            } else {
              _navigateToDetail(entry);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
            padding: const EdgeInsets.all(8), // 패딩 적당히 조정 (2 → 8)
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 좌측: 내용 영역
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더 (날짜, 감정)
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _formatDate(entry.createdAt),
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildEmotionIndicator(entry),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatTime(entry.createdAt),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6), // 간격 조정 (4 → 6)
                      
                      // 제목
                      if (entry.title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, right: 8), // 오른쪽 여백 추가로 이미지와 겹치지 않게
                          child: Text(
                            entry.title,
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      // 내용 (더 많은 줄 표시)
                      Padding(
                        padding: const EdgeInsets.only(right: 8), // 오른쪽 여백 추가로 이미지와 겹치지 않게
                        child: Text(
                          entry.content,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 8), // 하단 정보와 간격 넓힘 (4 → 8)
                      
                      // 하단 정보 (태그, 미디어, AI 분석)
                      Padding(
                        padding: const EdgeInsets.only(right: 8), // 오른쪽 여백 추가로 이미지와 겹치지 않게
                        child: Row(
                          children: [
                            // 태그
                            if (entry.tags.isNotEmpty) ...[
                              Icon(Icons.label, size: 10, color: Colors.grey[600]),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  entry.tags.take(2).join(', '),
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 9,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          
                          const Spacer(),
                          
                          // 미디어 개수
                          if (entry.mediaCount > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image, size: 10, color: Colors.grey[600]), // 아이콘 크기 더 축소 (12 → 10)
                                const SizedBox(width: 2), // 간격 더 축소 (3 → 2)
                                Text(
                                  '${entry.mediaCount}',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 9, // 글자 크기 더 축소 (10 → 9)
                                  ),
                                ),
                              ],
                            ),
                          
                          const SizedBox(width: 6), // 간격 더 축소 (8 → 6)
                          
                          // AI 분석 완료 여부
                          if (entry.hasAIAnalysis)
                            Icon(
                              Icons.psychology,
                              size: 10, // 아이콘 크기 더 축소 (12 → 10)
                              color: AppColors.primary,
                            ),
                          
                          const SizedBox(width: 4), // 간격 더 축소 (6 → 4)
                          
                          // 일기 종류 표시
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // 패딩 더 축소 (5x1 → 4x1)
                            decoration: BoxDecoration(
                              color: entry.diaryType == DiaryType.aiChat 
                                  ? AppColors.secondary.withOpacity(0.2)
                                  : AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5), // 반지름 더 축소 (6 → 5)
                              border: Border.all(
                                color: entry.diaryType == DiaryType.aiChat 
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              entry.diaryType == DiaryType.aiChat ? 'AI' : '자유',
                              style: AppTypography.caption.copyWith(
                                color: entry.diaryType == DiaryType.aiChat 
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 8, // 글자 크기 더 축소 (9 → 8)
                              ),
                            ),
                          ),
                        ],
                      ),)
                    ],
                  ),
                ),
                
                const SizedBox(width: 8), // 간격 더 축소 (10 → 8)
                
                // 우측: 이미지 영역 (크기 더 확대)
                if (entry.mediaCount > 0 || (entry.diaryType == DiaryType.aiChat && entry.metadata?['aiGeneratedImage'] != null))
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 140, // 높이 더 확대 (140 → 160)
                        width: 120, // 너비 축소 (160 → 120)로 flex 1.5 효과
                        color: Colors.grey[200],
                        child: _buildCardPreviewImage(entry),
                      ),
                    ),
                  ),
              ],
            ),
          ),
              if (_isDeleteMode)
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _toggleSelect(entry.id),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: isSelected ? Colors.red : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Colors.grey[600],
                      child: Icon(
                        isSelected ? Icons.check : Icons.radio_button_unchecked,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 감정 표시기 (3개 감정 작게 표시, 이모지만 표시, 툴팁 추가)
  Widget _buildEmotionIndicator(DiaryEntry entry) {
    if (entry.emotions.isEmpty) return const SizedBox.shrink();
    
    // 최대 3개 감정만 표시
    final emotionsToShow = entry.emotions.take(3).toList();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: emotionsToShow.map((emotionName) {
        final emotionModel = Emotion.findByName(emotionName);
        if (emotionModel == null) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.only(left: 2), // 간격 더 축소 (3 → 2)
          child: Tooltip(
            message: emotionModel.name,
            child: Container(
              width: 24, // 크기 더 축소 (28 → 24)
              height: 24, // 크기 더 축소 (28 → 24)
              decoration: BoxDecoration(
                color: emotionModel.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12), // 반지름 더 축소 (14 → 12)
                border: Border.all(color: emotionModel.color.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  emotionModel.emoji,
                  style: const TextStyle(fontSize: 14), // 글자 크기 더 축소 (16 → 14)
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 목록 카드용 프리뷰 이미지 (Firebase Storage 최적화)
  Widget _buildCardPreviewImage(DiaryEntry entry) {
    // AI 생성 이미지 우선 표시
    if (entry.diaryType == DiaryType.aiChat && entry.metadata?['aiGeneratedImage'] != null) {
      final aiImageUrl = entry.metadata!['aiGeneratedImage'] as String;
      if (aiImageUrl.isNotEmpty) {
        return _buildOptimizedImage(aiImageUrl);
      }
    }
    
    // 일반 미디어 파일 표시
    if (entry.mediaFiles.isNotEmpty) {
      final url = entry.mediaFiles.first.url;
      return _buildOptimizedImage(url);
    }
    
    // 기본 이미지 아이콘
    return const Icon(Icons.image, color: Colors.grey);
  }

  /// 최적화된 이미지 위젯 (Firebase Storage + 캐싱 + 메모리 관리)
  Widget _buildOptimizedImage(String url) {
    if (url.startsWith('http')) {
      // Firebase Storage URL인지 확인
      final isFirebaseStorage = url.contains('firebasestorage.googleapis.com');
      
      if (isFirebaseStorage) {
        // Firebase Storage 이미지 최적화
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain, // 전체 이미지가 보이도록 변경
          width: 120,
          height: 140,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              value: null,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.grey),
          // Firebase Storage 최적화
          memCacheWidth: 160,
          memCacheHeight: 160,
          // 빠른 로딩을 위한 설정
          fadeInDuration: const Duration(milliseconds: 150), // 페이드인 시간 단축
          fadeOutDuration: const Duration(milliseconds: 150),
          // Firebase Storage 특화 최적화
          httpHeaders: const {
            'Cache-Control': 'max-age=86400', // 24시간 캐시
          },
        );
      } else {
        // 일반 네트워크 이미지
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          width: 160,
          height: 160,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              value: null,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.grey),
          memCacheWidth: 160,
          memCacheHeight: 160,
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 200),
        );
      }
    }
    
    if (url.startsWith('/') || url.startsWith('file:')) {
      return Image.file(
        File(url),
        fit: BoxFit.contain,
        width: 160,
        height: 160,
        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
        cacheWidth: 160,
        cacheHeight: 160,
        filterQuality: FilterQuality.medium,
        repeat: ImageRepeat.noRepeat,
        alignment: Alignment.center,
      );
    }
    
    return Image.asset(
      url,
      fit: BoxFit.contain,
      width: 160,
      height: 160,
      errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
    );
  }

  /// 검색 및 필터 적용
  void _applySearchAndFilter(DiaryProvider diaryNotifier) {
    // 검색어와 필터를 적용하여 일기 목록 업데이트
    final searchQuery = _searchController.text.trim();
    final filters = Map<String, dynamic>.from(_currentFilters);
    
    // 검색어가 있으면 필터에 추가
    if (searchQuery.isNotEmpty) {
      filters['search'] = searchQuery;
    }
    
    // 정렬 기준 추가
    filters['sortBy'] = _currentSortBy;
    
    // DiaryProvider에 필터 적용 요청
    diaryNotifier.searchAndFilter(
      searchQuery: searchQuery,
      filters: filters,
      sortBy: _currentSortBy,
    );
    
    // 검색 결과가 있으면 스크롤을 맨 위로
    if (searchQuery.isNotEmpty || filters.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 스크롤 컨트롤러가 있다면 맨 위로 스크롤
          // TODO: 스크롤 컨트롤러 추가 필요
        }
      });
    }
  }

  /// 필터 다이얼로그 표시
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        currentFilters: _currentFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          _applySearchAndFilter(ref.read(diaryProvider.notifier));
        },
      ),
    );
  }

  /// 정렬 다이얼로그 표시
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.sort, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('정렬 기준', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption(
              title: '날짜순 (최신)',
              subtitle: '최근 작성된 순서대로',
              value: 'date',
              icon: Icons.schedule,
            ),
            _buildSortOption(
              title: '감정순',
              subtitle: '감정 강도 순서대로',
              value: 'emotion',
              icon: Icons.emoji_emotions,
            ),
            _buildSortOption(
              title: '감정 타입순',
              subtitle: '긍정/부정 순서대로',
              value: 'moodType',
              icon: Icons.psychology,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }



  /// 정렬 적용
  void _applySorting() {
    final diaryNotifier = ref.read(diaryProvider.notifier);
    // 정렬 로직은 DiaryProvider에서 처리
    _applySearchAndFilter(diaryNotifier);
  }

  // ===== 삭제 모드 관련 =====
  void _enterDeleteMode() {
    setState(() {
      _isDeleteMode = true;
      _selectedEntryIds.clear();
    });
  }

  void _exitDeleteMode() {
    setState(() {
      _isDeleteMode = false;
      _selectedEntryIds.clear();
    });
  }

  void _toggleSelect(String entryId) {
    setState(() {
      if (_selectedEntryIds.contains(entryId)) {
        _selectedEntryIds.remove(entryId);
      } else {
        _selectedEntryIds.add(entryId);
      }
    });
  }

  Future<void> _confirmAndDeleteSelected() async {
    final toDelete = _selectedEntryIds.toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('선택 삭제'),
        content: Text('${toDelete.length}개의 일기를 삭제하시겠어요? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final diaryNotifier = ref.read(diaryProvider.notifier);
      for (final id in toDelete) {
        await diaryNotifier.deleteDiaryEntry(id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${toDelete.length}개의 일기가 삭제되었습니다.'), backgroundColor: Colors.green),
        );
      }
      _exitDeleteMode();
    }
  }

  /// 일기 작성 옵션 다이얼로그
  void _showWriteOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 제목
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    '일기 작성 방법',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // 옵션들
            _buildWriteOption(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'AI와 대화하며 작성',
              subtitle: 'AI가 질문을 통해 일기를 이끌어줍니다',
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/diary/chat-write');
              },
            ),
            
            _buildWriteOption(
              context,
              icon: Icons.edit_outlined,
              title: '자유롭게 작성',
              subtitle: '직접 일기를 작성합니다',
              color: AppColors.secondary,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/diary/write');
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 일기 작성 옵션 위젯
  Widget _buildWriteOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(minHeight: 88),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 일기 상세 페이지로 이동
  void _navigateToDetail(DiaryEntry entry) {
    context.push('/diary/detail/${entry.id}');
  }

  /// 일기 목록 로드 (StreamBuilder 테스트용)
  Future<void> _loadDiaryEntries() async {
    print('=== 일기 목록 로드 시작 ===');
    
    try {
      // 직접 Firestore 테스트
      final snapshot = await FirebaseFirestore.instance
          .collection("diaries")
          .get();

      print("✅ 가져온 문서 개수: ${snapshot.docs.length}");
      
      if (snapshot.docs.isNotEmpty) {
        print("✅ 첫 번째 문서 데이터: ${snapshot.docs.first.data()}");
      }
      
    } catch (e) {
      print("❌ Firestore 에러: $e");
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return '오늘';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return '어제';
    } else if (targetDate.isAfter(now.subtract(const Duration(days: 7)))) {
      return '${date.month}월 ${date.day}일';
    } else {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// 필터 다이얼로그
class _FilterDialog extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const _FilterDialog({
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late Map<String, dynamic> _filters;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _startDate = _filters['startDate'];
    _endDate = _filters['endDate'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.filter_list, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('필터 설정', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 감정별 필터
            _buildEmotionFilter(),
            const SizedBox(height: 20),
            
            // 날짜 범위 필터
            _buildDateRangeFilter(),
            const SizedBox(height: 20),
            
            // 기타 필터
            _buildOtherFilters(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _filters.clear();
              _startDate = null;
              _endDate = null;
            });
          },
          child: Text(
            '초기화',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startDate != null) _filters['startDate'] = _startDate;
            if (_endDate != null) _filters['endDate'] = _endDate;
            widget.onFiltersChanged(_filters);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('적용'),
        ),
      ],
    );
  }

  /// 감정별 필터
  Widget _buildEmotionFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_emotions, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              '감정별 필터',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Emotion.basicEmotions.map((emotion) {
            final isSelected = _filters['emotion'] == emotion.name;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emotion.emoji),
                  const SizedBox(width: 6),
                  Text(
                    emotion.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _filters['emotion'] = emotion.name;
                  } else {
                    _filters.remove('emotion');
                  }
                });
              },
              selectedColor: emotion.color.withOpacity(0.2),
              checkmarkColor: emotion.color,
              labelStyle: TextStyle(
                color: isSelected ? emotion.color : AppColors.textSecondary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 날짜 범위 필터
  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              '날짜 범위',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                context: context,
                isStartDate: true,
                date: _startDate,
                label: '시작일',
                onTap: () => _selectDate(context, true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '~',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: _buildDateButton(
                context: context,
                isStartDate: false,
                date: _endDate,
                label: '종료일',
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 날짜 버튼 위젯
  Widget _buildDateButton({
    required BuildContext context,
    required bool isStartDate,
    required DateTime? date,
    required String label,
    required VoidCallback onTap,
  }) {
    final hasDate = date != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasDate ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasDate ? AppColors.primary : Colors.grey[300]!,
              width: hasDate ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: hasDate ? AppColors.primary : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                hasDate 
                    ? '${date.month}/${date.day}'
                    : label,
                style: TextStyle(
                  color: hasDate ? AppColors.primary : Colors.grey[600],
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 기타 필터
  Widget _buildOtherFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              '기타 옵션',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCheckboxOption(
          title: 'AI 분석 완료된 일기만',
          subtitle: 'AI가 분석한 일기만 표시',
          icon: Icons.psychology,
          value: _filters['hasAIAnalysis'] == true,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _filters['hasAIAnalysis'] = true;
              } else {
                _filters.remove('hasAIAnalysis');
              }
            });
          },
        ),
        _buildCheckboxOption(
          title: '미디어가 첨부된 일기만',
          subtitle: '사진이나 파일이 첨부된 일기만 표시',
          icon: Icons.image,
          value: _filters['hasMedia'] == true,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _filters['hasMedia'] = true;
              } else {
                _filters.remove('hasMedia');
              }
            });
          },
        ),
      ],
    );
  }

  /// 체크박스 옵션 위젯
  Widget _buildCheckboxOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary.withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Icon(
              icon,
              color: value ? AppColors.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: value ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: value ? AppColors.primary.withOpacity(0.7) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  /// 날짜 선택
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }


}
