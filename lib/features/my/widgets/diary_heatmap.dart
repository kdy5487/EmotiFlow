import 'package:flutter/material.dart';
import '../../../features/diary/domain/entities/diary_entry.dart';

/// GitHub 잔디 스타일 일기 활동 히트맵
///
/// 최근 17주 × 7일 셀을 렌더링.
/// 일기 작성 횟수에 따라 셀 색 강도 4단계.
class DiaryHeatmap extends StatefulWidget {
  const DiaryHeatmap({super.key, required this.entries});
  final List<DiaryEntry> entries;

  @override
  State<DiaryHeatmap> createState() => _DiaryHeatmapState();
}

class _DiaryHeatmapState extends State<DiaryHeatmap> {
  DateTime? _selectedDay;
  static const _weeks = 17;

  // entries → 날짜별 카운트 맵
  Map<DateTime, int> _buildCountMap() {
    final map = <DateTime, int>{};
    for (final e in widget.entries) {
      final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      map[d] = (map[d] ?? 0) + 1;
    }
    return map;
  }

  Color _cellColor(int count, ColorScheme cs) {
    if (count == 0) return cs.surfaceContainerHighest.withOpacity(0.4);
    if (count == 1) return cs.primary.withOpacity(0.35);
    if (count == 2) return cs.primary.withOpacity(0.60);
    return cs.primary.withOpacity(0.90);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final countMap = _buildCountMap();

    // 오늘 기준 이전 일요일부터 시작
    final today = DateTime.now();
    final startSunday = today.subtract(Duration(days: today.weekday % 7 + (_weeks - 1) * 7));

    final months = <String>[];
    DateTime? prevMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 월 레이블
        SizedBox(
          height: 14,
          child: Row(
            children: List.generate(_weeks, (wi) {
              final day = startSunday.add(Duration(days: wi * 7));
              final label = day.month != prevMonth?.month
                  ? '${day.month}월'
                  : '';
              prevMonth = day;
              if (label.isNotEmpty) months.add(label);
              return Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: cs.onSurface.withOpacity(0.4)),
                  overflow: TextOverflow.visible,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        // 히트맵 그리드
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(_weeks, (wi) {
            return Expanded(
              child: Column(
                children: List.generate(7, (di) {
                  final day = startSunday.add(Duration(days: wi * 7 + di));
                  if (day.isAfter(today)) {
                    return const SizedBox(height: 12, width: double.infinity);
                  }
                  final key = DateTime(day.year, day.month, day.day);
                  final count = countMap[key] ?? 0;
                  final isSelected = _selectedDay == key;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDay = isSelected ? null : key;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _cellColor(count, cs),
                          borderRadius: BorderRadius.circular(2),
                          border: isSelected
                              ? Border.all(color: cs.primary, width: 1.5)
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // 선택된 날짜 정보
        if (_selectedDay != null)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildDayTooltip(_selectedDay!, countMap[_selectedDay!] ?? 0, cs),
          ),
        const SizedBox(height: 8),
        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('적음', style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.4))),
            const SizedBox(width: 4),
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: i == 0
                      ? cs.surfaceContainerHighest.withOpacity(0.4)
                      : cs.primary.withOpacity(0.3 + i * 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
            const SizedBox(width: 4),
            Text('많음', style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: cs.onSurface.withOpacity(0.4))),
          ],
        ),
      ],
    );
  }

  Widget _buildDayTooltip(DateTime day, int count, ColorScheme cs) {
    final dateStr = '${day.year}.${day.month.toString().padLeft(2, '0')}.${day.day.toString().padLeft(2, '0')}';
    return Container(
      key: ValueKey(day),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count == 0
            ? '$dateStr — 일기 없음'
            : '$dateStr — 일기 ${count}편',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: cs.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }
}
