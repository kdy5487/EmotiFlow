import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:emoti_flow/shared/constants/emotion_character_map.dart';
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
    // EmotionCharacterMap의 사용 가능한 감정들 사용
    final emotions = EmotionCharacterMap.availableEmotions;

    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7), // 연한 크림색 배경
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 감정을 선택해주세요',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '감정을 선택하면 그에 맞는 에모티가 함께해요',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 캐릭터 기반 감정 선택 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: emotions.length,
              itemBuilder: (context, index) {
                final emotion = emotions[index];
                final isSelected = selectedEmotion == emotion;
                final characterAsset =
                    EmotionCharacterMap.getCharacterAsset(emotion);

                return GestureDetector(
                  onTap: () => onEmotionSelected(emotion),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.grey.withOpacity(0.3),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            characterAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.psychology,
                                  color: AppTheme.primary,
                                  size: 28,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        emotion,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
