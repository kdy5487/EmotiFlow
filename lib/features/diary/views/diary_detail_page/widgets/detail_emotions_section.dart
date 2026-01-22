import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/shared/constants/emotion_character_map.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

class DetailEmotionsSection extends StatelessWidget {
  final DiaryEntry entry;

  const DetailEmotionsSection({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              const Icon(
                Icons.emoji_emotions,
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '오늘의 감정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: entry.emotions.map((emotion) {
              final intensity = entry.emotionIntensities[emotion] ?? 5;
              return _buildEmotionChip(context, emotion, intensity);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChip(BuildContext context, String emotion, int intensity) {
    final emotionColors = {
      '기쁨': AppTheme.success,
      '감사': AppTheme.success,
      '평온': AppTheme.info,
      '설렘': AppTheme.warning,
      '슬픔': AppTheme.error,
      '분노': AppTheme.error,
      '걱정': AppTheme.warning,
      '지루함': AppTheme.textTertiary,
    };

    final color = emotionColors[emotion] ?? AppTheme.primary;
    final characterAsset = EmotionCharacterMap.getCharacterAsset(emotion);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 캐릭터 이미지
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset(
                characterAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: color.withOpacity(0.1),
                    child: Icon(
                      Icons.emoji_emotions,
                      size: 18,
                      color: color,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            emotion,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$intensity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
