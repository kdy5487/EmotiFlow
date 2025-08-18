import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../shared/widgets/buttons/emoti_button.dart';
import '../../../core/ai/openai/openai_service.dart';
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
  void _startNewConversation() {
    final viewModel = ref.read(diaryWriteProvider.notifier);
    viewModel.resetForm();
    viewModel.setIsChatMode(true);
    
    // AI 첫 메시지 추가
    final initialMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '안녕하세요! 오늘 하루는 어떠셨나요? 편하게 이야기해주세요.',
      isFromAI: true,
      timestamp: DateTime.now(),
    );
    
    viewModel.addChatMessage(initialMessage);
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
    _messageController.clear();
    
    // AI 응답 생성
    setState(() => _isTyping = true);
    
    try {
      final chatHistory = ref.read(diaryWriteProvider).chatHistory;
      final aiResponse = await OpenAIService.instance.generateChatReply(
        history: chatHistory,
        userMessage: message,
      );
      
      if (aiResponse != null && aiResponse.isNotEmpty) {
        final aiMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: aiResponse,
          isFromAI: true,
          timestamp: DateTime.now(),
        );
        
        viewModel.addChatMessage(aiMessage);
        
        // 충분한 대화가 진행되면 결과 표시
        if (chatHistory.length >= 6) {
          _generateDiaryFromChat();
        }
      }
    } catch (e) {
      print('AI 응답 생성 실패: $e');
      
      // 폴백 응답
      final fallbackMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '죄송해요, 잠시 문제가 있었어요. 계속 이야기해주세요.',
        isFromAI: true,
        timestamp: DateTime.now(),
      );
      
      viewModel.addChatMessage(fallbackMessage);
    } finally {
      setState(() => _isTyping = false);
    }
  }

  /// 대화에서 일기 생성
  Future<void> _generateDiaryFromChat() async {
    final viewModel = ref.read(diaryWriteProvider.notifier);
    final state = ref.read(diaryWriteProvider);
    
    if (state.chatHistory.isEmpty) return;
    
    // 간단한 일기 생성
    final userMessages = state.chatHistory
        .where((m) => !m.isFromAI)
        .map((m) => m.content)
        .join(' ');
    
    final title = userMessages.length > 20 
        ? '${userMessages.substring(0, 20)}...'
        : userMessages.isEmpty 
            ? 'AI와의 대화' 
            : userMessages;
    
    final content = state.chatHistory
        .map((m) => '${m.isFromAI ? "AI" : "나"}: ${m.content}')
        .join('\n\n');
    
    final emotions = _analyzeEmotionsFromText(userMessages);
    
    viewModel.updateTitle(title);
    viewModel.updateContent(content);
    viewModel.updateSelectedEmotions(emotions);
    
    setState(() => _showResult = true);
  }

  /// 텍스트에서 감정 분석
  List<String> _analyzeEmotionsFromText(String text) {
    final lowerText = text.toLowerCase();
    final emotions = <String>[];
    
    if (lowerText.contains('기쁘') || lowerText.contains('행복') || lowerText.contains('좋아')) {
      emotions.add('기쁨');
    }
    if (lowerText.contains('슬프') || lowerText.contains('우울') || lowerText.contains('힘들')) {
      emotions.add('슬픔');
    }
    if (lowerText.contains('화나') || lowerText.contains('분노') || lowerText.contains('짜증')) {
      emotions.add('분노');
    }
    if (lowerText.contains('평온') || lowerText.contains('차분') || lowerText.contains('편안')) {
      emotions.add('평온');
    }
    if (lowerText.contains('설렘') || lowerText.contains('기대') || lowerText.contains('떨림')) {
      emotions.add('설렘');
    }
    if (lowerText.contains('걱정') || lowerText.contains('불안') || lowerText.contains('긴장')) {
      emotions.add('걱정');
    }
    
    return emotions.isEmpty ? ['평온'] : emotions;
  }

  /// 일기 저장
  Future<void> _saveDiary() async {
    final viewModel = ref.read(diaryWriteProvider.notifier);
    final authState = ref.read(authProvider);
    final userId = authState.user?.uid ?? 'demo_user';
    
    try {
      final entry = viewModel.createDiaryEntry(userId);
      final diaryNotifier = ref.read(diaryProvider.notifier);
      
      await diaryNotifier.createDiaryEntry(entry);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI 대화 일기가 저장되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diaryWriteProvider);
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          'AI와 대화하기',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _startNewConversation,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: '새 대화 시작',
          ),
        ],
      ),
      body: Column(
        children: [
          // 대화 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // 카카오톡 스타일
              padding: const EdgeInsets.all(16),
              itemCount: state.chatHistory.reversed.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                final messages = state.chatHistory.reversed.toList();
                
                if (_isTyping && index == 0) {
                  return _buildTypingIndicator();
                }
                
                final messageIndex = _isTyping ? index - 1 : index;
                final message = messages[messageIndex];
                return _buildChatBubble(message);
              },
            ),
          ),
          
          // 결과 표시 영역
          if (_showResult) _buildResultSection(state),
          
          // 입력 영역
          _buildInputSection(),
        ],
      ),
    );
  }

  /// 채팅 버블
  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromAI 
            ? MainAxisAlignment.start 
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isFromAI) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isFromAI ? Colors.grey[100] : AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: message.isFromAI ? Colors.black87 : Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
          
          if (!message.isFromAI) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  /// 타이핑 인디케이터
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI가 답변 중',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 결과 섹션
  Widget _buildResultSection(DiaryWriteState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.green[600], size: 24),
              const SizedBox(width: 12),
              Text(
                'AI 대화 결과',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 제목
          if (state.title.isNotEmpty) ...[
            _buildResultItem('제목', state.title, Icons.title),
            const SizedBox(height: 12),
          ],
          
          // 감정
          if (state.selectedEmotions.isNotEmpty) ...[
            _buildResultItem('감정', state.selectedEmotions.join(', '), Icons.favorite),
            const SizedBox(height: 12),
          ],
          
          // 내용 요약
          if (state.content.isNotEmpty) ...[
            _buildResultItem(
              '내용 요약',
              state.content.length > 100 
                  ? '${state.content.substring(0, 100)}...'
                  : state.content,
              Icons.description,
            ),
            const SizedBox(height: 20),
          ],
          
          // 저장 버튼
          SizedBox(
            width: double.infinity,
            child: EmotiButton(
              text: '일기로 저장하기',
              onPressed: _saveDiary,
              type: EmotiButtonType.primary,
              icon: Icons.save,
            ),
          ),
        ],
      ),
    );
  }

  /// 결과 아이템
  Widget _buildResultItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green[600], size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(color: Colors.green[800]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 입력 섹션
  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isTyping ? null : _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
