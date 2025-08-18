import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/diary_write_view_model.dart';
import 'drawing_canvas_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/diary_provider.dart';
import '../models/emotion.dart';
import '../models/diary_entry.dart';


import '../../../shared/widgets/inputs/emoti_text_field.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';

/// 자유형 일기 작성 페이지
class DiaryWritePage extends ConsumerStatefulWidget {
  const DiaryWritePage({super.key});

  @override
  ConsumerState<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends ConsumerState<DiaryWritePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 컨트롤러와 뷰모델 연결
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleController.addListener(() {
        ref.read(diaryWriteProvider.notifier).setTitle(_titleController.text);
      });
      _contentController.addListener(() {
        ref.read(diaryWriteProvider.notifier).setContent(_contentController.text);
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(diaryWriteProvider.notifier);
    final state = ref.watch(diaryWriteProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('자유형 일기 작성'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: viewModel.canSaveEntry ? _saveDiary : null,
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // 외부 터치 시 키보드 내리기
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 선택
              _buildDatePickerSection(viewModel),
              const SizedBox(height: 16),
              
              // 제목 입력
              _buildTitleSection(viewModel),
              const SizedBox(height: 16),
              
              // 감정 선택
              _buildEmotionSection(viewModel),
              const SizedBox(height: 16),
              
              // 내용 입력
              _buildContentSection(viewModel),
              const SizedBox(height: 16),
              
              // 태그 입력
              _buildTagSection(viewModel),
              const SizedBox(height: 16),
              
              // 미디어 첨부
              _buildMediaSection(viewModel),
              const SizedBox(height: 16),
              
              // AI 분석 설정
              _buildAIAnalysisSection(viewModel),
              const SizedBox(height: 24),
              
              // 공개 설정
              _buildPublicSection(viewModel),
              const SizedBox(height: 24),
              
              // 에러 메시지
              if (state.errorMessage != null)
                _buildErrorMessage(state.errorMessage!),
              
              const SizedBox(height: 80), // 하단 여백
            ],
          ),
        ),
      ),
    );
  }

  /// 날짜 선택 섹션
  Widget _buildDatePickerSection(DiaryWriteViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('날짜 선택', style: AppTypography.bodyLarge),
                Text(
                  _formatDate(viewModel.selectedDate),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _selectDate(context, viewModel),
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  /// 제목 입력 섹션
  Widget _buildTitleSection(DiaryWriteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('제목', style: AppTypography.titleMedium),
        const SizedBox(height: 6),
        EmotiTextField(
          controller: _titleController,
          focusNode: _titleFocusNode,
          hintText: '오늘의 제목을 입력해주세요',
          maxLines: 1,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            _contentFocusNode.requestFocus();
          },
        ),
      ],
    );
  }

  /// 감정 선택 섹션
  Widget _buildEmotionSection(DiaryWriteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('오늘의 감정', style: AppTypography.titleMedium),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '감정 선택 (복수 선택 가능)',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 감정 선택 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.9,
          ),
          itemCount: Emotion.basicEmotions.length,
          itemBuilder: (context, index) {
            final emotion = Emotion.basicEmotions[index];
            final isSelected = viewModel.selectedEmotions.contains(emotion.name);
            
            return GestureDetector(
              onTap: () {
                viewModel.toggleEmotion(emotion.name);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? emotion.color.withOpacity(0.2) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? emotion.color : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emotion.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      emotion.name,
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? emotion.color : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // 선택된 감정들의 강도 조절
        if (viewModel.selectedEmotions.isNotEmpty)
          _buildEmotionIntensitySection(viewModel),
      ],
    );
  }

  /// 감정 강도 조절 섹션
  Widget _buildEmotionIntensitySection(DiaryWriteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '감정 강도 조절',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...viewModel.selectedEmotions.map<Widget>((emotionName) {
          final emotion = Emotion.findByName(emotionName);
          if (emotion == null) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Text(
                  emotion.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Slider(
                    value: viewModel.emotionIntensities[emotionName]?.toDouble() ?? 5.0,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    activeColor: emotion.color,
                    inactiveColor: emotion.color.withOpacity(0.3),
                    onChanged: (value) {
                      viewModel.setEmotionIntensity(emotionName, value.round());
                    },
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 24,
                  child: Text(
                    '${viewModel.emotionIntensities[emotionName] ?? 5}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: emotion.color,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 내용 입력 섹션
  Widget _buildContentSection(DiaryWriteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('내용', style: AppTypography.titleMedium),
        const SizedBox(height: 6),
        EmotiTextField(
          controller: _contentController,
          focusNode: _contentFocusNode,
          hintText: '오늘 있었던 일이나 느낀 점을 자유롭게 작성해주세요...',
          maxLines: 8,
          maxLength: 1000,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${viewModel.contentLength}/1000자',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${viewModel.wordCount}단어',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 태그 입력 섹션
  Widget _buildTagSection(DiaryWriteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('태그', style: AppTypography.titleMedium),
        const SizedBox(height: 6),
        Text(
          '일기와 관련된 키워드를 태그로 추가해주세요',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        
        // 태그 입력 필드
        Row(
          children: [
            Expanded(
              child: EmotiTextField(
                controller: _tagController,
                hintText: '태그를 입력하고 Enter를 누르세요',
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    viewModel.addTag(value.trim());
                    _tagController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (_tagController.text.trim().isNotEmpty) {
                  viewModel.addTag(_tagController.text.trim());
                  _tagController.clear();
                }
              },
              icon: const Icon(Icons.add, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        
        // 태그 목록
        if (viewModel.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: viewModel.tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => viewModel.removeTag(tag),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// 미디어 첨부 섹션
  Widget _buildMediaSection(DiaryWriteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('미디어 첨부', style: AppTypography.titleMedium),
        const SizedBox(height: 6),
        Text(
          '사진, 그림, 음성 등을 첨부할 수 있습니다',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // 미디어 타입별 버튼
        Row(
          children: [
            Expanded(
              child: _buildMediaButton(
                icon: Icons.photo_camera,
                label: '사진',
                onTap: () => _addImage(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMediaButton(
                icon: Icons.brush,
                label: '그림',
                onTap: () => _addDrawing(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMediaButton(
                icon: Icons.mic,
                label: '음성',
                onTap: () => _addVoice(),
              ),
            ),
          ],
        ),
        
        // 첨부된 미디어 목록 (썸네일/프리뷰)
        if (viewModel.mediaCount > 0) ...[
          const SizedBox(height: 16),
          Text(
            '첨부된 미디어 (${viewModel.mediaCount}개)',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // 여기에 미디어 썸네일 목록 표시
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.mediaFiles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final file = viewModel.mediaFiles[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: file.type == MediaType.image || file.type == MediaType.drawing
                        ? Image.file(
                            File(file.url),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
                          )
                        : const Icon(Icons.audiotrack, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// 미디어 버튼
  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        foregroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// AI 분석 설정 섹션
  Widget _buildAIAnalysisSection(DiaryWriteViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 감정 분석',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '작성한 일기를 AI가 분석하여 감정 패턴을 파악합니다',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: viewModel.isAIAnalysisEnabled,
            onChanged: (value) {
              viewModel.toggleAIAnalysis();
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// 공개 설정 섹션
  Widget _buildPublicSection(DiaryWriteViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.public,
            color: AppColors.secondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '공개 설정',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '일기를 다른 사용자와 공유할 수 있습니다',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: viewModel.isPublic,
            onChanged: (value) {
              viewModel.togglePublic();
            },
            activeColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  /// 에러 메시지 표시
  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.red[700],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(diaryWriteProvider.notifier).clearError();
            },
            icon: Icon(Icons.close, color: Colors.red[600], size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// 날짜 선택
  Future<void> _selectDate(BuildContext context, DiaryWriteViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != viewModel.selectedDate) {
      viewModel.setSelectedDate(picked);
    }
  }

  /// 이미지 추가
  void _addImage() {
    _pickImage();
  }

  /// 그림 추가
  void _addDrawing() {
    _openDrawing();
  }

  /// 음성 추가
  void _addVoice() {
    // TODO: 음성 녹음 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('음성 녹음 기능은 추후 구현 예정입니다.')),
    );
  }

  /// 이미지 선택 (image_picker)
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      final vm = ref.read(diaryWriteProvider.notifier);
      vm.addMediaFile(MediaFile(
        id: picked.path,
        url: picked.path,
        type: MediaType.image,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지가 추가되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 추가 실패: $e')),
        );
      }
    }
  }

  /// 그림 그리기 화면 열기
  Future<void> _openDrawing() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const DrawingCanvasPage()),
    );
    if (path == null) return;
    final vm = ref.read(diaryWriteProvider.notifier);
    vm.addMediaFile(MediaFile(
      id: path,
      url: path,
      type: MediaType.drawing,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그림이 추가되었습니다.')),
      );
    }
  }

  /// 일기 저장
  Future<void> _saveDiary() async {
    final viewModel = ref.read(diaryWriteProvider.notifier);
    
    // 유효성 검사
    final validationError = viewModel.validateForm();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 저장 진행
    try {
      final diaryNotifier = ref.read(diaryProvider.notifier);
      final authState = ref.read(authProvider);
      final currentUser = authState.user?.uid;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 필요합니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final entry = viewModel.createDiaryEntry(currentUser);
      await diaryNotifier.createDiaryEntry(entry);

      if (!mounted) return;
      // 저장 직후 결과 미리보기
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('저장 완료', style: AppTypography.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('제목', style: AppTypography.titleMedium),
                  const SizedBox(height: 4),
                  Text(entry.title, style: AppTypography.bodyLarge),
                  const SizedBox(height: 12),
                  Text('내용', style: AppTypography.titleMedium),
                  const SizedBox(height: 4),
                  Text(entry.content, style: AppTypography.bodyMedium),
                  const SizedBox(height: 12),
                  if (entry.mediaCount > 0) ...[
                    Text('첨부된 미디어', style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.mediaFiles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final file = entry.mediaFiles[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: file.type == MediaType.image || file.type == MediaType.drawing
                                  ? Image.asset(
                                      file.url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
                                    )
                                  : const Icon(Icons.audiotrack, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('확인'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }
}
