import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// EmotiFlow 앱의 감정별 아이콘 시스템
/// UI/UX 가이드에 정의된 모든 감정 아이콘을 포함
class EmotionIcons {
  // Private constructor to prevent instantiation
  EmotionIcons._();

  // 감정별 아이콘 매핑
  static const Map<String, IconData> emotionIcons = {
    'joy': Icons.sentiment_very_satisfied,      // 기쁨
    'gratitude': Icons.favorite,                // 감사
    'excitement': Icons.celebration,            // 설렘
    'calm': Icons.self_improvement,            // 평온
    'love': Icons.favorite_border,              // 사랑
    'sadness': Icons.sentiment_dissatisfied,    // 슬픔
    'anger': Icons.whatshot,                    // 분노
    'fear': Icons.psychology,                   // 두려움
    'surprise': Icons.emoji_emotions,           // 놀람
    'neutral': Icons.sentiment_neutral,         // 중립
  };

  /// 감정 아이콘 가져오기
  static IconData getIcon(String emotion) {
    return emotionIcons[emotion] ?? Icons.sentiment_neutral;
  }

  /// 감정 색상 가져오기
  static Color getColor(String emotion) {
    return AppColors.getEmotionPrimary(emotion);
  }
}

/// 감정 아이콘 위젯
class EmotionIcon extends StatelessWidget {
  final String emotion;
  final double size;
  final Color? color;
  final bool showBackground;
  final VoidCallback? onTap;

  const EmotionIcon({
    super.key,
    required this.emotion,
    this.size = 24,
    this.color,
    this.showBackground = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? EmotionIcons.getColor(emotion);
    final iconData = EmotionIcons.getIcon(emotion);

    Widget icon = Icon(
      iconData,
      color: iconColor,
      size: size,
    );

    if (showBackground) {
      icon = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.getEmotionBackground(emotion),
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: icon,
      );
    }

    return icon;
  }
}

/// 감정 칩 위젯 (선택 가능한 감정 버튼)
class EmotionChip extends StatelessWidget {
  final String emotion;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showIcon;
  final bool showLabel;

  const EmotionChip({
    super.key,
    required this.emotion,
    this.isSelected = false,
    this.onTap,
    this.showIcon = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final emotionColor = EmotionIcons.getColor(emotion);
    final backgroundColor = isSelected 
        ? emotionColor.withOpacity(0.2)
        : AppColors.surface;
    final borderColor = isSelected ? emotionColor : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              EmotionIcon(
                emotion: emotion,
                size: 16,
                color: emotionColor,
              ),
              if (showLabel) const SizedBox(width: 6),
            ],
            if (showLabel)
              Text(
                _getEmotionLabel(emotion),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? emotionColor : AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getEmotionLabel(String emotion) {
    const labels = {
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
    return labels[emotion] ?? emotion;
  }
}

/// 감정 선택 그리드
class EmotionSelector extends StatelessWidget {
  final String? selectedEmotion;
  final ValueChanged<String>? onEmotionSelected;
  final bool showLabels;
  final int crossAxisCount;

  const EmotionSelector({
    super.key,
    this.selectedEmotion,
    this.onEmotionSelected,
    this.showLabels = true,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final emotions = EmotionIcons.emotionIcons.keys.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        final emotion = emotions[index];
        final isSelected = selectedEmotion == emotion;

        return EmotionChip(
          emotion: emotion,
          isSelected: isSelected,
          onTap: () => onEmotionSelected?.call(emotion),
          showIcon: true,
          showLabel: showLabels,
        );
      },
    );
  }
}
