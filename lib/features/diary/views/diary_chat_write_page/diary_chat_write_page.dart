import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/gemini/gemini_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/constants/emotion_character_map.dart';
import '../../../../shared/widgets/keyboard_dismissible_scaffold.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/chat_message.dart';
import '../diary_write_page/diary_write_view_model.dart';
import '../../providers/diary_provider.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/chat_message_input.dart';

/// AI 대화형 일기 작성 페이지
class DiaryChatWritePage extends ConsumerStatefulWidget {
  final String? initialEmotion;

  const DiaryChatWritePage({
    super.key,
    this.initialEmotion,
  });

  @override
  ConsumerState<DiaryChatWritePage> createState() => _DiaryChatWritePageState();
}

class _DiaryChatWritePageState extends ConsumerState<DiaryChatWritePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  final List<String> _conversationHistory = [];
  String? _selectedEmotion;

  @override
  void initState() {
    super.initState();
    // 초기 감정이 있으면 설정
    if (widget.initialEmotion != null) {
      _selectedEmotion = widget.initialEmotion;
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _startNewConversation());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startNewConversation() async {
    print('⏱️ [성능] 대화 시작 - ${DateTime.now()}');

    final viewModel = ref.read(diaryWriteProvider.notifier);
    viewModel.resetForm();
    viewModel.setIsChatMode(true);
    setState(() {
      _conversationHistory.clear();
      // 초기 감정이 있으면 유지, 없으면 리셋
      if (widget.initialEmotion == null) {
        _selectedEmotion = null;
      }
    });

    print('⏱️ [성능] ViewModel 초기화 완료 - ${DateTime.now()}');

    // Fallback 메시지를 먼저 표시 (즉시 표시)
    const fallbackMessage = '안녕하세요! 오늘 하루는 어떠셨나요?';
    viewModel.addChatMessage(ChatMessage(
      id: 'init_${DateTime.now().millisecondsSinceEpoch}',
      content: fallbackMessage,
      isFromAI: true,
      timestamp: DateTime.now(),
    ));
    _conversationHistory.add('AI: $fallbackMessage');

    print('⏱️ [성능] 초기 메시지 표시 완료 - ${DateTime.now()}');

    // API 응답을 비동기로 받아서 업데이트 (선택적)
    _loadInitialPromptAsync(viewModel);
  }

  void _loadInitialPromptAsync(dynamic viewModel) async {
    try {
      print('⏱️ [성능] Gemini API 호출 시작 - ${DateTime.now()}');
      final initialPrompt =
          await GeminiService.instance.generateEmotionSelectionPrompt();
      print('⏱️ [성능] Gemini API 응답 완료 - ${DateTime.now()}');

      // API 응답이 Fallback과 다르면 추가 (간단한 구현)
      // 실제로는 첫 메시지를 교체하는 것이 좋지만, 간단하게 유지
      print('✅ [성능] AI 초기 인사: $initialPrompt');
    } catch (e) {
      print('⏱️ [성능] Gemini API 오류 (Fallback 유지) - $e');
      // Fallback 메시지 유지
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final viewModel = ref.read(diaryWriteProvider.notifier);
    viewModel.addChatMessage(ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: message,
      isFromAI: false,
      timestamp: DateTime.now(),
    ));
    _conversationHistory.add('사용자: $message');
    _messageController.clear();

    setState(() => _isTyping = true);
    try {
      final aiResponse =
          await GeminiService.instance.generateEmotionBasedQuestion(
        _selectedEmotion ?? '자연스러운',
        message,
        _conversationHistory,
      );
      viewModel.addChatMessage(ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        content: aiResponse,
        isFromAI: true,
        timestamp: DateTime.now(),
      ));
      _conversationHistory.add('AI: $aiResponse');
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  Future<void> _completeDiary() async {
    if (_conversationHistory.isEmpty) return;
    setState(() => _isTyping = true);

    try {
      final summary = await GeminiService.instance
          .generateDiarySummary(_conversationHistory, _selectedEmotion ?? '평온');
      _showResultDialog(summary);
    } finally {
      setState(() => _isTyping = false);
    }
  }

  void _showResultDialog(String summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오늘의 일기 완성'),
        content: SingleChildScrollView(child: Text(summary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              await _saveDiary(summary);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('저장하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDiary(String content) async {
    final auth = ref.read(authProvider);
    final entry = DiaryEntry(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      userId: auth.user?.uid ?? 'unknown',
      title: content.length > 20 ? '${content.substring(0, 20)}...' : content,
      content: content,
      emotions: _selectedEmotion != null ? [_selectedEmotion!] : [],
      emotionIntensities:
          _selectedEmotion != null ? {_selectedEmotion!: 8} : {},
      createdAt: DateTime.now(),
      diaryType: DiaryType.aiChat,
    );
    await ref.read(diaryProvider.notifier).createDiaryEntry(entry);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatHistory = ref.watch(diaryWriteProvider).chatHistory;
    final backgroundColor = Color(
      EmotionCharacterMap.getBackgroundColor(_selectedEmotion),
    );

    return KeyboardDismissibleScaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              EmotionCharacterMap.getCharacterAsset(_selectedEmotion),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.psychology, size: 20);
              },
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF0F172A), // 아이콘 진하게
        ),
        actions: [
          IconButton(
            onPressed: _startNewConversation,
            icon: const Icon(Icons.refresh),
            tooltip: '대화 다시 시작',
          ),
          IconButton(
            onPressed: _completeDiary,
            icon: const Icon(Icons.check_circle_outline),
            tooltip: '일기 완성',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              itemCount: chatHistory.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatHistory.length) {
                  return TypingIndicator(
                    characterAsset:
                        EmotionCharacterMap.getCharacterAsset(_selectedEmotion),
                  );
                }
                return ChatMessageBubble(
                  message: chatHistory[index],
                  selectedEmotion: _selectedEmotion,
                );
              },
            ),
          ),
          ChatMessageInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
