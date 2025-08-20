import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// EmotiFlow 앱의 공통 AppBar 컴포넌트
/// UI/UX 가이드에 정의된 모든 AppBar 스타일을 포함
class EmotiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final VoidCallback? onBackPressed;

  const EmotiAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.backgroundColor,
    this.foregroundColor,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTypography.titleLarge.copyWith(
          color: foregroundColor ?? AppColors.textPrimary,
        ),
      ),
      leading: _buildLeading(context),
      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: elevation,
      centerTitle: centerTitle,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.border.withOpacity(0.1),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        color: foregroundColor ?? AppColors.textPrimary,
      );
    }
    
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 홈 페이지용 AppBar
class EmotiHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final String? notificationCount;

  const EmotiHomeAppBar({
    super.key,
    this.onNotificationTap,
    this.onSettingsTap,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiAppBar(
      title: 'EmotiFlow',
      showBackButton: false,
      actions: [
        // 알림 버튼
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationTap,
            ),
            if (notificationCount != null && notificationCount != '0')
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount!,
                    style: AppTypography.captionSmall.copyWith(
                      color: AppColors.textInverse,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // 설정 버튼
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 일기 작성용 AppBar
class EmotiDiaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool isSaving;
  final bool canSave;

  const EmotiDiaryAppBar({
    super.key,
    this.onSave,
    this.onShare,
    this.isSaving = false,
    this.canSave = true,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiAppBar(
      title: '일기 작성',
      showBackButton: true,
      actions: [
        // 공유 버튼
        if (onShare != null)
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: onShare,
          ),
        // 저장 버튼
        if (onSave != null)
          IconButton(
            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: canSave && !isSaving ? onSave : null,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// AI 분석용 AppBar
class EmotiAIAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHistoryTap;
  final VoidCallback? onSettingsTap;

  const EmotiAIAppBar({
    super.key,
    this.onHistoryTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiAppBar(
      title: 'AI 분석',
      showBackButton: true,
      actions: [
        // 히스토리 버튼
        if (onHistoryTap != null)
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: onHistoryTap,
          ),
        // 설정 버튼
        if (onSettingsTap != null)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: onSettingsTap,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
