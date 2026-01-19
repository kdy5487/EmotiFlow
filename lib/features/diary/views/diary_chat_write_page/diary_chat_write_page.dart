import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/gemini/gemini_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/chat_message.dart';
import '../diary_write_page/diary_write_view_model.dart';
import '../../providers/diary_provider.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/chat_emotion_selector.dart';
import 'widgets/chat_message_input.dart';

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
  final List<String> _conversationHistory = [];
  String? _selectedEmotion;
  bool _emotionSelected = false;

  @override
  void initState() {
    super.initState();
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
    // 디버깅을 위해 모델 리스트 먼저 조회
    await GeminiService.instance.listAvailableModels();

    final viewModel = ref.read(diaryWriteProvider.notifier);
    viewModel.resetForm();
    viewModel.setIsChatMode(true);
    setState(() {
      _conversationHistory.clear();
      _selectedEmotion = null;
      _emotionSelected = false;
    });

    try {
      final initialPrompt =
          await GeminiService.instance.generateEmotionSelectionPrompt();
      viewModel.addChatMessage(ChatMessage(
        id: 'init_${DateTime.now().millisecondsSinceEpoch}',
        content: initialPrompt,
        isFromAI: true,
        timestamp: DateTime.now(),
      ));
      _conversationHistory.add('AI: $initialPrompt');
    } catch (e) {
      viewModel.addChatMessage(ChatMessage(
        id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        content: '안녕하세요! 오늘 하루는 어떠셨나요? 마음속 이야기를 들려주세요. 😊',
        isFromAI: true,
        timestamp: DateTime.now(),
      ));
      _conversationHistory.add('AI: 안녕하세요! 오늘 하루는 어떠셨나요? 마음속 이야기를 들려주세요. 😊');
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

  void _selectEmotion(String emotion) async {
    setState(() {
      _selectedEmotion = emotion;
      _emotionSelected = true;
      _isTyping = true;
    });

    final viewModel = ref.read(diaryWriteProvider.notifier);
    try {
      final aiResponse =
          await GeminiService.instance.generateEmotionBasedQuestion(
        emotion,
        '감정 선택: $emotion',
        _conversationHistory,
      );
      viewModel.addChatMessage(ChatMessage(
        id: 'emotion_q_${DateTime.now().millisecondsSinceEpoch}',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('에모티와 대화하기'),
        actions: [
          IconButton(
              onPressed: _startNewConversation,
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: _completeDiary,
              icon: const Icon(Icons.check_circle_outline)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: chatHistory.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatHistory.length) return const TypingIndicator();
                return ChatMessageBubble(message: chatHistory[index]);
              },
            ),
          ),
          if (!_emotionSelected && chatHistory.isNotEmpty)
            ChatEmotionSelector(
                selectedEmotion: _selectedEmotion,
                onEmotionSelected: _selectEmotion),
          ChatMessageInput(
              controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }
}
