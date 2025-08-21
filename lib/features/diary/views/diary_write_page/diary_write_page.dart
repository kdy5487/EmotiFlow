import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/shared/widgets/inputs/emoti_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:emoti_flow/features/diary/providers/firestore_provider.dart';
import 'package:emoti_flow/features/diary/models/diary_entry.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/features/settings/providers/settings_provider.dart';
import 'package:emoti_flow/features/music/providers/music_provider.dart';
import 'package:emoti_flow/features/music/providers/music_prompt_provider.dart';

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
  
  final List<Map<String, dynamic>> _availableEmotions = [
    {'name': '기쁨', 'color': AppTheme.joy, 'icon': Icons.sentiment_very_satisfied},
    {'name': '사랑', 'color': AppTheme.love, 'icon': Icons.favorite},
    {'name': '평온', 'color': AppTheme.calm, 'icon': Icons.sentiment_satisfied},
    {'name': '슬픔', 'color': AppTheme.sadness, 'icon': Icons.sentiment_dissatisfied},
    {'name': '분노', 'color': AppTheme.anger, 'icon': Icons.sentiment_very_dissatisfied},
    {'name': '두려움', 'color': AppTheme.fear, 'icon': Icons.visibility},
    {'name': '놀람', 'color': AppTheme.surprise, 'icon': Icons.sentiment_satisfied_alt},
    {'name': '중립', 'color': AppTheme.neutral, 'icon': Icons.sentiment_neutral},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '일기 작성',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showDiscardDialog(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: const Text('저장'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 선택 (크기 대폭 축소)
              _buildDateSelector(),
              const SizedBox(height: 20),
              
              // 제목 입력
              _buildTitleInput(),
              const SizedBox(height: 20),
              
              // 감정 선택 (4x2 그리드)
              _buildEmotionSelector(),
              const SizedBox(height: 20),
              
              // 미디어 첨부
              _buildMediaAttachment(),
              const SizedBox(height: 20),
              
              // 내용 입력
              _buildContentInput(),
              const SizedBox(height: 20),
              
              // 설정 옵션
              _buildSettingsOptions(),
              const SizedBox(height: 20),
              
              // 저장 버튼
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 날짜 선택 UI (크기 대폭 축소)
  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                '${_selectedDate.month}월 ${_selectedDate.day}일',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 제목 입력
  Widget _buildTitleInput() {
    return EmotiTextField(
      label: '제목',
      hint: '오늘 하루를 한 줄로 요약해보세요',
      controller: _titleController,
      maxLines: 1,
    );
  }

  /// 감정 선택 섹션
  Widget _buildEmotionSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sentiment_satisfied,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 감정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '최대 2개',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _availableEmotions.length,
            itemBuilder: (context, index) {
              final emotion = _availableEmotions[index];
              final isSelected = _selectedEmotions.contains(emotion['name']);
              final isDisabled = !isSelected && _selectedEmotions.length >= 2;
              
              return GestureDetector(
                onTap: isDisabled ? null : () => _toggleEmotion(emotion['name']),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primary 
                        : (isDisabled ? Colors.grey[300] : AppTheme.surface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.primary 
                          : (isDisabled ? Colors.grey[400]! : AppTheme.border),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        emotion['icon'],
                        color: isSelected 
                            ? Colors.white 
                            : (isDisabled ? Colors.grey[600] : AppTheme.textPrimary),
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emotion['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? Colors.white 
                              : (isDisabled ? Colors.grey[600] : AppTheme.textPrimary),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // 감정 선택 제한 안내 메시지
          if (_selectedEmotions.length >= 2) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '감정은 최대 2개까지 선택할 수 있습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // 선택된 감정이 있을 때만 강도 슬라이더 표시
          if (_selectedEmotions.isNotEmpty) ...[
            const SizedBox(height: 20),
            ..._selectedEmotions.map((emotionName) => _buildEmotionIntensitySlider(emotionName)),
          ],
        ],
      ),
    );
  }

  // 감정 강도 슬라이더
  Widget _buildEmotionIntensitySlider(String emotionName) {
    final intensity = _emotionIntensities[emotionName] ?? 5;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emotionName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '$intensity/10',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: intensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _emotionIntensities[emotionName] = value.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // 미디어 첨부
  Widget _buildMediaAttachment() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '미디어 첨부',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // 미디어 첨부 버튼들
            Column(
              children: [
                // 사진 첨부
                SizedBox(
                  width: double.infinity,
                  child: EmotiButton(
                    text: '사진 추가',
                    onPressed: _pickImage,
                    type: EmotiButtonType.outline,
                    size: EmotiButtonSize.medium,
                    icon: Icons.photo_library,
                    textColor: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                // 그림 그리기
                SizedBox(
                  width: double.infinity,
                  child: EmotiButton(
                    text: '그림 그리기',
                    onPressed: _openDrawingCanvas,
                    type: EmotiButtonType.outline,
                    size: EmotiButtonSize.medium,
                    icon: Icons.brush,
                    textColor: AppTheme.primary,
                  ),
                ),
              ],
            ),
            
            // 선택된 이미지들 표시
            if (_selectedImages.isNotEmpty || _selectedDrawings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '선택된 미디어',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._selectedImages.map((file) => _buildMediaPreview(file, 'image')),
                  ..._selectedDrawings.map((file) => _buildMediaPreview(file, 'drawing')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 미디어 미리보기
  Widget _buildMediaPreview(File file, String type) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(file, type),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 내용 입력
  Widget _buildContentInput() {
    return EmotiTextField(
      label: '일기 내용',
      hint: '오늘 있었던 일과 느낀 감정을 자유롭게 적어보세요...',
      controller: _contentController,
      maxLines: 10,
    );
  }

  // 설정 옵션
  Widget _buildSettingsOptions() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '설정',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('비공개'),
              subtitle: const Text('나만 볼 수 있는 일기'),
              value: _isPrivate,
              onChanged: (value) {
                setState(() {
                  _isPrivate = value;
                });
              },
              activeColor: AppTheme.primary,
            ),
            SwitchListTile(
              title: const Text('AI 분석 허용'),
              subtitle: const Text('감정 분석 및 개선 방안 제시'),
              value: _allowAI,
              onChanged: (value) {
                setState(() {
                  _allowAI = value;
                });
              },
              activeColor: AppTheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  // 저장 버튼
  Widget _buildSaveButton() {
    return EmotiButton(
      text: '일기 저장하기',
      onPressed: _saveDiary,
      type: EmotiButtonType.primary,
      size: EmotiButtonSize.large,
      icon: Icons.save,
      isFullWidth: true,
    );
  }

  // 날짜 선택
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 감정 토글 (최대 2개)
  void _toggleEmotion(String emotionName) {
    setState(() {
      if (_selectedEmotions.contains(emotionName)) {
        // 이미 선택된 감정이면 제거
        _selectedEmotions.remove(emotionName);
        _emotionIntensities.remove(emotionName);
      } else {
        // 최대 2개까지만 선택 가능
        if (_selectedEmotions.length < 2) {
          _selectedEmotions.add(emotionName);
          _emotionIntensities[emotionName] = 5; // 기본 강도 5
        }
        // 이미 2개가 선택된 경우에는 아무것도 하지 않음 (선택 불가)
      }
    });
  }

  // 이미지 선택
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  // 그림 그리기 캔버스 열기
  void _openDrawingCanvas() async {
    final result = await context.push('/diary/drawing-canvas');
    if (result != null && result is String) {
      setState(() {
        _selectedDrawings.add(File(result));
      });
    }
  }

  // 미디어 제거
  void _removeMedia(File file, String type) {
    setState(() {
      if (type == 'image') {
        _selectedImages.remove(file);
      } else if (type == 'drawing') {
        _selectedDrawings.remove(file);
      }
    });
  }

  // 일기 저장
  Future<void> _saveDiary() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog('제목을 입력해주세요');
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showErrorDialog('일기 내용을 입력해주세요');
      return;
    }

    if (_selectedEmotions.isEmpty) {
      _showErrorDialog('감정을 선택해주세요');
      return;
    }

    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) {
        _showErrorDialog('로그인이 필요합니다');
        return;
      }

      // 이미지와 그림을 MediaFile로 변환
      final List<MediaFile> mediaFiles = [];
      
      // 선택된 이미지들 추가
      for (int i = 0; i < _selectedImages.length; i++) {
        mediaFiles.add(MediaFile(
          id: 'image_$i',
          url: _selectedImages[i].path,
          type: MediaType.image,
        ));
      }
      
      // 선택된 그림들 추가
      for (int i = 0; i < _selectedDrawings.length; i++) {
        mediaFiles.add(MediaFile(
          id: 'drawing_$i',
          url: _selectedDrawings[i].path,
          type: MediaType.drawing,
        ));
      }

      // DiaryEntry 객체 생성
      final diaryEntry = DiaryEntry(
        userId: authState.user!.uid,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        emotions: _selectedEmotions,
        emotionIntensities: _emotionIntensities,
        createdAt: _selectedDate,
        diaryType: DiaryType.free,
        isPublic: !_isPrivate,
        mediaFiles: mediaFiles,
      );

      // Firestore에 저장
      await ref.read(firestoreProvider).saveDiary(diaryEntry);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일기가 저장되었습니다')),
      );

      // 일기 목록으로 이동
      context.pop();

      // 음악 전환 안내는 홈으로 돌아간 뒤 표시되도록 예약
      final musicSettings = ref.read(settingsProvider).settings.musicSettings;
      if (musicSettings.enabled && musicSettings.promptOnEmotionChange && musicSettings.showPostDiaryMusicTip) {
        final emotion = _selectedEmotions.isNotEmpty ? _selectedEmotions.first : '평온';
        ref.read(pendingMusicPromptProvider.notifier).state = PendingMusicPrompt(
          emotion: emotion,
          intensity: _emotionIntensities[emotion] ?? 5,
          source: EmotionSource.todayDiary,
        );
      }
    } catch (e) {
      print('일기 저장 오류: $e');
      _showErrorDialog('일기 저장 중 오류가 발생했습니다: $e');
    }
  }

  // 오류 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('입력 오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // AI 조언 다이얼로그
  void _showAIAdviceDialog(DiaryEntry diaryEntry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text('AI 조언'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
                context.pop(); // 홈으로 이동
              },
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 감정: ${diaryEntry.emotions.isNotEmpty ? diaryEntry.emotions.first : '평온'}',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '오늘의 조언',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generateAIAdvice(diaryEntry),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.pop(); // 홈으로 이동
                    },
                    child: const Text('홈으로'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/ai'); // AI 분석 페이지로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('자세한 분석'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // AI 조언 생성 (간단한 버전)
  String _generateAIAdvice(DiaryEntry diaryEntry) {
    final emotion = diaryEntry.emotions.isNotEmpty ? diaryEntry.emotions.first : '평온';
    final intensity = diaryEntry.emotionIntensities[emotion] ?? 5;
    
    switch (emotion) {
      case '기쁨':
        return '정말 기쁜 하루였네요! 이런 긍정적인 감정을 오래 유지하기 위해 감사한 일들을 더 기록해보세요.';
      case '사랑':
        return '사랑이 가득한 하루였군요. 주변 사람들에게 더 많은 관심과 사랑을 나누어보세요.';
      case '평온':
        return '차분하고 평온한 마음으로 하루를 마무리했네요. 이 평온함을 기록하고 감사해보세요.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 자신에게 친절하게 대하고 충분한 휴식을 취하세요.';
      case '분노':
        return '화가 나는 일이 있었나요? 깊은 호흡을 통해 감정을 진정시키고, 산책이나 운동으로 스트레스를 해소해보세요.';
      case '두려움':
        return '불안하고 걱정되는 마음이 드시나요? 현재에 집중하는 명상이나 요가를 시도해보세요.';
      case '놀람':
        return '예상치 못한 일이 있었나요? 새로운 경험을 긍정적으로 받아들이고 성장의 기회로 삼아보세요.';
      case '중립':
        return '차분하게 하루를 마무리했네요. 내일은 더 특별한 순간들을 만들어보세요.';
      default:
        return '오늘 하루도 수고하셨습니다. 내일은 더 좋은 하루가 될 거예요!';
    }
  }

  // 작성 취소 다이얼로그
  void _showDiscardDialog(BuildContext context) {
    if (_titleController.text.isNotEmpty || _contentController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('작성 취소'),
          content: const Text('작성 중인 내용이 있습니다. 정말로 나가시겠습니까?'),
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
              child: const Text('나가기'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }
}