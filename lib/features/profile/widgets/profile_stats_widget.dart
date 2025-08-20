import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/cards/emoti_card.dart';
import '../../../theme/app_colors.dart';

/// 프로필 통계 위젯
/// 사용자의 다이어리 통계를 표시
class ProfileStatsWidget extends ConsumerWidget {
  final Map<String, dynamic> stats;

  const ProfileStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDiaries = stats['totalDiaries'] ?? 0;
    final continuousDays = stats['continuousDays'] ?? 0;
    final emotionCounts = stats['emotionCounts'] as Map<String, dynamic>? ?? {};

    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 통계 요약',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.book,
                    title: '총 다이어리',
                    value: '$totalDiaries',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.local_fire_department,
                    title: '연속 기록',
                    value: '$continuousDays일',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            
            if (emotionCounts.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                '자주 느끼는 감정',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: emotionCounts.entries
                    .take(5)
                    .map((entry) => _buildEmotionChip(
                          context,
                          emotion: entry.key,
                          count: entry.value,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 통계 아이템 위젯
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 감정 칩 위젯
  Widget _buildEmotionChip(BuildContext context, {
    required String emotion,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getEmotionDisplayName(emotion),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 감정 표시명 가져오기
  String _getEmotionDisplayName(String emotion) {
    const displayNames = {
      'joy': '기쁨',
      'gratitude': '감사',
      'excitement': '설렘',
      'calm': '평온',
      'love': '사랑',
      'sadness': '슬픔',
      'anger': '분노',
      'fear': '두려움',
      'surprise': '놀람',
      'neutral': '중립',
    };
    return displayNames[emotion] ?? emotion;
  }
}
