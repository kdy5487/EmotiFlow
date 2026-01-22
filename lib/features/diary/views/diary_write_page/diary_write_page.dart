import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/shared/widgets/keyboard_dismissible_scaffold.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:emoti_flow/features/diary/providers/diary_provider.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';
import 'package:emoti_flow/features/diary/domain/entities/media_file.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';

// 위젯 imports
import 'widgets/emotion_selector_section.dart';
import 'widgets/title_input_card.dart';
import 'widgets/content_input_card.dart';
import 'widgets/drawing_section_card.dart';
import 'widgets/settings_section_card.dart';

class DiaryWritePage extends ConsumerStatefulWidget {
  const DiaryWritePage({super.key});

  @override
  ConsumerState<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends ConsumerState<DiaryWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedEmotions = [];
  final Map<String, int> _emotionIntensities = {}; // 감정별 강도 (1-10)
  final List<File> _selectedImages = [];
  final List<File> _selectedDrawings = [];
  bool _isPrivate = false;
  bool _allowAI = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return KeyboardDismissibleScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '일기 작성',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            top: 16,
            bottom: 32, // 하단 여유 공간 확보
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 날짜 선택
              _buildDateSelector(),
              const SizedBox(height: 24),

              // 2. 오늘의 감정 (캐릭터 이미지)
              EmotionSelectorSection(
                selectedEmotions: _selectedEmotions,
                emotionIntensities: _emotionIntensities,
                onEmotionToggle: _toggleEmotion,
                onIntensityChanged: (emotion, intensity) {
                  setState(() {
                    _emotionIntensities[emotion] = intensity;
                  });
                },
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 24),

              // 3. 제목
              TitleInputCard(controller: _titleController),
              const SizedBox(height: 24),

              // 4. 일기 내용
              ContentInputCard(controller: _contentController),
              const SizedBox(height: 24),

              // 5. 그림 그리기
              DrawingSectionCard(
                selectedDrawings: _selectedDrawings,
                onAddDrawing: _openDrawingCanvas,
              ),
              const SizedBox(height: 24),

              // 6. 사진 추가 (선택)
              if (_selectedImages.isNotEmpty) _buildImagePreview(),
              if (_selectedImages.isNotEmpty) const SizedBox(height: 24),

              // 7. 설정 옵션 (간소화)
              SettingsSectionCard(
                isPrivate: _isPrivate,
                allowAI: _allowAI,
                onPrivateChanged: (value) {
                  setState(() {
                    _isPrivate = value ?? false;
                  });
                },
                onAllowAIChanged: (value) {
                  setState(() {
                    _allowAI = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 32),

              // 8. 저장 버튼
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EmotiButton(
                    text: '일기 저장하기',
                    onPressed: _saveDiary,
                    type: EmotiButtonType.primary,
                    size: EmotiButtonSize.large,
                    isFullWidth: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. 날짜 선택
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '일기 날짜',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  /// 사진 미리보기
  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '사진',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: _pickImage,
                child: Text(
                  '+ 추가',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImages[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeMedia(_selectedImages[index]),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============ 기능 메서드들 ============

  /// 날짜 포맷팅 (한국어)
  String _formatDate(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    return '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _toggleEmotion(String emotionName) {
    setState(() {
      if (_selectedEmotions.contains(emotionName)) {
        _selectedEmotions.remove(emotionName);
        _emotionIntensities.remove(emotionName);
      } else {
        if (_selectedEmotions.length < 2) {
          _selectedEmotions.add(emotionName);
          _emotionIntensities[emotionName] = 5;
        }
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedImages.add(File(image.path)));
    }
  }

  Future<void> _openDrawingCanvas() async {
    context.push('/diaries/drawing-canvas').then((result) {
      if (result != null && result is File) {
        setState(() => _selectedDrawings.add(result));
      }
    });
  }

  void _removeMedia(File file) {
    setState(() {
      _selectedImages.remove(file);
      _selectedDrawings.remove(file);
    });
  }

  Future<void> _saveDiary() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일기 내용을 입력해주세요')),
      );
      return;
    }

    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    try {
      // 로컬 파일 경로를 MediaFile로 변환
      final List<MediaFile> mediaFiles = [
        ..._selectedImages.asMap().entries.map((entry) => MediaFile(
              id: 'img_${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
              url: entry.value.path, // 로컬 파일 경로
              type: MediaType.image,
            )),
        ..._selectedDrawings.asMap().entries.map((entry) => MediaFile(
              id: 'draw_${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
              url: entry.value.path, // 로컬 파일 경로
              type: MediaType.drawing,
            )),
      ];

      final diary = DiaryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        title: _titleController.text.trim().isEmpty
            ? '제목 없음'
            : _titleController.text.trim(),
        content: _contentController.text.trim(),
        emotions: _selectedEmotions,
        emotionIntensities: _emotionIntensities,
        createdAt: _selectedDate,
        diaryType: DiaryType.free,
        isPublic: !_isPrivate,
        mediaFiles: mediaFiles,
        metadata: {
          'allowAI': _allowAI,
        },
      );

      await ref.read(diaryProvider.notifier).createDiaryEntry(diary);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일기가 저장되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }
}
