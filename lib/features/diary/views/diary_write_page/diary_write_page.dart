import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/shared/widgets/inputs/emoti_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:emoti_flow/features/diary/providers/firestore_provider.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';
import 'package:emoti_flow/features/diary/domain/entities/media_file.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/features/settings/providers/settings_provider.dart';
import 'package:emoti_flow/features/music/providers/music_provider.dart';
import 'package:emoti_flow/features/music/providers/music_prompt_provider.dart';
import 'widgets/write_date_selector.dart';
import 'widgets/write_emotion_selector.dart';
import 'widgets/write_media_attachment.dart';
import 'widgets/write_settings_options.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '일기 작성',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showDiscardDialog(context),
        ),
        actions: [
          TextButton(onPressed: _saveDiary, child: const Text('저장')),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WriteDateSelector(
                selectedDate: _selectedDate,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              EmotiTextField(
                labelText: '제목',
                hintText: '오늘 하루를 한 줄로 요약해보세요',
                controller: _titleController,
              ),
              const SizedBox(height: 20),
              WriteEmotionSelector(
                selectedEmotions: _selectedEmotions,
                onToggle: _toggleEmotion,
                emotionIntensities: _emotionIntensities,
                onIntensityChanged: (name, val) {
                  setState(() => _emotionIntensities[name] = val);
                },
              ),
              const SizedBox(height: 20),
              WriteMediaAttachment(
                selectedImages: _selectedImages,
                selectedDrawings: _selectedDrawings,
                onPickImage: _pickImage,
                onOpenCanvas: _openDrawingCanvas,
                onRemove: _removeMedia,
              ),
              const SizedBox(height: 20),
              EmotiTextField(
                labelText: '일기 내용',
                hintText: '오늘 있었던 일과 느낀 감정을 자유롭게 적어보세요...',
                controller: _contentController,
                maxLines: 10,
              ),
              const SizedBox(height: 20),
              WriteSettingsOptions(
                isPrivate: _isPrivate,
                allowAI: _allowAI,
                onPrivateChanged: (val) => setState(() => _isPrivate = val),
                onAIChanged: (val) => setState(() => _allowAI = val),
              ),
              const SizedBox(height: 20),
              EmotiButton(
                text: '일기 저장하기',
                onPressed: _saveDiary,
                type: EmotiButtonType.primary,
                size: EmotiButtonSize.large,
                icon: Icons.save,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
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
      } else if (_selectedEmotions.length < 2) {
        _selectedEmotions.add(emotionName);
        _emotionIntensities[emotionName] = 5;
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImages.add(File(image.path)));
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  void _openDrawingCanvas() async {
    final result = await context.push('/diaries/drawing-canvas');
    if (result != null && result is String) {
      setState(() => _selectedDrawings.add(File(result)));
    }
  }

  void _removeMedia(File file, String type) {
    setState(() {
      if (type == 'image') {
        _selectedImages.remove(file);
      } else if (type == 'drawing') {
        _selectedDrawings.remove(file);
      }
    });
  }

  Future<void> _saveDiary() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) return _showErrorDialog('제목을 입력해주세요');
    if (content.isEmpty) return _showErrorDialog('일기 내용을 입력해주세요');
    if (_selectedEmotions.isEmpty) return _showErrorDialog('감정을 선택해주세요');

    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) return _showErrorDialog('로그인이 필요합니다');

      final mediaFiles = [
        ..._selectedImages.asMap().entries.map((e) => MediaFile(
            id: 'image_${e.key}', url: e.value.path, type: MediaType.image)),
        ..._selectedDrawings.asMap().entries.map((e) => MediaFile(
            id: 'drawing_${e.key}',
            url: e.value.path,
            type: MediaType.drawing)),
      ];

      final diaryEntry = DiaryEntry(
        id: 'free_${DateTime.now().millisecondsSinceEpoch}',
        userId: authState.user!.uid,
        title: title,
        content: content,
        emotions: _selectedEmotions,
        emotionIntensities: _emotionIntensities,
        createdAt: _selectedDate,
        diaryType: DiaryType.free,
        isPublic: !_isPrivate,
        mediaFiles: mediaFiles,
      );

      await ref.read(firestoreProvider).saveDiary(diaryEntry);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('일기가 저장되었습니다')));
      context.pop();

      _checkMusicPrompt();
    } catch (e) {
      _showErrorDialog('일기 저장 중 오류가 발생했습니다: $e');
    }
  }

  void _checkMusicPrompt() {
    final musicSettings = ref.read(settingsProvider).settings.musicSettings;
    if (musicSettings.enabled &&
        musicSettings.promptOnEmotionChange &&
        musicSettings.showPostDiaryMusicTip) {
      final emotion =
          _selectedEmotions.isNotEmpty ? _selectedEmotions.first : '평온';
      ref.read(pendingMusicPromptProvider.notifier).state = PendingMusicPrompt(
        emotion: emotion,
        intensity: _emotionIntensities[emotion] ?? 5,
        source: EmotionSource.todayDiary,
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('입력 오류'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('확인'))
        ],
      ),
    );
  }

  void _showDiscardDialog(BuildContext context) {
    if (_titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('작성 취소'),
          content: const Text('작성 중인 내용이 있습니다. 정말로 나가시겠습니까?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('계속 작성')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('나가기')),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }
}
