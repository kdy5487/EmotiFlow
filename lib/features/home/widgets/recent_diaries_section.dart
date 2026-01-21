import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/emotion_character_map.dart';
import '../../diary/domain/entities/diary_entry.dart';
import 'package:intl/intl.dart';

/// 최근 일기 섹션
class RecentDiariesSection extends StatelessWidget {
  final List<DiaryEntry> recentDiaries;

  const RecentDiariesSection({
    super.key,
    required this.recentDiaries,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (recentDiaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 일기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/diaries'),
                child: Text(
                  '전체보기',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentDiaries.take(3).map((diary) => _DiaryCard(diary: diary)),
        ],
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  final DiaryEntry diary;

  const _DiaryCard({required this.diary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryEmotion = diary.emotions.isNotEmpty ? diary.emotions.first : null;
    final emotionColors = primaryEmotion != null
        ? EmotionCharacterMap.getEmotionColors(primaryEmotion)
        : {'primary': theme.colorScheme.primary, 'secondary': theme.colorScheme.secondary};
    
    return GestureDetector(
      onTap: () => context.push('/diaries/${diary.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: emotionColors['primary']!.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 캐릭터 미니 아이콘
            if (primaryEmotion != null)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: emotionColors['primary']!.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    EmotionCharacterMap.getCharacterAsset(primaryEmotion),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diary.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diary.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MM/dd HH:mm').format(diary.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      if (diary.emotions.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: emotionColors['primary']!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            diary.emotions.join(', '),
                            style: TextStyle(
                              fontSize: 10,
                              color: emotionColors['primary'],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

