import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

class DetailAISimpleAdvice extends StatelessWidget {
  final DiaryEntry entry;

  const DetailAISimpleAdvice({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    final advice = _generateSimpleAIAdvice(emotion);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: AppTheme.info),
              SizedBox(width: 8),
              Text(
                'AI 간단 조언',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.info,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advice,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '앱바의 🧠 아이콘을 눌러 더 자세한 AI 분석을 확인할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateSimpleAIAdvice(String emotion) {
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
      case '두려움':
        return '불안하고 걱정되는 마음이 드시나요? 현재에 집중하는 명상이나 요가를 시도해보세요.';
      case '놀람':
        return '예상치 못한 일이 있었나요? 새로운 경험을 긍정적으로 받아들이고 성장의 기회로 삼아보세요.';
      case '중립':
        return '차분하게 하루를 마무리했네요. 내일은 더 특별한 순간들을 만들어보세요.';
      default:
        return '오늘 하루도 수고하셨습니다. 내일은 더 좋은 하루가 될 거예요!';
    }
  }
}
