import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/shared/widgets/inputs/emoti_textfield.dart';

class DiaryWritePage extends ConsumerStatefulWidget {
  const DiaryWritePage({super.key});

  @override
  ConsumerState<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends ConsumerState<DiaryWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedEmotions = [];
  bool _isPrivate = false;
  bool _allowAI = false;
  
  final List<Map<String, dynamic>> _availableEmotions = [
    {'name': '기쁨', 'color': AppTheme.joy, 'icon': Icons.sentiment_satisfied},
    {'name': '사랑', 'color': AppTheme.love, 'icon': Icons.favorite},
    {'name': '평온', 'color': AppTheme.calm, 'icon': Icons.sentiment_neutral},
    {'name': '슬픔', 'color': AppTheme.sadness, 'icon': Icons.sentiment_dissatisfied},
    {'name': '분노', 'color': AppTheme.anger, 'icon': Icons.sentiment_very_dissatisfied},
    {'name': '두려움', 'color': AppTheme.fear, 'icon': Icons.sentiment_neutral},
    {'name': '놀람', 'color': AppTheme.surprise, 'icon': Icons.sentiment_satisfied_alt},
    {'name': '중립', 'color': AppTheme.neutral, 'icon': Icons.sentiment_neutral},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _moodController.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 선택
            _buildDateSelector(),
            const SizedBox(height: 24),
            
            // 제목 입력
            _buildTitleInput(),
            const SizedBox(height: 24),
            
            // 감정 선택
            _buildEmotionSelector(),
            const SizedBox(height: 24),
            
            // 내용 입력
            _buildContentInput(),
            const SizedBox(height: 24),
            
            // 기분 점수
            _buildMoodScore(),
            const SizedBox(height: 24),
            
            // 설정 옵션
            _buildSettingsOptions(),
            const SizedBox(height: 24),
            
            // 저장 버튼
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return EmotiCard(
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: const Icon(Icons.calendar_today, size: 18, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '날짜',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return EmotiTextField(
      label: '제목',
      hint: '오늘 하루를 한 줄로 요약해보세요',
      controller: _titleController,
      maxLines: 1,
    );
  }

  Widget _buildEmotionSelector() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 감정',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableEmotions.map((emotion) {
                final isSelected = _selectedEmotions.contains(emotion['name']);
                return GestureDetector(
                  onTap: () => _toggleEmotion(emotion['name']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? emotion['color'] : AppTheme.textSecondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          emotion['icon'],
                          color: isSelected ? AppTheme.textPrimary : Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          emotion['name'],
                          style: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    return EmotiTextField(
      label: '일기 내용',
      hint: '오늘 있었던 일과 느낀 감정을 자유롭게 적어보세요...',
      controller: _contentController,
      maxLines: 10,
    );
  }

  Widget _buildMoodScore() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기분 점수',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: EmotiButton(
                    text: '😢',
                    onPressed: () => _setMoodScore(1),
                    type: EmotiButtonType.outline,
                    size: EmotiButtonSize.medium,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: EmotiButton(
                    text: '😐',
                    onPressed: () => _setMoodScore(5),
                    type: EmotiButtonType.outline,
                    size: EmotiButtonSize.medium,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: EmotiButton(
                    text: '😊',
                    onPressed: () => _setMoodScore(10),
                    type: EmotiButtonType.outline,
                    size: EmotiButtonSize.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
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

  void _toggleEmotion(String emotionName) {
    setState(() {
      if (_selectedEmotions.contains(emotionName)) {
        _selectedEmotions.remove(emotionName);
      } else {
        _selectedEmotions.add(emotionName);
      }
    });
  }

  void _setMoodScore(int score) {
    // 기분 점수 설정 로직
    print('기분 점수: $score');
  }

  void _saveDiary() {
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

    // 일기 저장 로직
    print('일기 저장 완료');
    print('제목: ${_titleController.text.trim()}');
    print('내용: ${_contentController.text.trim()}');
    print('날짜: $_selectedDate');
    print('감정: $_selectedEmotions');
    print('비공개: $_isPrivate');
    print('AI 분석: $_allowAI');
    
    // TODO: 실제 저장 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일기가 저장되었습니다')),
    );
    
    context.pop();
  }

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