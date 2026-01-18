import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

class AIDetailedAnalysisDialog extends StatelessWidget {
  final DiaryEntry entry;

  const AIDetailedAnalysisDialog({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.psychology, color: AppTheme.primary),
          const SizedBox(width: 8),
          const Text('AI 상세 분석'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDiarySummary(entry),
              const SizedBox(height: 20),
              _buildWeeklyAdvice(entry),
              const SizedBox(height: 20),
              _buildMonthlyAdvice(entry),
              const SizedBox(height: 20),
              _buildTodayAdviceCardSection(context, entry),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  Widget _buildDiarySummary(DiaryEntry entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text(
                '일기 요약',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.title.isNotEmpty ? entry.title : '제목 없음',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            entry.content.length > 100
                ? '${entry.content.substring(0, 100)}...'
                : entry.content,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyAdvice(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppTheme.secondary),
              const SizedBox(width: 8),
              const Text(
                '주간 조언',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                    fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_generateWeeklyAdvice(emotion),
              style: const TextStyle(color: AppTheme.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildMonthlyAdvice(DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppTheme.warning),
              const SizedBox(width: 8),
              const Text(
                '월간 조언',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warning,
                    fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_generateMonthlyAdvice(emotion),
              style: const TextStyle(color: AppTheme.textPrimary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTodayAdviceCardSection(BuildContext context, DiaryEntry entry) {
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : '평온';
    final adviceCards = _generateAdviceCards(emotion);

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
          Row(
            children: [
              const Icon(Icons.card_giftcard, color: AppTheme.info),
              const SizedBox(width: 8),
              const Text(
                '오늘의 조언 카드',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.info,
                    fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: adviceCards.map((card) {
              final index = adviceCards.indexOf(card);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: index < adviceCards.length - 1 ? 12 : 0),
                  child: GestureDetector(
                    onTap: () => _showAdviceCardDetail(context, card),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: card['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: card['color'].withOpacity(0.3), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(card['icon'], size: 24, color: card['color']),
                          const SizedBox(height: 8),
                          Text(card['title'],
                              style: TextStyle(
                                  color: card['color'],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _generateWeeklyAdvice(String emotion) {
    switch (emotion) {
      case '기쁨':
        return '이번 주는 매우 긍정적인 감정을 유지하고 있습니다. 이런 좋은 기운을 주변 사람들과 나누어보세요.';
      case '슬픔':
        return '힘든 시간을 보내고 계시는군요. 자신에게 친절하게 대하고 충분한 휴식을 취하세요.';
      default:
        return '이번 주는 다양한 감정을 경험하고 있습니다. 감정의 변화를 자연스럽게 받아들여 보세요.';
    }
  }

  String _generateMonthlyAdvice(String emotion) {
    switch (emotion) {
      case '기쁨':
        return '이번 달은 전반적으로 긍정적인 감정을 유지하고 있습니다. 이런 기운을 더 오래 유지하기 위해 감사 일기를 써보세요.';
      default:
        return '이번 달은 다양한 감정을 경험하고 있습니다. 각각의 감정에서 배울 점이 있는지 생각해보세요.';
    }
  }

  List<Map<String, dynamic>> _generateAdviceCards(String emotion) {
    return [
      {
        'title': '자연과 함께',
        'advice': '오늘은 자연 속에서 시간을 보내보세요.',
        'icon': Icons.park,
        'color': AppTheme.success
      },
      {
        'title': '감사의 마음',
        'advice': '오늘 감사한 일 3가지를 적어보세요.',
        'icon': Icons.favorite,
        'color': AppTheme.error
      },
      {
        'title': '마음 정리',
        'advice': '깊은 호흡을 해보세요. 마음이 차분해질 거예요.',
        'icon': Icons.air,
        'color': AppTheme.info
      },
    ];
  }

  void _showAdviceCardDetail(BuildContext context, Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(card['icon'], color: card['color']),
            const SizedBox(width: 8),
            Text(card['title']),
          ],
        ),
        content: Text(card['advice']),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('확인'))
        ],
      ),
    );
  }
}
