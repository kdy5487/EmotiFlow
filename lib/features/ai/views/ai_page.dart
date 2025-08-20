import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';

class AIPage extends ConsumerStatefulWidget {
  const AIPage({super.key});

  @override
  ConsumerState<AIPage> createState() => _AIPageState();
}

class _AIPageState extends ConsumerState<AIPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: '안녕하세요! 저는 당신의 감정 파트너 AI입니다. 오늘 하루는 어땠나요?',
      isAI: true,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 사용자 메시지 추가
    _messages.add(ChatMessage(
      text: text,
      isAI: false,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();
    setState(() {});

    // AI 응답 시뮬레이션
    _simulateAIResponse(text);
  }

  void _simulateAIResponse(String userMessage) {
    setState(() {
      _isLoading = true;
    });

    // 실제 AI 서비스 연동 시에는 여기서 API 호출
    Future.delayed(const Duration(seconds: 2), () {
      String aiResponse = _generateAIResponse(userMessage);
      
      setState(() {
        _messages.add(ChatMessage(
          text: aiResponse,
          isAI: true,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    });
  }

  String _generateAIResponse(String userMessage) {
    // 간단한 응답 생성 로직 (실제로는 AI 모델 사용)
    if (userMessage.contains('기쁘') || userMessage.contains('좋') || userMessage.contains('행복')) {
      return '정말 기쁜 일이 있었나요? 그런 긍정적인 감정을 느끼는 것은 정말 좋은 일이에요. 더 자세히 이야기해주세요!';
    } else if (userMessage.contains('슬프') || userMessage.contains('우울') || userMessage.contains('힘들')) {
      return '힘든 시간을 보내고 계시는군요. 그런 감정을 느끼는 것은 자연스러운 일이에요. 함께 이야기해보아요.';
    } else if (userMessage.contains('화나') || userMessage.contains('짜증') || userMessage.contains('분노')) {
      return '화가 나는 일이 있었나요? 그런 감정을 표현하는 것도 중요해요. 어떤 일이 있었는지 들려주세요.';
    } else {
      return '흥미로운 이야기네요! 더 자세히 들려주세요. 당신의 감정과 생각을 이해하고 싶어요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'AI 감정 파트너',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () {
              // AI 설정 또는 도움말
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // AI 기능 소개 카드
          _buildAIFeaturesCard(),
          
          // 채팅 영역
          Expanded(
            child: _buildChatArea(),
          ),
          
          // 메시지 입력 영역
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildAIFeaturesCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: EmotiCard(
        backgroundColor: AppTheme.primary.withOpacity(0.05),
        borderColor: AppTheme.primary.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'AI 감정 분석',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '감정 상태 분석 및 개선 방안 제시',
                    style: AppTypography.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.assignment, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  '일기 작성 도움',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.play_arrow, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI와의 대화를 통한 일기 작성 지원',
                    style: AppTypography.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isLoading) {
            return _buildLoadingMessage();
          }
          return _buildMessage(_messages[index]);
        },
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isAI) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isAI 
                  ? AppTheme.primary.withOpacity(0.1)
                  : AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: message.isAI ? AppTheme.textPrimary : Colors.white,
                ),
              ),
            ),
          ),
          if (!message.isAI) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primary.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isAI;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isAI,
    required this.timestamp,
  });
}