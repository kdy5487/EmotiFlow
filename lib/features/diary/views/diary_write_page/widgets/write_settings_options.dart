import 'package:flutter/material.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';

class WriteSettingsOptions extends StatelessWidget {
  final bool isPrivate;
  final bool allowAI;
  final Function(bool) onPrivateChanged;
  final Function(bool) onAIChanged;

  const WriteSettingsOptions({
    super.key,
    required this.isPrivate,
    required this.allowAI,
    required this.onPrivateChanged,
    required this.onAIChanged,
  });

  @override
  Widget build(BuildContext context) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '설정',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('비공개'),
              subtitle: const Text('나만 볼 수 있는 일기'),
              value: isPrivate,
              onChanged: onPrivateChanged,
              activeColor: AppTheme.primary,
            ),
            SwitchListTile(
              title: const Text('AI 분석 허용'),
              subtitle: const Text('감정 분석 및 개선 방안 제시'),
              value: allowAI,
              onChanged: onAIChanged,
              activeColor: AppTheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
