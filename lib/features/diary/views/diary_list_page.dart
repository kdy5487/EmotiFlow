import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../models/emotion.dart';
import '../models/diary_entry.dart' show DiaryType;

import '../../../shared/widgets/cards/emoti_card.dart';
import '../../../shared/widgets/inputs/emoti_text_field.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';

/// 일기 목록 페이지
class DiaryListPage extends ConsumerStatefulWidget {
  const DiaryListPage({super.key});

  @override
  ConsumerState<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends ConsumerState<DiaryListPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  
  String _currentSearchQuery = '';
  Map<String, dynamic> _currentFilters = {};
  String _currentSortBy = 'date'; // date, emotion, moodType

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
      appBar: AppBar(
        title: const Text('일기 목록'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터 섹션
          _buildSearchAndFilterSection(diaryNotifier),
          
          // 필터 태그 표시
          if (_currentFilters.isNotEmpty) _buildFilterTags(diaryNotifier),
          
          // 일기 목록
          Expanded(
            child: _buildDiaryList(diaryState, diaryNotifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWriteOptionsDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 검색 및 필터 섹션
  Widget _buildSearchAndFilterSection(DiaryProvider diaryNotifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 검색바
          EmotiTextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            hintText: '일기 내용, 제목, 태그로 검색...',
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              _currentSearchQuery = value;
              _applySearchAndFilter(diaryNotifier);
            },
          ),
          
          const SizedBox(height: 12),
          
          // 빠른 필터 버튼들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickFilterChip('전체', null, diaryNotifier),
                _buildQuickFilterChip('긍정', 'positive', diaryNotifier),
                _buildQuickFilterChip('부정', 'negative', diaryNotifier),
                _buildQuickFilterChip('AI 분석', true, diaryNotifier, filterKey: 'hasAIAnalysis'),
                _buildQuickFilterChip('미디어', true, diaryNotifier, filterKey: 'hasMedia'),
              ],
            ),
          ),
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
        label: Text(label),
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
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  /// 필터 태그 표시
  Widget _buildFilterTags(DiaryProvider diaryNotifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _currentFilters.entries.map((entry) {
          return Chip(
            label: Text(_getFilterLabel(entry.key, entry.value)),
            onDeleted: () {
              _currentFilters.remove(entry.key);
              _applySearchAndFilter(diaryNotifier);
            },
            backgroundColor: AppColors.primary.withOpacity(0.1),
            labelStyle: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
            ),
          );
        }).toList(),
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

