import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';

class WriteEmotionSelector extends StatelessWidget {
  final List<String> selectedEmotions;
  final Function(String) onToggle;
  final Map<String, int> emotionIntensities;
  final Function(String, int) onIntensityChanged;

  const WriteEmotionSelector({
    super.key,
    required this.selectedEmotions,
    required this.onToggle,
    required this.emotionIntensities,
    required this.onIntensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final availableEmotions = [
      {
        'name': '기쁨',
        'color': AppTheme.joy,
        'icon': Icons.sentiment_very_satisfied
      },
      {'name': '사랑', 'color': AppTheme.love, 'icon': Icons.favorite},
      {'name': '평온', 'color': AppTheme.calm, 'icon': Icons.sentiment_satisfied},
      {
        'name': '슬픔',
        'color': AppTheme.sadness,
        'icon': Icons.sentiment_dissatisfied
      },
      {
        'name': '분노',
        'color': AppTheme.anger,
        'icon': Icons.sentiment_very_dissatisfied
      },
      {'name': '두려움', 'color': AppTheme.fear, 'icon': Icons.visibility},
      {
        'name': '놀람',
        'color': AppTheme.surprise,
        'icon': Icons.sentiment_satisfied_alt
      },
      {
        'name': '중립',
        'color': AppTheme.neutral,
        'icon': Icons.sentiment_neutral
      },
    ];

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
          Row(
            children: [
              const Icon(Icons.sentiment_satisfied,
                  color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text('오늘의 감정',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              _buildLimitBadge(),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: availableEmotions.length,
            itemBuilder: (context, index) {
              final emotion = availableEmotions[index];
              final name = emotion['name'] as String;
              final isSelected = selectedEmotions.contains(name);
              final isDisabled = !isSelected && selectedEmotions.length >= 2;

              return GestureDetector(
                onTap: isDisabled ? null : () => onToggle(name),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : (isDisabled ? Colors.grey[200] : AppTheme.surface),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : (isDisabled ? Colors.grey[300]! : AppTheme.border),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        emotion['icon'] as IconData,
                        color: isSelected
                            ? Colors.white
                            : (isDisabled
                                ? Colors.grey[500]
                                : AppTheme.textPrimary),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDisabled
                                  ? Colors.grey[500]
                                  : AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (selectedEmotions.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...selectedEmotions
                .map((name) => _buildIntensitySlider(context, name)),
          ],
        ],
      ),
    );
  }

  Widget _buildLimitBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text('최대 2개',
          style: TextStyle(
              color: AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildIntensitySlider(BuildContext context, String name) {
    final intensity = emotionIntensities[name] ?? 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('$intensity/10',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: intensity.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppTheme.primary,
          onChanged: (val) => onIntensityChanged(name, val.round()),
        ),
      ],
    );
  }
}
