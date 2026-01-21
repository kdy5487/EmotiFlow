import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 빠른 작업 그리드
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 작업',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _QuickActionItem(
                icon: Icons.psychology,
                title: 'AI 대화',
                subtitle: '감정 나누기',
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.2),
                  ],
                ),
                iconColor: theme.colorScheme.primary,
                onTap: () => context.push('/diaries/chat'),
              ),
              _QuickActionItem(
                icon: Icons.book,
                title: '자유 일기',
                subtitle: '자유롭게 쓰기',
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.2),
                  ],
                ),
                iconColor: theme.colorScheme.secondary,
                onTap: () => context.push('/diaries/write'),
              ),
              _QuickActionItem(
                icon: Icons.format_list_bulleted,
                title: '일기 목록',
                subtitle: '모든 일기 보기',
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.withOpacity(0.1),
                    Colors.teal.withOpacity(0.2),
                  ],
                ),
                iconColor: Colors.teal,
                onTap: () => context.push('/diaries'),
              ),
              _QuickActionItem(
                icon: Icons.insert_chart,
                title: '감정 분석',
                subtitle: '트렌드 확인',
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.orange.withOpacity(0.2),
                  ],
                ),
                iconColor: Colors.orange,
                onTap: () => context.push('/statistics'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iconColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

