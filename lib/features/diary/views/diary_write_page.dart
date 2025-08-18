import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/diary_write_view_model.dart';
import '../providers/diary_provider.dart';
import '../models/emotion.dart';

import '../../../shared/widgets/inputs/emoti_text_field.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';

/// 일기 작성 페이지
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(diaryWriteProvider.notifier);
    final state = ref.watch(diaryWriteProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('일기 작성'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: viewModel.canSave ? _saveDiary : null,
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              _buildTitleSection(viewModel),
              const SizedBox(height: 24),
              
              // 감정 선택
              _buildEmotionSection(viewModel),
              const SizedBox(height: 24),
              
              // 내용 입력
              _buildContentSection(viewModel),
              const SizedBox(height: 24),
              
              // AI 분석 설정
              _buildAIAnalysisSection(viewModel),
              const SizedBox(height: 24),
              
              // 에러 메시지
              if (state.errorMessage != null)
                _buildErrorMessage(state.errorMessage!),
              
              const SizedBox(height: 100), // 하단 여백
            ],
          ),
        ),
      ),
    );
  }

  /// 제목 입력 섹션
  Widget _buildTitleSection(DiaryWriteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '제목',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
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
        Text(
          '오늘의 감정',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '오늘 느낀 감정을 선택해주세요 (여러 개 선택 가능)',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // 감정 선택 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
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
                      style: const TextStyle(fontSize: 20),
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
        Text(
          '내용',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        EmotiTextField(
          controller: _contentController,
          focusNode: _contentFocusNode,
          hintText: '오늘 있었던 일이나 느낀 점을 자유롭게 작성해주세요...',
          maxLines: 10,
          maxLength: 1000,
        ),
      ],
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
      final success = await diaryNotifier.createDiaryEntry(entry);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('일기가 성공적으로 저장되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // 이전 화면으로 돌아가기
        }
      } else {
        if (mounted) {
          final diaryState = ref.read(diaryProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(diaryState.errorMessage ?? '저장에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
}
