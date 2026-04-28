import 'package:flutter/material.dart';
import '../../../../../features/diary/domain/entities/diary_entry.dart';

/// 미니멀 일기 목록 카드
///
/// - 감정별 그라데이션 배경 제거 (색상 홍수 방지)
/// - 감정은 아이콘/텍스트 배지로만 표현
/// - 제목 + 본문 스니펫 + 날짜 레이아웃
class DiaryListCard extends StatelessWidget {
  final DiaryEntry entry;
  final bool isSelected;
  final bool isDeleteMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;

  const DiaryListCard({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.isDeleteMode,
    required this.onTap,
    required this.onLongPress,
    required this.formatDate,
    required this.formatTime,
  });

  static const _emotionEmoji = {
    '기쁨': '😊', '설렘': '🥰', '감사': '🙏', '평온': '😌',
    '슬픔': '😢', '분노': '😤', '걱정': '😟', '지루함': '😑',
    '놀람': '😲', '혼란': '😵',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final emotion = entry.emotions.isNotEmpty ? entry.emotions.first : null;
    final emoji = emotion != null ? (_emotionEmoji[emotion] ?? '📓') : '📓';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primaryContainer.withOpacity(0.7)
                : cs.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: cs.primary, width: 1.5)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이모지 아이콘
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.title.isNotEmpty)
                          Expanded(
                            child: Text(
                              entry.title,
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          Expanded(
                            child: Text(
                              entry.content,
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(width: 8),
                        // AI/자유 배지
                        _TypeBadge(isAi: entry.diaryType == DiaryType.aiChat, cs: cs, tt: tt),
                      ],
                    ),
                    if (entry.title.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.content,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    // 날짜 + 감정 태그
                    Row(children: [
                      Text(
                        '${formatDate(entry.createdAt)}  ${formatTime(entry.createdAt)}',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                      if (emotion != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            emotion,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
              // 삭제 모드 체크박스
              if (isDeleteMode)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? cs.error : cs.outline,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isAi, required this.cs, required this.tt});
  final bool isAi;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isAi
            ? cs.primaryContainer.withOpacity(0.7)
            : cs.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAi ? 'AI' : '자유',
        style: tt.labelSmall?.copyWith(
          color: isAi ? cs.onPrimaryContainer : cs.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
