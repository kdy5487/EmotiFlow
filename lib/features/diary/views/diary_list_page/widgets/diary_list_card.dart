import 'package:flutter/material.dart';
import '../../../../../shared/constants/emotion_character_map.dart';
import '../../../../../theme/app_typography.dart';
import '../../../domain/entities/diary_entry.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryEmotion = entry.emotions.isNotEmpty ? entry.emotions.first : null;
    final pointColor = EmotionCharacterMap.getPointColor(primaryEmotion);
    final characterAsset = EmotionCharacterMap.getCharacterAsset(primaryEmotion);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                pointColor.withOpacity(0.2),
                Colors.white,
              ],
            ),
            border: Border.all(
              color: pointColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 좌측: 감정 캐릭터 (48-56px)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          characterAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.emoji_emotions,
                                size: 28,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 중앙: 제목/요약
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 우측 상단: 작성방식 태그
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (entry.title.isNotEmpty) ...[
                                      Text(
                                        entry.title,
                                        style: AppTypography.titleLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF111827),
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                    Text(
                                      entry.content,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: const Color(0xFF6B7280),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 작성방식 태그
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: entry.diaryType == DiaryType.aiChat 
                                      ? const Color(0xFF8B7CF6).withOpacity(0.15)
                                      : const Color(0xFF4CC9A6).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  entry.diaryType == DiaryType.aiChat ? 'AI' : '자유',
                                  style: TextStyle(
                                    color: entry.diaryType == DiaryType.aiChat 
                                        ? const Color(0xFF8B7CF6)
                                        : const Color(0xFF4CC9A6),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 날짜 · 시간
                          Row(
                            children: [
                              Text(
                                formatDate(entry.createdAt),
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '·',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatTime(entry.createdAt),
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isDeleteMode)
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: isSelected ? Colors.red : Colors.white,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}


