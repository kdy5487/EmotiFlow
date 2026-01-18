import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_typography.dart';
import '../../../domain/entities/diary_entry.dart';
import '../../../domain/entities/emotion.dart';

class DiaryGridCard extends StatelessWidget {
  final DiaryEntry entry;
  final bool isSelected;
  final bool isDeleteMode;
  final VoidCallback onTap;
  final VoidCallback onToggleSelect;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;

  const DiaryGridCard({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.isDeleteMode,
    required this.onTap,
    required this.onToggleSelect,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDate(entry.createdAt),
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              formatTime(entry.createdAt),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (entry.emotions.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Emotion.findByName(entry.emotions.first)?.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            Emotion.findByName(entry.emotions.first)?.emoji ?? '😊',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (entry.title.isNotEmpty) ...[
                    Text(
                      entry.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Expanded(
                    child: Text(
                      entry.content,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (entry.tags.isNotEmpty)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.tags.first,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (entry.mediaCount > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              '${entry.mediaCount}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.diaryType == DiaryType.aiChat ? 'AI' : '자유형',
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isDeleteMode)
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: onToggleSelect,
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
              ),
          ],
        ),
      ),
    );
  }
}


