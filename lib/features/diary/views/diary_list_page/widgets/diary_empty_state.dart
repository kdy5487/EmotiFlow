import 'package:emoti_flow/theme/app_colors.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:flutter/material.dart';

class DiaryEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onPrimaryAction;
  final String primaryActionText;

  const DiaryEmptyState({
    super.key,
    this.title = '아직 작성된 일기가 없습니다',
    this.subtitle = '첫 번째 일기를 작성해보세요!',
    this.onPrimaryAction,
    this.primaryActionText = '일기 작성하기',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onPrimaryAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPrimaryAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(primaryActionText),
            ),
          ],
        ],
      ),
    );
  }
}


