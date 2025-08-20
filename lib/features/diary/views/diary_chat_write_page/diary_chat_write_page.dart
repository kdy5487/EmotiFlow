import '../../../../core/ai/gemini/gemini_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/diary_entry.dart';
import '../diary_write_page/diary_write_view_model.dart';
import '../../providers/diary_provider.dart';

/// AI 대화형 일기 작성 페이지
class DiaryChatWritePage extends ConsumerStatefulWidget {
  const DiaryChatWritePage({super.key});

  @override
  ConsumerState<DiaryChatWritePage> createState() => _DiaryChatWritePageState();
}

class _DiaryChatWritePageState extends ConsumerState<DiaryChatWritePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false;
  bool _showResult = false;
  final List<String> _conversationHistory = [];
  String? _selectedEmotion; // 선택된 감정 (하나만)
  bool _emotionSelected = false; // 감정이 선택되었는지 여부
  String? _aiGeneratedImageUrl; // AI 생성 이미지 URL

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewConversation();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 새 대화 시작
  void _startNewConversation() async {
    final viewModel = ref.read(diaryWriteProvider.notifier);
    viewModel.resetForm();
    viewModel.setIsChatMode(true);
    setState(() {
      _showResult = false;
      _conversationHistory.clear();
      _selectedEmotion = null;
      _emotionSelected = false;
    });
    _messageController.clear();
    
    // Gemini AI로 감정 선택 안내 메시지 시작
    try {
      final initialPrompt = await GeminiService.instance.generateEmotionSelectionPrompt();
      
      final initialMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: initialPrompt,
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      viewModel.addChatMessage(initialMessage);
    } catch (e) {
      // Fallback 메시지
    final initialMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '안녕하세요! 오늘 하루는 어떠셨나요? 아래 감정 중에서 선택하거나, 자유롭게 이야기해주세요! 😊',
      isFromAI: true,
      timestamp: DateTime.now(),
    );
    
    viewModel.addChatMessage(initialMessage);
    }
  }

  /// 메시지 전송
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final viewModel = ref.read(diaryWriteProvider.notifier);
    
    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      isFromAI: false,
      timestamp: DateTime.now(),
    );
    
    viewModel.addChatMessage(userMessage);
    _conversationHistory.add(message);
    _messageController.clear();
    
    // 감정이 선택되지 않았다면 메시지에서 감정 유추
    if (!_emotionSelected) {
      final extractedEmotion = _extractEmotionFromMessage(message);
      if (extractedEmotion != null) {
        setState(() {
                  _selectedEmotion = extractedEmotion;
          _emotionSelected = true;
        });
      }
      // 감정을 추출하지 못한 경우에만 감정 선택 UI 유지 (바로 숨기지 않음)
    }
    
    // AI 응답 생성
    setState(() => _isTyping = true);
    
    try {
      // 자연스러운 상담 대화 응답 생성
      final aiResponse = await GeminiService.instance.generateEmotionBasedQuestion(
        '자연스러운',
        message,
        _conversationHistory,
      );
      
      if (aiResponse.isNotEmpty) {
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: aiResponse,
          isFromAI: true,
          timestamp: DateTime.now(),
        );
        
        viewModel.addChatMessage(aiMessage);
        _conversationHistory.add(aiResponse);
      }
    } catch (e) {
      print('AI 응답 생성 실패: $e');
      
      // Fallback 응답
      const fallbackResponse = '흥미로운 이야기네요! 더 자세히 들려주세요.';
      
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: fallbackResponse,
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      viewModel.addChatMessage(aiMessage);
      _conversationHistory.add(fallbackResponse);
    } finally {
      setState(() => _isTyping = false);
      // 채팅 자동 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  /// 감정 선택 여부 확인
  bool _isEmotionSelection(String message) {
    // 8가지 감정에 대한 정확한 매칭
    final emotionMap = {
      '기쁨': ['기쁨', '기쁘', '행복', '즐거', '신나', '좋아', '웃겨', '재미있'],
      '슬픔': ['슬픔', '슬프', '우울', '속상', '눈물', '힘들', '아파', '서러워'],
      '분노': ['분노', '화나', '짜증', '열받', '화', '열받', '빡쳐', '열불'],
      '평온': ['평온', '차분', '고요', '안정', '편안', '평화', '조용', '잔잔'],
      '설렘': ['설렘', '설레', '기대', '떨리', '긴장', '두근', '떨려', '기대돼'],
      '걱정': ['걱정', '불안', '초조', '무서', '겁나', '불안', '초조', '긴장'],
      '감사': ['감사', '고마', '은혜', '축복', '감사해', '고마워', '은혜', '축복'],
      '지루함': ['지루함', '심심', '따분', '재미없', '지루해', '심심해', '따분해']
    };
    
    // 정확한 감정 매칭
    for (final entry in emotionMap.entries) {
      if (entry.value.any((keyword) => message.contains(keyword))) {
        return true;
      }
    }
    
    // 이모지 기반 감정 매칭
    final emojiEmotions = {
      '😊': '기쁨', '😄': '기쁨', '😃': '기쁨', '😁': '기쁨',
      '😢': '슬픔', '😭': '슬픔', '😔': '슬픔', '😞': '슬픔',
      '😠': '분노', '😡': '분노', '🤬': '분노', '😤': '분노',
      '😌': '평온', '😐': '평온', '🙂': '평온',
      '🤩': '설렘', '😍': '설렘', '🥰': '설렘',
      '😰': '걱정', '😨': '걱정', '😱': '걱정', '😥': '걱정',
      '🙏': '감사', '😇': '감사', '🥺': '감사',
      '😴': '지루함', '🥱': '지루함', '😑': '지루함', '😶': '지루함'
    };
    
    return emojiEmotions.keys.any((emoji) => message.contains(emoji));
  }

  /// 메시지에서 감정 추출
  String? _extractEmotionFromMessage(String message) {
    // 8가지 감정에 대한 정확한 매칭
    final emotionMap = {
      '기쁨': ['기쁨', '기쁘', '행복', '즐거', '신나', '좋아', '웃겨', '재미있'],
      '슬픔': ['슬픔', '슬프', '우울', '속상', '눈물', '힘들', '아파', '서러워'],
      '화남': ['화남', '화나', '짜증', '열받', '화', '열받', '빡쳐', '열불'],
      '평온': ['평온', '차분', '고요', '안정', '편안', '평화', '조용', '잔잔'],
      '설렘': ['설렘', '설레', '기대', '떨리', '긴장', '두근', '떨려', '기대돼'],
      '피곤함': ['피곤함', '피곤', '지쳐', '힘들어', '쉬고 싶어', '피곤한', '지친', '힘든'],
      '놀람': ['놀람', '놀라', '깜짝', '어이없어', '헐', '놀란', '깜짝 놀란', '어이없는'],
      '걱정': ['걱정', '불안', '초조', '무서', '겁나', '불안', '초조', '긴장']
    };
    
    // 정확한 감정 매칭
    for (final entry in emotionMap.entries) {
      if (entry.value.any((keyword) => message.contains(keyword))) {
        return entry.key;
      }
    }
    
    // 이모지 기반 감정 매칭
    final emojiEmotions = {
      '😊': '기쁨', '😄': '기쁨', '😃': '기쁨', '😁': '기쁨',
      '😢': '슬픔', '😭': '슬픔', '😔': '슬픔', '😞': '슬픔',
      '😠': '화남', '😡': '화남', '🤬': '화남', '😤': '화남',
      '😌': '평온', '😐': '평온', '🙂': '평온',
      '🤩': '설렘', '😍': '설렘', '🥰': '설렘',
      '😴': '피곤함', '🥱': '피곤함', '😑': '피곤함',
      '😲': '놀람', '😱': '놀람', '😨': '놀람',
      '😰': '걱정', '😥': '걱정', '😟': '걱정'
    };
    
    for (final entry in emojiEmotions.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // 감정을 찾을 수 없는 경우
    return null;
  }

  /// 일기 완성 및 요약 생성
  Future<void> _completeDiary() async {
    if (_conversationHistory.isEmpty) return;
    
    setState(() => _isTyping = true);
    
    try {
              final diarySummary = await GeminiService.instance.generateDiarySummary(
          _conversationHistory,
          _selectedEmotion ?? '자연스러운',
        );
      
      final summaryMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '📝 **오늘의 일기 완성**\n\n$diarySummary',
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      final viewModel = ref.read(diaryWriteProvider.notifier);
      viewModel.addChatMessage(summaryMessage);
      
      setState(() {
        _showResult = true;
      });
      
      setState(() => _isTyping = false);
      
      // 별도 다이얼로그로 결과 표시
      _showDiaryResultDialog(diarySummary);
      
    } catch (e) {
      print('일기 요약 생성 실패: $e');
      setState(() => _isTyping = false);
      
      // 오류 시 간단한 다이얼로그 표시
      _showDiaryResultDialog('오늘 하루도 수고하셨습니다. 대화를 통해 일기를 정리하는 것은 좋은 습관이에요.');
    }
  }

  /// 일기 결과 다이얼로그 표시
  void _showDiaryResultDialog(String diarySummary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.primary),
              SizedBox(width: 8),
              Text('오늘의 일기'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedEmotion != null) ...[
                Row(
                  children: [
                    const Icon(Icons.emoji_emotions, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 감정: $_selectedEmotion',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diarySummary,
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'AI 그림 생성',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI가 오늘의 감정과 경험을 바탕으로 그림을 그려드릴 수 있어요!',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _generateAIImage(diarySummary),
                                icon: const Icon(Icons.brush),
                                label: const Text('AI가 그림 그려주기'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewConversation(); // 새 대화 시작
              },
              child: const Text('새 일기 작성'),
            ),
            ElevatedButton(
              onPressed: () async {
                // 채팅 일기를 일기 목록에 저장
                await _saveChatDiary(diarySummary);
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // 채팅 페이지 닫기
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('저장 후 완료'),
            ),
          ],
        );
      },
    );
  }

  /// 스크롤을 하단으로 이동 (최신 메시지로)
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, // 최신 메시지가 아래에 있음
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(diaryWriteProvider);
    final chatHistory = chatState.chatHistory;
    
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드 터치시 화면 위로 밀림 (필수 기능)
      appBar: AppBar(
        title: const Text('AI와 일기 작성'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 새로고침 버튼
          IconButton(
            onPressed: _startNewConversation,
            icon: const Icon(Icons.refresh),
            tooltip: '새 대화 시작',
          ),
          if (!_showResult)
            TextButton(
              onPressed: _completeDiary,
              child: const Text('일기 완성'),
          ),
        ],
      ),
      body: Column(
                children: [
          // 채팅 메시지 목록
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              reverse: false, // 카카오톡처럼 오래된 채팅이 위로, 최신이 아래로
              itemCount: chatHistory.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                if (index == chatHistory.length && _isTyping) {
                          return _buildTypingIndicator();
                }
                
                if (index >= chatHistory.length) {
                  return const SizedBox.shrink();
                }
                
                final message = chatHistory[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // 감정 선택 UI (첫 메시지 이후에만 표시, 키보드가 활성화되지 않았을 때만)
          if (!_emotionSelected && chatHistory.isNotEmpty && MediaQuery.of(context).viewInsets.bottom == 0)
            _buildEmotionSelectionUI(),
          
          // 메시지 입력 영역
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 16,
            child: Icon(Icons.psychology, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI가 생각하고 있어요...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 감정 선택 UI
  Widget _buildEmotionSelectionUI() {
    final emotions = [
      {'name': '기쁨', 'icon': Icons.sentiment_very_satisfied, 'color': AppTheme.joy},
      {'name': '사랑', 'icon': Icons.favorite, 'color': AppTheme.love},
      {'name': '평온', 'icon': Icons.sentiment_satisfied, 'color': AppTheme.calm},
      {'name': '슬픔', 'icon': Icons.sentiment_dissatisfied, 'color': AppTheme.sadness},
      {'name': '분노', 'icon': Icons.sentiment_very_dissatisfied, 'color': AppTheme.anger},
      {'name': '두려움', 'icon': Icons.visibility, 'color': AppTheme.fear},
      {'name': '놀람', 'icon': Icons.sentiment_satisfied_alt, 'color': AppTheme.sadness},
      {'name': '중립', 'icon': Icons.sentiment_neutral, 'color': AppTheme.neutral},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 감정을 선택해주세요',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: emotions.map((emotion) {
              final isSelected = _selectedEmotion == emotion['name'] as String;
              
              return GestureDetector(
                onTap: () => _selectEmotion(emotion['name'] as String),
                                  child: Container(
                    width: 80, // 고정 너비로 통일
                    height: 36, // 고정 높이로 통일
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primary 
                          : (emotion['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primary 
                            : (emotion['color'] as Color).withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          emotion['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : emotion['color'] as Color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            emotion['name'] as String,
                            style: AppTypography.bodySmall.copyWith(
                              color: isSelected ? Colors.white : emotion['color'] as Color,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              );
            }).toList(),
          ),
          

          
          const SizedBox(height: 12),
          Text(
            '감정을 선택하거나 자유롭게 이야기해주세요!',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.grey[400],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 감정 선택 처리 (하나만)
  void _selectEmotion(String emotion) {
    setState(() {
      if (_selectedEmotion == emotion) {
        // 같은 감정을 다시 클릭하면 선택 해제
        _selectedEmotion = null;
        _emotionSelected = false;
      } else {
        // 새로운 감정 선택
        _selectedEmotion = emotion;
        _emotionSelected = true;
      }
    });
    
    // 감정 선택 후 AI가 맞춤형 질문하도록
    if (_selectedEmotion != null) {
      _sendEmotionBasedQuestion(emotion);
    }
  }

  /// 감정 기반 AI 질문 전송
  Future<void> _sendEmotionBasedQuestion(String emotion) async {
    final viewModel = ref.read(diaryWriteProvider.notifier);
    
    // AI가 감정에 맞는 맞춤형 질문 생성
    setState(() => _isTyping = true);
    
    try {
      final aiResponse = await GeminiService.instance.generateEmotionBasedQuestion(
        emotion,
        '감정: $emotion',
        _conversationHistory,
      );
      
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      viewModel.addChatMessage(aiMessage);
      _scrollToBottom();
    } catch (e) {
      // Fallback 응답
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '$emotion한 하루를 보내셨군요. 더 자세히 들려주세요!',
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      viewModel.addChatMessage(aiMessage);
      _scrollToBottom();
    } finally {
      setState(() => _isTyping = false);
    }
  }

  /// 채팅 일기를 일기 목록에 저장
  Future<void> _saveChatDiary(String diarySummary) async {
    try {
      final authState = ref.read(authProvider);
      
      // 현재 사용자 ID 가져오기
      final userId = authState.user?.uid ?? 'demo_user';
      
      // 일기 데이터 생성
      final diaryEntry = DiaryEntry(
        title: _generateDiaryTitle(diarySummary),
        content: diarySummary,
        emotions: _selectedEmotion != null ? [_selectedEmotion!] : [],
        emotionIntensities: _selectedEmotion != null ? {_selectedEmotion!: 8} : {},
        tags: _extractTagsFromSummary(diarySummary),
        diaryType: DiaryType.aiChat, // AI 대화형 일기
        isPublic: false,
        userId: userId, // 실제 사용자 ID 또는 더미 ID
        chatHistory: _conversationHistory.map((msg) => ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: msg,
          isFromAI: false,
          timestamp: DateTime.now(),
        )).toList(),
        aiAnalysis: null,
        mediaFiles: [],
        weather: null,
        location: null,
        metadata: {
          'isChatDiary': true, // 채팅 일기 구분을 위한 메타데이터
          'conversationCount': _conversationHistory.length,
          'aiGeneratedImage': _aiGeneratedImageUrl, // AI 생성 이미지 URL
        },
      );
      
      // Riverpod을 사용하여 일기 저장
      final diaryNotifier = ref.read(diaryProvider.notifier);
      await diaryNotifier.createDiaryEntry(diaryEntry);
      
      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('채팅 일기가 저장되었습니다!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      print('채팅 일기 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('일기 저장에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 일기 제목 생성
  String _generateDiaryTitle(String summary) {
    if (summary.length > 20) {
      return '${summary.substring(0, 20)}...';
    }
    return summary;
  }

  /// AI 이미지 생성
  Future<void> _generateAIImage(String diarySummary) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // AI 이미지 생성 요청 (채팅 내용과 감정 기반)
              final imageUrl = await GeminiService.instance.generateImage(
          diarySummary, 
          _selectedEmotion ?? '자연스러운', 
          _conversationHistory
        );
      
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
      // 결과 표시
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('AI가 그린 그림'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.error, size: 100, color: Colors.red),
                  )
                else
                  const Text('이미지 생성에 실패했습니다.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          ),
        );
      }
      
      // AI 생성 이미지 URL을 일기 저장시 사용할 수 있도록 저장
      if (imageUrl != null) {
        setState(() {
          _aiGeneratedImageUrl = imageUrl;
        });
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // 에러 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 일기 내용에서 태그 추출
  List<String> _extractTagsFromSummary(String summary) {
    final tags = <String>[];
    
    // 감정 관련 태그
            if (_selectedEmotion != null) {
          tags.add(_selectedEmotion!);
        }
    
    // 일반적인 태그들
    if (summary.contains('일') || summary.contains('하루')) tags.add('일상');
    if (summary.contains('친구') || summary.contains('사람')) tags.add('사람');
    if (summary.contains('음식') || summary.contains('밥')) tags.add('음식');
    if (summary.contains('운동') || summary.contains('걷기')) tags.add('운동');
    if (summary.contains('일') || summary.contains('업무')) tags.add('업무');
    
    return tags.take(5).toList(); // 최대 5개 태그
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isAI = message.isFromAI;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          if (isAI) ...[
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
        const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAI 
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isAI ? AppColors.textPrimary : Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ),
          
          if (!isAI) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: AppColors.secondary,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '자유롭게 이야기해주세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              onTapOutside: (event) {
                // 외부 터치 시 키보드 내려감
                FocusScope.of(context).unfocus();
              },
              onEditingComplete: () {
                // 편집 완료 시 키보드 내려감
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}