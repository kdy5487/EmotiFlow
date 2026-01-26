import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';
import 'package:emoti_flow/core/ai/gemini/gemini_service.dart';

class DetailAISimpleAdvice extends ConsumerStatefulWidget {
  final DiaryEntry entry;

  const DetailAISimpleAdvice({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<DetailAISimpleAdvice> createState() => _DetailAISimpleAdviceState();
}

class _DetailAISimpleAdviceState extends ConsumerState<DetailAISimpleAdvice> {
  String? _advice;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAdvice();
  }

  Future<void> _loadAdvice() async {
    // aiAnalysis에 이미 조언이 있으면 사용, 없으면 생성하지 않음
    if (widget.entry.aiAnalysis != null && widget.entry.aiAnalysis!.advice.isNotEmpty) {
      setState(() {
        _advice = widget.entry.aiAnalysis!.advice;
        _isLoading = false;
      });
      return;
    }

    // 조언이 없으면 fallback 조언만 표시 (새로 생성하지 않음)
    setState(() {
      _advice = _getFallbackAdvice();
      _isLoading = false;
    });
  }

  String _getFallbackAdvice() {
    final emotion = widget.entry.emotions.isNotEmpty 
        ? widget.entry.emotions.first 
        : '평온';
    switch (emotion) {
      case '기쁨':
        return '정말 기쁜 하루였네요! 이런 긍정적인 감정을 오래 유지하기 위해 감사한 일들을 더 기록해보세요.';
      case '사랑':
        return '사랑이 가득한 하루였군요. 주변 사람들에게 더 많은 관심과 사랑을 나누어보세요.';
      case '평온':
        return '차분하고 평온한 마음으로 하루를 마무리했네요. 이 평온함을 기록하고 감사해보세요.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 자신에게 친절하게 대하고 충분한 휴식을 취하세요.';
      case '분노':
        return '화가 나는 일이 있었나요? 깊은 호흡을 통해 감정을 진정시키고, 산책이나 운동으로 스트레스를 해소해보세요.';
      case '걱정':
        return '불안하고 걱정되는 마음이 드시나요? 현재에 집중하는 명상이나 요가를 시도해보세요.';
      case '놀람':
        return '예상치 못한 일이 있었나요? 새로운 경험을 긍정적으로 받아들이고 성장의 기회로 삼아보세요.';
      default:
        return '오늘 하루도 수고하셨습니다. 내일은 더 좋은 하루가 될 거예요!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI 조언',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoading
              ? Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '조언을 생성하는 중...',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              : Text(
                  _advice ?? _getFallbackAdvice(),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
        ],
      ),
    );
  }
}
