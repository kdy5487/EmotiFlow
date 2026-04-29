import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ai/gemini/gemini_service.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/usage_limit_service.dart';
import '../../../../shared/constants/emotion_character_map.dart';
import '../../../../shared/widgets/keyboard_dismissible_scaffold.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ai_analysis.dart';
import '../diary_write_page/diary_write_view_model.dart';
import '../../providers/diary_provider.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/chat_message_input.dart';

/// AI ??? ?? ?? ???
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

  // ?? fallback ??? ID ? API ?? ?? ? ??
  String? _initMsgId;

  @override
  void initState() {
    super.initState();
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
    final viewModel = ref.read(diaryWriteProvider.notifier);
    viewModel.resetForm();
    viewModel.setIsChatMode(true);
    setState(() {
      _conversationHistory.clear();
      if (widget.initialEmotion == null) {
        _selectedEmotion = null;
      }
    });

    // Gemini API ?? ??? ??? ?? ???
    _initMsgId = 'init_${DateTime.now().millisecondsSinceEpoch}';
    const fallbackMessage = '?????! ?? ?? ??????';
    viewModel.addChatMessage(ChatMessage(
      id: _initMsgId!,
      content: fallbackMessage,
      isFromAI: true,
      timestamp: DateTime.now(),
    ));
    _conversationHistory.add('AI: $fallbackMessage');

    // ?? ?? ? ??? ?? ?? (1?)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await UsageLimitService.instance.showPolicyIfNeeded(
          context,
          UsageType.geminiCall,
        );
      }
    });

    _loadInitialPromptAsync(viewModel);
  }

  void _loadInitialPromptAsync(dynamic viewModel) async {
    try {
      final initialPrompt =
          await GeminiService.instance.generateEmotionSelectionPrompt();

      if (!mounted) return;

      // fallback ???? ?? Gemini API ???? ??
      if (_initMsgId != null) {
        viewModel.removeChatMessage(_initMsgId!);
        viewModel.addChatMessage(ChatMessage(
          id: 'init_api_${DateTime.now().millisecondsSinceEpoch}',
          content: initialPrompt,
          isFromAI: true,
          timestamp: DateTime.now(),
        ));
        _conversationHistory.removeWhere((m) => m.startsWith('AI:'));
        _conversationHistory.insert(0, 'AI: $initialPrompt');
      }
    } catch (e) {
      // ?? ? fallback ??? ??
      debugPrint('?? AI ???? ?? ?? (fallback ??): $e');
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
    _conversationHistory.add('???: $message');
    _messageController.clear();

    setState(() => _isTyping = true);
    try {
      final aiResponse =
          await GeminiService.instance.generateEmotionBasedQuestion(
        _selectedEmotion ?? '??',
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
          .generateDiarySummary(_conversationHistory, _selectedEmotion ?? '??');
      _showResultDialog(summary);
    } finally {
      setState(() => _isTyping = false);
    }
  }

  void _showResultDialog(String summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('??? ?? ??'),
        content: SingleChildScrollView(child: Text(summary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('??')),
          ElevatedButton(
            onPressed: () async {
              final diaryId = await _saveDiary(summary);
              if (mounted) {
                Navigator.pop(context);
                context.go('/diaries/$diaryId');
              }
            },
            child: const Text('????'),
          ),
        ],
      ),
    );
  }

  Future<String> _saveDiary(String content) async {
    final auth = ref.read(authProvider);
    final geminiService = GeminiService.instance;
    final entryId = 'chat_${DateTime.now().millisecondsSinceEpoch}';

    final tempEntry = DiaryEntry(
      id: entryId,
      userId: auth.user?.uid ?? 'unknown',
      title: content.length > 20 ? '${content.substring(0, 20)}...' : content,
      content: content,
      emotions: _selectedEmotion != null ? [_selectedEmotion!] : [],
      emotionIntensities: _selectedEmotion != null ? {_selectedEmotion!: 8} : {},
      createdAt: DateTime.now(),
      diaryType: DiaryType.aiChat,
      chatHistory: ref.read(diaryWriteProvider).chatHistory,
    );

    final detailedAdvice = await geminiService.generateDetailedAdvice(tempEntry);
    final detailedSummary =
        await geminiService.generateDetailedDiarySummary(tempEntry);

    final aiAnalysis = AIAnalysis(
      id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
      summary: detailedSummary,
      keywords: [],
      emotionScores: {},
      advice: detailedAdvice,
      actionItems: [],
      moodTrend: '',
      analyzedAt: DateTime.now(),
    );

    final entry = DiaryEntry(
      id: entryId,
      userId: auth.user?.uid ?? 'unknown',
      title: tempEntry.title,
      content: content,
      emotions: tempEntry.emotions,
      emotionIntensities: tempEntry.emotionIntensities,
      createdAt: tempEntry.createdAt,
      diaryType: DiaryType.aiChat,
      chatHistory: tempEntry.chatHistory,
      aiAnalysis: aiAnalysis,
    );
    await ref.read(diaryProvider.notifier).createDiaryEntry(entry);
    return entryId;
  }

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
          color: Color(0xFF0F172A),
        ),
        actions: [
          IconButton(
            onPressed: _startNewConversation,
            icon: const Icon(Icons.refresh),
            tooltip: '?? ?? ??',
          ),
          IconButton(
            onPressed: _completeDiary,
            icon: const Icon(Icons.check_circle_outline),
            tooltip: '?? ??',
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
