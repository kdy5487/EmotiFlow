import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/shared/widgets/keyboard_dismissible_scaffold.dart';
import 'package:emoti_flow/shared/constants/emotion_character_map.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:emoti_flow/features/diary/providers/diary_provider.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';
import 'package:emoti_flow/features/diary/domain/entities/media_file.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';

class DiaryWritePage extends ConsumerStatefulWidget {
  const DiaryWritePage({super.key});

  @override
  ConsumerState<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends ConsumerState<DiaryWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  List<String> _selectedEmotions = [];
  Map<String, int> _emotionIntensities = {}; // 감정별 강도 (1-10)
  List<File> _selectedImages = [];
  List<File> _selectedDrawings = [];
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
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: const Text('일기 작성'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF7),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: const Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 날짜 선택
            _buildDateSelector(),
            const SizedBox(height: 24),

            // 2. 오늘의 감정 (캐릭터 이미지)
            _buildEmotionSelector(),
            const SizedBox(height: 24),

            // 3. 제목
            _buildTitleInput(),
            const SizedBox(height: 24),

            // 4. 일기 내용
            _buildContentInput(),
            const SizedBox(height: 24),

            // 5. 그림 그리기
            _buildDrawingSection(),
            const SizedBox(height: 24),

            // 6. 사진 추가 (선택)
            if (_selectedImages.isNotEmpty) _buildImagePreview(),
            if (_selectedImages.isNotEmpty) const SizedBox(height: 24),

            // 7. 설정 옵션 (간소화)
            _buildSettings(),
            const SizedBox(height: 32),

