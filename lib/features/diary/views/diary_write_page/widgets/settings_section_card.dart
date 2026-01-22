import 'package:flutter/material.dart';

/// 일기 설정 섹션 카드 위젯 (다크모드 지원)
class SettingsSectionCard extends StatelessWidget {
  final bool isPrivate;
  final bool allowAI;
  final ValueChanged<bool?> onPrivateChanged;
  final ValueChanged<bool?> onAllowAIChanged;

  const SettingsSectionCard({
    super.key,
    required this.isPrivate,
    required this.allowAI,
    required this.onPrivateChanged,
    required this.onAllowAIChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '일기 설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '개발중',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(
              '비공개 일기',
              style: TextStyle(
                fontSize: 14, 
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            subtitle: Text(
              '나만 볼 수 있는 일기',
              style: TextStyle(
                fontSize: 12, 
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            value: isPrivate,
            onChanged: onPrivateChanged,
            activeColor: theme.colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(
              'AI 분석 허용',
              style: TextStyle(
                fontSize: 14, 
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            subtitle: Text(
              '감정 분석 및 조언 받기',
              style: TextStyle(
                fontSize: 12, 
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            value: allowAI,
            onChanged: onAllowAIChanged,
            activeColor: theme.colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
