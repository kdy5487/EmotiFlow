import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ai/gemini/gemini_service.dart';

enum VoiceChatState { idle, listening, processing, speaking }

class VoiceChatPage extends ConsumerStatefulWidget {
  const VoiceChatPage({super.key});

  @override
  ConsumerState<VoiceChatPage> createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends ConsumerState<VoiceChatPage>
    with TickerProviderStateMixin {
  VoiceChatState _chatState = VoiceChatState.idle;

  late final AnimationController _pulseController;
  late final AnimationController _waveController;
  late final Animation<double> _pulseAnim;

  final List<_ChatTurn> _turns = [];
  String _transcriptDraft = '';
  String _statusText = '마이크 버튼을 눌러 대화를 시작하세요';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _onMicTap() {
    if (_chatState == VoiceChatState.idle) {
      _startListening();
    } else if (_chatState == VoiceChatState.listening) {
      _stopListening();
    }
  }

  void _startListening() {
    setState(() {
      _chatState = VoiceChatState.listening;
      _transcriptDraft = '';
      _statusText = '듣고 있어요...';
    });
    _waveController.repeat();
    // TODO: Soniox STT 연동 시 여기서 녹음 시작
    _simulateListening();
  }

  void _stopListening() {
    _waveController.stop();
    if (_transcriptDraft.isEmpty) {
      setState(() {
        _chatState = VoiceChatState.idle;
        _statusText = '마이크 버튼을 눌러 대화를 시작하세요';
      });
      return;
    }
    _processInput(_transcriptDraft);
  }

  /// 실제 STT 연동 전 데모용 시뮬레이션
  Future<void> _simulateListening() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || _chatState != VoiceChatState.listening) return;
    setState(() {
      _transcriptDraft = '오늘 하루가 조금 힘들었어요.';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _chatState != VoiceChatState.listening) return;
    _stopListening();
  }

  Future<void> _processInput(String text) async {
    if (!mounted) return;
    setState(() {
      _chatState = VoiceChatState.processing;
      _statusText = '생각하고 있어요...';
      _turns.add(_ChatTurn(text: text, isUser: true));
      _transcriptDraft = '';
    });

    try {
      final history = _turns.map((t) => '${t.isUser ? "User" : "AI"}: ${t.text}').toList();
      final response = await GeminiService.instance
          .generateEmotionBasedQuestion('평온', text, history);

      if (!mounted) return;
      setState(() {
        _turns.add(_ChatTurn(text: response, isUser: false));
        _chatState = VoiceChatState.speaking;
        _statusText = 'AI가 답하고 있어요';
      });

      // TODO: TTS 연동 시 여기서 음성 재생
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _chatState = VoiceChatState.idle;
        _statusText = '마이크 버튼을 눌러 계속 대화하세요';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _chatState = VoiceChatState.idle;
        _statusText = '오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  Color get _micColor {
    final cs = Theme.of(context).colorScheme;
    return switch (_chatState) {
      VoiceChatState.idle => cs.primary,
      VoiceChatState.listening => const Color(0xFFE05B5B),
      VoiceChatState.processing => cs.secondary,
      VoiceChatState.speaking => cs.primaryContainer,
    };
  }

  IconData get _micIcon {
    return switch (_chatState) {
      VoiceChatState.idle => Icons.mic_none_rounded,
      VoiceChatState.listening => Icons.mic_rounded,
      VoiceChatState.processing => Icons.hourglass_top_rounded,
      VoiceChatState.speaking => Icons.volume_up_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('AI 음성 대화'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_turns.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: '대화 초기화',
              onPressed: () => setState(() {
                _turns.clear();
                _chatState = VoiceChatState.idle;
                _statusText = '마이크 버튼을 눌러 대화를 시작하세요';
              }),
            ),
        ],
      ),
      body: Column(
        children: [
          // 대화 기록
          Expanded(
            child: _turns.isEmpty
                ? _buildEmptyState(cs, textTheme)
                : _buildChatList(cs, textTheme),
          ),

          // 마이크 초안 텍스트
          if (_transcriptDraft.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _transcriptDraft,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // 상태 텍스트
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _statusText,
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
          ),

          // 마이크 버튼 + 파동
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: _buildMicButton(cs),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, TextTheme t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.record_voice_over_rounded,
              size: 64, color: cs.primary.withOpacity(0.25)),
          const SizedBox(height: 16),
          Text(
            'AI에게 오늘 하루를\n음성으로 이야기해보세요',
            style: t.titleMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.45),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '* 음성 인식 기능은 준비 중입니다',
            style: t.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(ColorScheme cs, TextTheme t) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _turns.length,
      itemBuilder: (context, i) {
        final turn = _turns[i];
        return _ChatBubble(turn: turn, cs: cs, t: t);
      },
    );
  }

  Widget _buildMicButton(ColorScheme cs) {
    final isListening = _chatState == VoiceChatState.listening;
    final isInteractable = _chatState == VoiceChatState.idle ||
        _chatState == VoiceChatState.listening;

    return GestureDetector(
      onTap: isInteractable ? _onMicTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 파동 링 (청취 중일 때)
          if (isListening)
            ..._buildWaveRings(cs),

          // 펄스 애니메이션 (아이들)
          if (_chatState == VoiceChatState.idle)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withOpacity(0.12),
                  ),
                ),
              ),
            ),

          // 메인 버튼
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _micColor,
              boxShadow: [
                BoxShadow(
                  color: _micColor.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(_micIcon, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWaveRings(ColorScheme cs) {
    return List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _waveController,
        builder: (_, __) {
          final t = (_waveController.value + i * 0.33) % 1.0;
          final size = 80.0 + t * 80;
          final opacity = (1.0 - t) * 0.4;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE05B5B).withOpacity(opacity),
                width: 2,
              ),
            ),
          );
        },
      );
    });
  }
}

class _ChatTurn {
  final String text;
  final bool isUser;
  _ChatTurn({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final _ChatTurn turn;
  final ColorScheme cs;
  final TextTheme t;

  const _ChatBubble({required this.turn, required this.cs, required this.t});

  @override
  Widget build(BuildContext context) {
    final isUser = turn.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.psychology_rounded,
                  size: 18, color: cs.onPrimaryContainer),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(isUser ? 16 : 4),
                  bottomRight:
                      Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                turn.text,
                style: t.bodyMedium?.copyWith(
                  color: isUser ? cs.onPrimary : cs.onSurface,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.person_rounded,
                  size: 18, color: cs.onPrimaryContainer),
            ),
        ],
      ),
    );
  }
}
