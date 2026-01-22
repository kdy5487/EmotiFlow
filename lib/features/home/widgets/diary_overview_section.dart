import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/features/diary/domain/entities/diary_entry.dart';
import 'package:emoti_flow/shared/constants/emotion_character_map.dart';
import '../models/growth_status.dart';
import 'calendar_modal.dart';

/// 최근 7일 스탬프 + 최근 일기 통합 위젯
class DiaryOverviewSection extends StatelessWidget {
  final GrowthStatus growthStatus;
  final List<DiaryEntry> recentDiaries;
  final List<DiaryEntry> allDiaries;

  const DiaryOverviewSection({
    super.key,
    required this.growthStatus,
    required this.recentDiaries,
    required this.allDiaries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (제목 + 액션 버튼들)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '나의 일기',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  // 달력 버튼
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CalendarModal(allDiaries: allDiaries),
                      );
                    },
                    icon: Icon(
                      Icons.calendar_month,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    tooltip: '달력 보기',
                  ),
                  const SizedBox(width: 4),
                  // 일기 목록 버튼
                  IconButton(
                    onPressed: () => context.push('/diaries'),
                    icon: Icon(
                      Icons.list,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    tooltip: '일기 목록',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 최근 7일 스탬프
          _build7DayStamps(context, theme),
          const SizedBox(height: 20),

          // 최근 일기
          if (recentDiaries.isEmpty)
            _buildEmptyState(context, theme)
          else
            _buildRecentDiariesList(context, theme),
        ],
      ),
    );
  }

  Widget _build7DayStamps(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 7일',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: growthStatus.last7Days.map((stamp) {
            return Column(
              children: [
                // 요일
                Text(
                  stamp.dayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                // 스탬프 원
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(stamp.stampColor),
                    boxShadow: stamp.hasEntry
                        ? [
                            BoxShadow(
                              color: Color(stamp.stampColor).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: stamp.hasEntry
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                // 날짜
                Text(
                  '${stamp.date.day}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentDiariesList(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 작성',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        ...recentDiaries.take(3).map((diary) => _buildDiaryItem(context, theme, diary)),
      ],
    );
  }

  Widget _buildDiaryItem(BuildContext context, ThemeData theme, DiaryEntry diary) {
    // 첫 번째 감정 가져오기
    final primaryEmotion = diary.emotions.isNotEmpty ? diary.emotions.first : null;
    final characterAsset = primaryEmotion != null
        ? EmotionCharacterMap.getCharacterAsset(primaryEmotion)
        : null;

    return GestureDetector(
      onTap: () => context.push('/diaries/${diary.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: characterAsset != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        characterAsset,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.book,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diary.title.isNotEmpty ? diary.title : '제목 없음',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(diary.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.book_outlined,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              '아직 일기가 없어요',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '첫 번째 일기를 작성해보세요!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '${difference}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

