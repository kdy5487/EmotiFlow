import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ChatEmotionSelector extends StatelessWidget {
  final String? selectedEmotion;
  final Function(String) onEmotionSelected;

  const ChatEmotionSelector({
    super.key,
    this.selectedEmotion,
    required this.onEmotionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final emotions = [
      {
        'name': '기쁨',
        'icon': Icons.sentiment_very_satisfied,
        'color': AppTheme.joy
      },
      {'name': '사랑', 'icon': Icons.favorite, 'color': AppTheme.love},
      {'name': '평온', 'icon': Icons.sentiment_satisfied, 'color': AppTheme.calm},
      {
        'name': '슬픔',
        'icon': Icons.sentiment_dissatisfied,
        'color': AppTheme.sadness
      },
      {
        'name': '분노',
        'icon': Icons.sentiment_very_dissatisfied,
        'color': AppTheme.anger
      },
      {'name': '두려움', 'icon': Icons.visibility, 'color': AppTheme.fear},
      {
        'name': '놀람',
        'icon': Icons.sentiment_satisfied_alt,
        'color': AppTheme.sadness
      },
      {
        'name': '중립',
        'icon': Icons.sentiment_neutral,
        'color': AppTheme.neutral
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 감정을 선택해주세요',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotions.map((emotion) {
              final isSelected = selectedEmotion == emotion['name'] as String;
              final color = emotion['color'] as Color;

              return GestureDetector(
                onTap: () => onEmotionSelected(emotion['name'] as String),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.primary : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        emotion['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        emotion['name'] as String,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected ? Colors.white : color,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