  /// 일기 목록 (StreamBuilder 사용)
  Widget _buildDiaryList(DiaryState diaryState, DiaryProvider diaryNotifier) {
    print('=== 일기 목록 빌드 ===');
    
    // StreamBuilder를 사용해서 실시간 Firestore 데이터 가져오기
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("diaries").snapshots(),
      builder: (context, snapshot) {
        print('=== StreamBuilder 상태 ===');
        print('연결 상태: ${snapshot.connectionState}');
        print('데이터 있음: ${snapshot.hasData}');
        print('오류 있음: ${snapshot.hasError}');
        if (snapshot.hasData) {
          print('문서 개수: ${snapshot.data!.docs.length}');
        }
        if (snapshot.hasError) {
          print('오류 내용: ${snapshot.error}');
        }
        
        // 오류 발생 시
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  "❌ 오류: ${snapshot.error}",
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.red[600],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '더미 데이터를 표시합니다.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                // 더미 데이터로 폴백
                Expanded(
                  child: _buildDummyDataList(),
                ),
              ],
            ),
          );
        }
        
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('일기 목록을 불러오는 중...'),
              ],
            ),
          );
        }
        
        // 데이터 없음
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '데이터가 없습니다',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '더미 데이터를 표시합니다.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                // 더미 데이터로 폴백
                Expanded(
                  child: _buildDummyDataList(),
                ),
              ],
            ),
          );
        }
        
        // 실제 Firestore 데이터 표시
        final docs = snapshot.data!.docs;
        print('✅ Firestore에서 ${docs.length}개 문서 가져옴');
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            // Firestore 데이터를 DiaryEntry로 변환
            try {
              final entry = DiaryEntry.fromFirestore(doc);
              return _buildDiaryCard(entry, index);
            } catch (e) {
              print('문서 변환 실패: $e, 데이터: $data');
              // 변환 실패 시 간단한 카드 표시
              return _buildSimpleDiaryCard(doc.id, data, index);
            }
          },
        );
      },
    );
  }

  /// 일기 카드
  Widget _buildDiaryCard(DiaryEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: EmotiCard(
        child: InkWell(
          onTap: () => _navigateToDetail(entry),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(entry.createdAt),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildEmotionIndicator(entry),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 제목
                if (entry.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      entry.title,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                // 내용 미리보기
                Text(
                  entry.content,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // 하단 정보 (태그, 미디어, AI 분석)
                Row(
                  children: [
                    // 태그
                    if (entry.tags.isNotEmpty) ...[
                      Icon(Icons.label, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.tags.take(3).join(', '),
                          style: AppTypography.caption.copyWith(
                            color: Colors.grey[600],
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
                          Icon(Icons.image, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.mediaCount}',
                            style: AppTypography.caption.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(width: 16),
                    
                    // AI 분석 완료 여부
                    if (entry.hasAIAnalysis)
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    
                    const SizedBox(width: 8),
                    
                    // 일기 종류 표시
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: entry.diaryType == DiaryType.aiChat 
                            ? AppColors.secondary.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
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
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 감정 표시기
  Widget _buildEmotionIndicator(DiaryEntry entry) {
    if (entry.emotions.isEmpty) return const SizedBox.shrink();
    
    final primaryEmotion = entry.emotions.first;
    final emotionModel = Emotion.findByName(primaryEmotion);
    
    if (emotionModel == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: emotionModel.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: emotionModel.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emotionModel.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            emotionModel.name,
            style: AppTypography.caption.copyWith(
              color: emotionModel.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 상태 표시
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _currentSearchQuery.isNotEmpty || _currentFilters.isNotEmpty
                ? '검색 결과가 없습니다'
                : '아직 작성된 일기가 없습니다',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentSearchQuery.isNotEmpty || _currentFilters.isNotEmpty
                ? '검색어나 필터를 변경해보세요'
                : '첫 번째 일기를 작성해보세요',
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

  /// 더미 데이터 목록 표시
  Widget _buildDummyDataList() {
    final dummyEntries = [
      DiaryEntry(
        id: 'dummy_1',
        title: 'AI와 함께한 하루',
        content: 'AI와 대화하며 오늘 하루를 정리했습니다. 생각보다 많은 감정들을 느꼈네요.',
        emotions: ['기쁨', '평온'],
        emotionIntensities: {'기쁨': 8, '평온': 7},
        userId: 'demo_user',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        diaryType: DiaryType.aiChat,
      ),
      DiaryEntry(
        id: 'dummy_2',
        title: '조금 힘들었던 하루',
        content: '일이 많아서 조금 스트레스를 받았지만, 그래도 잘 버텨냈어요. 내일은 더 좋을 거예요.',
        emotions: ['걱정', '희망'],
        emotionIntensities: {'걱정': 6, '희망': 7},
        userId: 'demo_user',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        diaryType: DiaryType.free,
      ),
      DiaryEntry(
        id: 'dummy_3',
        title: '새로운 도전',
        content: '새로운 프로젝트를 시작하게 되어 설레고 기대됩니다. 열심히 해보겠어요!',
        emotions: ['설렘', '기대'],
        emotionIntensities: {'설렘': 9, '기대': 8},
        userId: 'demo_user',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        diaryType: DiaryType.free,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyEntries.length,
      itemBuilder: (context, index) {
        final entry = dummyEntries[index];
        return _buildDiaryCard(entry, index);
      },
    );
  }

  /// 간단한 일기 카드 (Firestore 데이터 변환 실패 시)
  Widget _buildSimpleDiaryCard(String docId, Map<String, dynamic> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                      data['title']?.toString() ?? '제목 없음',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Firestore',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data['content']?.toString() ?? '내용 없음',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '문서 ID: $docId',
                style: AppTypography.caption.copyWith(
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 검색 및 필터 적용
  void _applySearchAndFilter(DiaryProvider diaryNotifier) {
    diaryNotifier.searchAndFilter(
      searchQuery: _currentSearchQuery,
      filters: _currentFilters,
      sortBy: _currentSortBy,
    );
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
        title: const Text('정렬 기준'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('날짜순 (최신)'),
              value: 'date',
              groupValue: _currentSortBy,
              onChanged: (value) {
                setState(() {
                  _currentSortBy = value!;
                });
                Navigator.of(context).pop();
                _applySorting();
              },
            ),
            RadioListTile<String>(
              title: const Text('감정순'),
              value: 'emotion',
              groupValue: _currentSortBy,
              onChanged: (value) {
                setState(() {
                  _currentSortBy = value!;
                });
                Navigator.of(context).pop();
                _applySorting();
              },
            ),
            RadioListTile<String>(
              title: const Text('감정 타입순'),
              value: 'moodType',
              groupValue: _currentSortBy,
              onChanged: (value) {
                setState(() {
                  _currentSortBy = value!;
                });
                Navigator.of(context).pop();
                _applySorting();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 정렬 적용
  void _applySorting() {
    final diaryNotifier = ref.read(diaryProvider.notifier);
    // 정렬 로직은 DiaryProvider에서 처리
    _applySearchAndFilter(diaryNotifier);
  }

  /// 일기 작성 옵션 다이얼로그
  void _showWriteOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 작성 방법'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.primary),
              title: const Text('AI와 대화하며 작성'),
              subtitle: const Text('AI가 질문을 통해 일기를 이끌어줍니다'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/diary/chat-write');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.secondary),
              title: const Text('자유롭게 작성'),
              subtitle: const Text('직접 일기를 작성합니다'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/diary/write');
              },
            ),
          ],
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
      title: const Text('필터 설정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 감정별 필터
            _buildEmotionFilter(),
            const SizedBox(height: 16),
            
            // 날짜 범위 필터
            _buildDateRangeFilter(),
            const SizedBox(height: 16),
            
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
          child: const Text('초기화'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startDate != null) _filters['startDate'] = _startDate;
            if (_endDate != null) _filters['endDate'] = _endDate;
            widget.onFiltersChanged(_filters);
            Navigator.of(context).pop();
          },
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
        Text(
          '감정별 필터',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Emotion.basicEmotions.map((emotion) {
            final isSelected = _filters['emotion'] == emotion.name;
            return FilterChip(
              label: Text(emotion.name),
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
        Text(
          '날짜 범위',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => _selectDate(context, true),
                icon: const Icon(Icons.calendar_today),
                label: Text(_startDate != null 
                    ? '${_startDate!.month}/${_startDate!.day}'
                    : '시작일'),
              ),
            ),
            const Text('~'),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _selectDate(context, false),
                icon: const Icon(Icons.calendar_today),
                label: Text(_endDate != null 
                    ? '${_endDate!.month}/${_endDate!.day}'
                    : '종료일'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 기타 필터
  Widget _buildOtherFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기타 옵션',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('AI 분석 완료된 일기만'),
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
        CheckboxListTile(
          title: const Text('미디어가 첨부된 일기만'),
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
