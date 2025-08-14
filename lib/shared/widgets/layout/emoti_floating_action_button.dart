import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// EmotiFlow 앱의 공통 FloatingActionButton 컴포넌트
/// UI/UX 가이드에 정의된 모든 FloatingActionButton 스타일을 포함
class EmotiFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final bool isExtended;
  final bool isLoading;

  const EmotiFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56,
    this.isExtended = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? AppColors.primary;
    final iconColor = foregroundColor ?? AppColors.textInverse;

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: isLoading ? null : onPressed,
        backgroundColor: buttonColor,
        foregroundColor: iconColor,
        icon: _buildIcon(iconColor),
        label: Text(
          label!,
          style: AppTypography.buttonMedium.copyWith(
            color: iconColor,
          ),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: buttonColor,
      foregroundColor: iconColor,
      child: _buildIcon(iconColor),
    );
  }

  Widget _buildIcon(Color iconColor) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }

    return Icon(icon, size: 24);
  }
}

/// 일기 작성용 FloatingActionButton
class EmotiDiaryFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const EmotiDiaryFAB({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiFloatingActionButton(
      onPressed: onPressed,
      icon: Icons.edit,
      label: '일기 작성',
      isExtended: true,
      isLoading: isLoading,
    );
  }
}

/// AI 분석용 FloatingActionButton
class EmotiAIFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const EmotiAIFAB({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiFloatingActionButton(
      onPressed: onPressed,
      icon: Icons.psychology,
      label: 'AI 분석',
      isExtended: true,
      isLoading: isLoading,
    );
  }
}

/// 음악 재생용 FloatingActionButton
class EmotiMusicFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isPlaying;
  final bool isLoading;

  const EmotiMusicFAB({
    super.key,
    this.onPressed,
    this.isPlaying = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiFloatingActionButton(
      onPressed: onPressed,
      icon: isPlaying ? Icons.pause : Icons.play_arrow,
      backgroundColor: AppColors.secondary,
      isLoading: isLoading,
    );
  }
}

/// 커뮤니티 글쓰기용 FloatingActionButton
class EmotiCommunityFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const EmotiCommunityFAB({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiFloatingActionButton(
      onPressed: onPressed,
      icon: Icons.create,
      label: '글쓰기',
      isExtended: true,
      isLoading: isLoading,
    );
  }
}

/// 감정 체크용 FloatingActionButton
class EmotiMoodFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? currentMood;
  final bool isLoading;

  const EmotiMoodFAB({
    super.key,
    this.onPressed,
    this.currentMood,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    Color backgroundColor;

    if (currentMood != null) {
      icon = Icons.sentiment_satisfied;
      label = '감정 변경';
      backgroundColor = AppColors.getEmotionPrimary(currentMood!);
    } else {
      icon = Icons.sentiment_neutral;
      label = '감정 체크';
      backgroundColor = AppColors.primary;
    }

    return EmotiFloatingActionButton(
      onPressed: onPressed,
      icon: icon,
      label: label,
      backgroundColor: backgroundColor,
      isExtended: true,
      isLoading: isLoading,
    );
  }
}
