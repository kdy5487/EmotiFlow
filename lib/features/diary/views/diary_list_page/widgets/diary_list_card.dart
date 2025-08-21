import 'package:flutter/material.dart';
import '../../../../../shared/widgets/cards/emoti_card.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_typography.dart';
import '../../../models/diary_entry.dart';

class DiaryListCard extends StatelessWidget {
  final DiaryEntry entry;
  final bool isSelected;
  final bool isDeleteMode;
  final VoidCallback onTap;
  final Widget headerEmotionIndicator;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;

  const DiaryListCard({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.isDeleteMode,
    required this.onTap,
    required this.headerEmotionIndicator,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: EmotiCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        formatDate(entry.createdAt),
                                        style: AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      headerEmotionIndicator,
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatTime(entry.createdAt),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (entry.title.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, right: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.title,
                                      style: AppTypography.titleLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: entry.diaryType == DiaryType.aiChat 
                                          ? AppColors.info.withOpacity(0.2)
                                          : AppColors.success.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: entry.diaryType == DiaryType.aiChat 
                                            ? AppColors.info
                                            : AppColors.success,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      entry.diaryType == DiaryType.aiChat ? 'AI' : '자유',
                                      style: AppTypography.caption.copyWith(
                                        color: entry.diaryType == DiaryType.aiChat 
                                            ? AppColors.info
                                            : AppColors.success,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              entry.content,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (entry.tags.isNotEmpty) ...[
                                Icon(Icons.label, size: 10, color: Colors.grey[600]),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    entry.tags.take(2).join(', '),
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 9,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              const SizedBox(width: 6),
                              if (entry.mediaCount > 0)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.image, size: 10, color: Colors.grey[600]),
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
                              const SizedBox(width: 6),
                              if (entry.aiAnalysis != null)
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.psychology, size: 10, color: AppColors.primary),
                                    SizedBox(width: 2),
                                    Text(
                                      'AI',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (entry.coverImageUrl != null || entry.firstLocalImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 120,
                          height: 140,
                          color: Colors.grey[200],
                          child: _buildOptimizedImage(entry),
                        ),
                      ),
                  ],
                ),
              ),
              if (isDeleteMode)
                Positioned(
                  right: 8,
                  top: 8,
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

  Widget _buildOptimizedImage(DiaryEntry entry) {
    if (entry.coverImageUrl != null) {
      return Image.network(
        entry.coverImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
    if (entry.firstLocalImagePath != null) {
      return Image.asset(
        entry.firstLocalImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
      );
    }
    return const SizedBox.shrink();
  }
}


