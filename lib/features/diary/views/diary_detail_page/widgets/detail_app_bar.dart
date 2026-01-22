import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        '일기 상세',
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
      ),
      actions: [
        IconButton(
          onPressed: onAnalysisTap,
          icon: Icon(
            Icons.psychology,
            color: theme.colorScheme.onSurface,
          ),
          tooltip: 'AI 상세 분석',
        ),
        IconButton(
          onPressed: onMoreTap,
          icon: Icon(
            Icons.more_vert,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
