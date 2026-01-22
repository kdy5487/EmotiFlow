import 'package:flutter/material.dart';
import '../models/growth_status.dart';

/// 최근 7일 감정 스탬프 캘린더 위젯
class DailyStampCalendar extends StatelessWidget {
  final List<DailyStamp> stamps;
  final VoidCallback? onTap;

  const DailyStampCalendar({
    super.key,
    required this.stamps,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 7일 기록',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.calendar_month,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 스탬프 그리드
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  stamps.map((stamp) => _buildStampItem(stamp, theme)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStampItem(DailyStamp stamp, ThemeData theme) {
    return Column(
      children: [
        // 요일
        Text(
          stamp.dayName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),

        // 스탬프 원
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(stamp.stampColor),
            boxShadow: stamp.hasEntry
                ? [
                    BoxShadow(
                      color: Color(stamp.stampColor).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: stamp.hasEntry
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
        const SizedBox(height: 4),

        // 날짜
        Text(
          '${stamp.date.day}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

