import 'package:flutter/material.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';

/// 홈페이지 달력 모달 (월별 일기 작성 현황)
class CalendarModal extends StatefulWidget {
  final List<DiaryEntry> allDiaries;

  const CalendarModal({
    super.key,
    required this.allDiaries,
  });

  @override
  State<CalendarModal> createState() => _CalendarModalState();
}

class _CalendarModalState extends State<CalendarModal> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // 헤더 (월 선택)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month + 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 요일 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                return SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // 달력 그리드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCalendarGrid(theme),
            ),
          ),

          // 하단 설명
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surface
                  : theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(theme, Colors.green, '일기 작성'),
                const SizedBox(width: 24),
                _buildLegendItem(
                    theme, theme.colorScheme.onSurface.withOpacity(0.1), '미작성'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme) {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 일요일 = 0

    // 해당 월의 일기들 찾기
    final monthDiaries = widget.allDiaries.where((diary) {
      return diary.createdAt.year == _selectedMonth.year &&
          diary.createdAt.month == _selectedMonth.month;
    }).toList();

    // 날짜별 일기 맵 생성
    final diaryMap = <int, List<DiaryEntry>>{};
    for (final diary in monthDiaries) {
      final day = diary.createdAt.day;
      diaryMap.putIfAbsent(day, () => []).add(diary);
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: firstWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox.shrink();
        }

        final day = index - firstWeekday + 1;
        final hasEntry = diaryMap.containsKey(day);
        final isToday = _selectedMonth.year == DateTime.now().year &&
            _selectedMonth.month == DateTime.now().month &&
            day == DateTime.now().day;

        return Container(
          decoration: BoxDecoration(
            color: hasEntry
                ? Colors.green.withOpacity(0.2)
                : theme.colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '$day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: hasEntry
                        ? Colors.green
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              if (hasEntry)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(ThemeData theme, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

