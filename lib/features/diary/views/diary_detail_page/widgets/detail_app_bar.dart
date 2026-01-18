import 'package:flutter/material.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DiaryEntry diaryEntry;
  final VoidCallback onAnalysisTap;
  final VoidCallback onMoreTap;

  const DetailAppBar({
    super.key,
    required this.diaryEntry,
    required this.onAnalysisTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('일기 상세'),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: onAnalysisTap,
          icon: const Icon(Icons.psychology),
          tooltip: 'AI 상세 분석',
        ),
        IconButton(
          onPressed: onMoreTap,
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