            // 8. 저장 버튼
            EmotiButton(
              text: '일기 저장하기',
              onPressed: _saveDiary,
              type: EmotiButtonType.primary,
              size: EmotiButtonSize.large,
              isFullWidth: true,
            ),
          ],
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
          color: Colors.white,
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
                  const Text(
                    '일기 날짜',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// 2. 오늘의 감정 선택 (캐릭터 이미지, 4x3 + 선택없음) - 적응형
  Widget _buildEmotionSelector() {
    final emotions = EmotionCharacterMap.availableEmotions;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // "선택 없음" 옵션 추가
    final allOptions = ['선택 없음', ...emotions];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
            children: [
              Flexible(
                child: const Text(
                  '오늘의 감정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '최대 2개',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '오늘 느낀 감정을 선택해주세요',
            style: TextStyle(
              fontSize: screenWidth * 0.03, // 적응형
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // 감정 그리드 (4x3 + 선택없음) - 적응형 (오버플로우 방지)
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 30) / 4; // 4열, 간격 고려
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4열
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 22, // ✅ 간격 더 넓힘 (18 → 22)
                  childAspectRatio:
                      itemWidth / (itemWidth + 18), // ✅ 비율 조정 (15 → 18)
                ),
                itemCount: allOptions.length, // ✅ "선택 없음" 포함
                itemBuilder: (context, index) {
                  final option = allOptions[index];
                  final isNoneOption = option == '선택 없음';
                  
                  if (isNoneOption) {
                    // "선택 없음" - 대표 캐릭터 사용
                    final isSelected = _selectedEmotions.isEmpty;
                    return _buildEmotionItem(
                      emotion: '선택 없음',
                      isSelected: isSelected,
                      isDisabled: false,
                      itemSize: itemWidth,
                      isNoneOption: true,
                      onTap: () {
                        setState(() {
                          _selectedEmotions.clear();
                          _emotionIntensities.clear();
                        });
                      },
                    );
                  } else {
                    // 일반 감정
                    final emotion = option;
                    final isSelected = _selectedEmotions.contains(emotion);
                    final isDisabled =
                        !isSelected && _selectedEmotions.length >= 2;

                    return _buildEmotionItem(
                      emotion: emotion,
                      isSelected: isSelected,
                      isDisabled: isDisabled,
                      itemSize: itemWidth,
                      isNoneOption: false,
                      onTap: () {
                        if (!isDisabled) {
                          _toggleEmotion(emotion);
                        }
                      },
                    );
                  }
                },
              );
            },
          ),

          // 감정 강도 슬라이더
          if (_selectedEmotions.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            ..._selectedEmotions
                .map((emotion) => _buildIntensitySlider(emotion)),
          ],
        ],
      ),
    );
  }

  /// 감정 아이템 (캐릭터 이미지)
  Widget _buildEmotionItem({
    required String emotion,
    required bool isSelected,
    required bool isDisabled,
    required double itemSize,
    required VoidCallback onTap,
    bool isNoneOption = false,
  }) {
    final characterAsset = isNoneOption
        ? EmotionCharacterMap.defaultCharacter
        : EmotionCharacterMap.getCharacterAsset(emotion);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: itemSize,
              height: itemSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDisabled ? Colors.grey[200] : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: isSelected ? 3 : 0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isSelected ? 3 : 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    isSelected ? 13 : 16,
                  ),
                  child: Image.asset(
                    characterAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.sentiment_satisfied,
                          color: AppTheme.primary,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emotion,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primary
                    : (isDisabled ? Colors.grey : AppTheme.textPrimary),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 감정 강도 슬라이더
  Widget _buildIntensitySlider(String emotion) {
    final intensity = _emotionIntensities[emotion] ?? 5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // 16 → 8 (간격 줄임)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emotion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '$intensity/10',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.0, // 슬라이더 굵기 줄임 (기본 4.0 → 3.0)
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0, // 썸 크기 조정
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16.0, // 오버레이 크기 조정
              ),
            ),
            child: Slider(
              value: intensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppTheme.primary,
              inactiveColor: AppTheme.primary.withOpacity(0.2),
              onChanged: (val) {
                setState(() {
                  _emotionIntensities[emotion] = val.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 3. 제목 입력
  Widget _buildTitleInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            '제목',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '오늘 하루를 한 줄로 요약해보세요',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 4. 일기 내용 입력
  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            '일기 내용',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: '오늘 있었던 일과 느낀 감정을 자유롭게 적어보세요...',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// 5. 그림 그리기
  Widget _buildDrawingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            '그림으로 표현하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '오늘의 감정을 그림으로 그려보세요',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // 그림 미리보기
          if (_selectedDrawings.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedDrawings.map((file) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeMedia(file),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          if (_selectedDrawings.isNotEmpty) const SizedBox(height: 16),

          // 그림 그리기 버튼
          OutlinedButton.icon(
            onPressed: _openDrawingCanvas,
            icon: const Icon(Icons.brush, size: 20),
            label: Text(
              _selectedDrawings.isEmpty ? '그림 그리기' : '그림 추가',
              style: const TextStyle(fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 사진 미리보기
  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            '첨부 사진',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedImages.map((file) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      file,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeMedia(file),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 6. 설정 옵션 (간소화)
  Widget _buildSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
            children: [
              const Text(
                '일기 설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '개발중',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              '비공개 일기',
              style: TextStyle(fontSize: 14),
            ),
            subtitle: const Text(
              '나만 볼 수 있는 일기로 설정',
              style: TextStyle(fontSize: 12),
            ),
            value: _isPrivate,
            onChanged: (val) => setState(() => _isPrivate = val),
            activeColor: AppTheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text(
              'AI 분석 허용',
              style: TextStyle(fontSize: 14),
            ),
            subtitle: const Text(
              'AI가 감정을 분석하고 추천을 제공',
              style: TextStyle(fontSize: 12),
            ),
            value: _allowAI,
            onChanged: (val) => setState(() => _allowAI = val),
            activeColor: AppTheme.primary,
            contentPadding: EdgeInsets.zero,
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

  void _showDiscardDialog(BuildContext context) {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일기 작성 취소'),
        content: const Text('작성 중인 일기를 취소하시겠습니까?\n작성 내용은 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 작성'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('취소', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
