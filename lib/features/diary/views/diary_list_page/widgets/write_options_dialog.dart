import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_colors.dart';
import 'package:emoti_flow/theme/app_typography.dart';

class WriteOptionsDialog extends StatelessWidget {
  const WriteOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '어떻게 작성할까요?',
              style: AppTypography.titleLarge
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildOption(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'AI와 대화하며 작성',
              subtitle: '상담가와 대화하듯 편하게 작성해요',
              color: AppColors.primary,
              onTap: () {
                context.pop();
                context.push('/diaries/chat');
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              icon: Icons.edit_outlined,
              title: '직접 작성',
              subtitle: '오늘의 감정과 일기를 직접 기록해요',
              color: AppColors.secondary,
              onTap: () {
                context.pop();
                context.push('/diaries/write');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall
                        .copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
