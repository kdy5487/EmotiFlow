import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_colors.dart';
import 'package:emoti_flow/theme/app_typography.dart';

class WriteOptionsDialog extends StatelessWidget {
  const WriteOptionsDialog({super.key});

  Future<void> _openVoiceChat(BuildContext context) async {
    context.pop();
    context.push('/voice-chat');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('어떻게 작성할까요?',
                      style: AppTypography.titleLarge
                          .copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
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
              const SizedBox(height: 12),
              _buildOption(
                context,
                icon: Icons.mic_rounded,
                title: '음성으로 AI와 대화',
                subtitle: '말로 감정을 털어놓고 AI가 답해줘요 (STT)',
                color: Colors.deepPurple,
                badge: 'BETA',
                onTap: () => _openVoiceChat(context),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 8),
            ],
          ),
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
    String? badge,
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
                  Row(children: [
                    Text(title,
                        style: AppTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold)),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(badge,
                            style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  Text(subtitle,
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.grey[600])),
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
