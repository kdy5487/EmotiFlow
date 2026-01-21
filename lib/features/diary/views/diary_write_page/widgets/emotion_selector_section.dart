import 'package:flutter/material.dart';
import '../../../../../shared/constants/emotion_character_map.dart';

/// 감정 선택 섹션 위젯 (다크모드 지원)
class EmotionSelectorSection extends StatelessWidget {
  final List<String> selectedEmotions;
  final Map<String, int> emotionIntensities;
  final Function(String) onEmotionToggle;
  final Function(String, int) onIntensityChanged;
  final double screenWidth;

  const EmotionSelectorSection({
    super.key,
    required this.selectedEmotions,
    required this.emotionIntensities,
    required this.onEmotionToggle,
    required this.onIntensityChanged,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emotions = [
      ...EmotionCharacterMap.availableEmotions,
      null, // "선택 없음" 옵션
    ];

    // 그리드 아이템 크기 계산
    final itemWidth = (screenWidth - (screenWidth * 0.1) - (screenWidth * 0.09)) / 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '오늘의 감정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '최대 2개',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '오늘 느낀 감정을 선택해주세요',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: screenWidth * 0.04,
              childAspectRatio: itemWidth / (itemWidth + 10),
            ),
            itemCount: emotions.length,
            itemBuilder: (context, index) {
              final emotion = emotions[index];
              final isSelected = emotion == null
                  ? selectedEmotions.isEmpty
                  : selectedEmotions.contains(emotion);
              final characterAsset = EmotionCharacterMap.getCharacterAsset(emotion);

              return GestureDetector(
                onTap: () => onEmotionToggle(emotion ?? ''),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          characterAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.emoji_emotions,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      emotion ?? '선택 없음',
                      style: TextStyle(
                        fontSize: 9,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          if (selectedEmotions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '감정 강도',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            ...selectedEmotions.map((emotion) {
              final intensity = emotionIntensities[emotion] ?? 5;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          emotion,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '$intensity',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8.0,
                        ),
                      ),
                      child: Slider(
                        value: intensity.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: theme.colorScheme.onSurface.withOpacity(0.1),
                        onChanged: (value) =>
                            onIntensityChanged(emotion, value.toInt()),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
