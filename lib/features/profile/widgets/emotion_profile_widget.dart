import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../../../shared/widgets/cards/emoti_card.dart';
import '../../../theme/app_colors.dart';

/// 감정 프로필 위젯
/// 사용자의 감정 프로필 정보를 표시
class EmotionProfileWidget extends ConsumerWidget {
  final UserProfile profile;
  final VoidCallback? onEditTap;

  const EmotionProfileWidget({
    super.key,
    required this.profile,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotionProfile = profile.emotionProfile;
    final preferredEmotions = emotionProfile.preferredEmotions;
    final expressionPreferences = emotionProfile.expressionPreferences;

    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '💜 감정 프로필',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEditTap != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditTap,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 선호하는 감정
            if (preferredEmotions.isNotEmpty) ...[
              Text(
                '선호하는 감정',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: preferredEmotions
                    .take(5)
                    .map((emotion) => _buildEmotionTag(context, emotion))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            
            // 표현 방식 선호도
            if (expressionPreferences.isNotEmpty) ...[
              Text(
                '표현 방식 선호도',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: expressionPreferences
                    .map((preference) => _buildExpressionTag(context, preference))
                    .toList(),
              ),
            ],
            
            // 감정 프로필이 비어있는 경우
            if (preferredEmotions.isEmpty && expressionPreferences.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_emotions_outlined,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '감정 프로필을 설정해주세요',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '자주 느끼는 감정과 표현 방식을 설정하여\n더 나은 경험을 제공받으세요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 감정 태그 위젯
  Widget _buildEmotionTag(BuildContext context, String emotion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        _getEmotionDisplayName(emotion),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 표현 방식 태그 위젯
  Widget _buildExpressionTag(BuildContext context, String preference) {
    final preferenceInfo = _getPreferenceInfo(preference);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            preferenceInfo['icon'] as IconData,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            preferenceInfo['label'] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
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

  /// 표현 방식 정보 가져오기
  Map<String, dynamic> _getPreferenceInfo(String preference) {
    const preferenceOptions = {
      'text': {'label': '텍스트', 'icon': Icons.text_fields},
      'image': {'label': '이미지', 'icon': Icons.image},
      'music': {'label': '음악', 'icon': Icons.music_note},
      'drawing': {'label': '그림', 'icon': Icons.brush},
      'voice': {'label': '음성', 'icon': Icons.mic},
    };
    return preferenceOptions[preference] ?? {'label': preference, 'icon': Icons.help};
  }
}
