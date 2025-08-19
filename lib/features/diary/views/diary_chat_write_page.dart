import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../shared/widgets/buttons/emoti_button.dart';
import '../../../core/ai/gemini/gemini_service.dart';
import '../models/diary_entry.dart';
import '../viewmodels/diary_write_view_model.dart';
import '../providers/diary_provider.dart';
import '../../../core/providers/auth_provider.dart';

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
  String? _selectedEmotion;
  bool _emotionSelected = false;
  List<String> _conversationHistory = [];

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

  /// 새 대화 시작 - 감정 선택 우선
  void _startNewConversation() async {
    final viewModel = ref.read(diaryWriteProvider.notifier);
    viewModel.resetForm();
    viewModel.setIsChatMode(true);
    setState(() {
      _showResult = false;
      _selectedEmotion = null;
      _emotionSelected = false;
      _conversationHistory.clear();
    });
    _messageController.clear();
    
    // Gemini AI로 감정 선택 초기 질문 생성
    try {
      final emotionPrompt = await GeminiService.instance.generateEmotionSelectionPrompt();
      
      final initialMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: emotionPrompt,
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      viewModel.addChatMessage(initialMessage);
    } catch (e) {
      // Fallback 메시지
      final initialMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '안녕하세요! 오늘 하루는 어뭇셨나요? 어떤 감정을 느끼고 계신지 궁금해요. 😊',
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
    
    // AI 응답 생성
    setState(() => _isTyping = true);
    
    try {
      String aiResponse;
      
      if (!_emotionSelected) {
        // 감정이 선택되지 않은 경우, 감정 기반 질문 생성
        aiResponse = await GeminiService.instance.generateEmotionBasedQuestion(
          _selectedEmotion ?? '평온',
          message,
          _conversationHistory,
        );
        
        // 감정이 선택되었는지 확인
        if (_isEmotionSelection(message)) {
          setState(() {
            _emotionSelected = true;
            _selectedEmotion = _extractEmotionFromMessage(message);
          });
        }
      } else {
        // 감정이 선택된 경우, 일반적인 대화 응답
        aiResponse = await GeminiService.instance.generateEmotionBasedQuestion(
          _selectedEmotion!,
          message,
          _conversationHistory,
        );
      }
      
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
      final fallbackResponse = _emotionSelected 
          ? '흥미로운 이야기네요! 더 자세히 들려주세요.'
          : '어떤 감정을 느끼고 계신지 더 구체적으로 말씀해주세요.';
      
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
      _scrollToBottom();
    }
  }

  /// 감정 선택 여부 확인
  bool _isEmotionSelection(String message) {
    final emotionKeywords = [
      '기쁨', '기쁘', '행복', '즐거', '신나',
      '슬픔', '슬프', '우울', '속상', '눈물',
      '분노', '화나', '짜증', '열받', '화',
      '평온', '차분', '고요', '안정', '편안',
      '설렘', '설레', '기대', '떨리', '긴장',
      '걱정', '불안', '초조', '무서',
      '감사', '고마', '은혜', '축복',
      '지루함', '심심', '따분', '재미없'
    ];
    
    return emotionKeywords.any((keyword) => message.contains(keyword));
  }

  /// 메시지에서 감정 추출
  String _extractEmotionFromMessage(String message) {
    if (message.contains('기쁘') || message.contains('행복') || message.contains('즐거') || message.contains('신나')) {
      return '기쁨';
    } else if (message.contains('슬프') || message.contains('우울') || message.contains('속상')) {
      return '슬픔';
    } else if (message.contains('화나') || message.contains('짜증') || message.contains('열받')) {
      return '분노';
    } else if (message.contains('차분') || message.contains('고요') || message.contains('안정')) {
      return '평온';
    } else if (message.contains('설레') || message.contains('기대') || message.contains('떨리')) {
      return '설렘';
    } else if (message.contains('걱정') || message.contains('불안') || message.contains('초조')) {
      return '걱정';
    } else if (message.contains('감사') || message.contains('고마') || message.contains('은혜')) {
      return '감사';
    } else if (message.contains('지루') || message.contains('심심') || message.contains('따분')) {
      return '지루함';
    }
    return '평온';
  }

  /// 일기 완성 및 요약 생성
  Future<void> _completeDiary() async {
    if (_conversationHistory.isEmpty) return;
    
    setState(() => _isTyping = true);
    
    try {
      final selectedEmotion = _selectedEmotion ?? '평온';
      final diarySummary = await GeminiService.instance.generateDiarySummary(
        _conversationHistory,
        selectedEmotion,
      );
      
      final summaryMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '📝 **오늘의 일기 요약**\n\n$diarySummary',
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      final viewModel = ref.read(diaryWriteProvider.notifier);
      viewModel.addChatMessage(summaryMessage);
      
      setState(() {
        _showResult = true;
      });
      
      _scrollToBottom();
    } catch (e) {
      print('일기 요약 생성 실패: $e');
      
      final fallbackSummary = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '📝 **오늘의 일기 요약**\n\n오늘 하루도 수고하셨습니다. 감정을 정리하는 것은 좋은 습관이에요.',
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      final viewModel = ref.read(diaryWriteProvider.notifier);
      viewModel.addChatMessage(fallbackSummary);
      
      setState(() {
        _showResult = true;
      });
    } finally {
      setState(() => _isTyping = false);
    }
  }

  /// 스크롤을 하단으로 이동
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
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
      appBar: AppBar(
        title: const Text('AI와 일기 작성'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_emotionSelected && !_showResult)
            TextButton(
              onPressed: _completeDiary,
              child: const Text('일기 완성'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 감정 선택 상태 표시
          if (_selectedEmotion != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.emoji_emotions, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '선택된 감정: $_selectedEmotion',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          // 채팅 메시지 목록
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatHistory.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatHistory.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                
                final message = chatHistory[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // 메시지 입력 영역
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isAI = message.isFromAI;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAI) ...[
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAI 
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isAI ? AppColors.textPrimary : Colors.white,
                ),
              ),
            ),
          ),
          
          if (!isAI) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: Colors.white, size: 20),
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
                hintText: _emotionSelected 
                    ? '더 자세히 이야기해주세요...'
                    : '감정을 표현해주세요...',
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
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(Icons.send, color: AppColors.primary),
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
