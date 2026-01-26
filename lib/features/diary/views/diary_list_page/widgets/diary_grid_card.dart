import 'package:flutter/material.dart';
import '../../../../../shared/constants/emotion_character_map.dart';
import '../../../../../theme/app_typography.dart';
import '../../../domain/entities/diary_entry.dart';

class DiaryGridCard extends StatelessWidget {
  final DiaryEntry entry;
  final bool isSelected;
  final bool isDeleteMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;

  const DiaryGridCard({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.isDeleteMode,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelect,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final primaryEmotion = entry.emotions.isNotEmpty ? entry.emotions.first : null;
    final pointColor = EmotionCharacterMap.getPointColor(primaryEmotion);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20), // 간격 증가
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                pointColor.withOpacity(0.2),
                Theme.of(context).colorScheme.surface,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 첫 번째 줄: 제목
                    if (entry.title.isNotEmpty)
                      Text(
                        entry.title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    if (entry.title.isNotEmpty) const SizedBox(height: 12),
                    // 두 번째 줄: 내용 (3줄로 확장)
                    Expanded(
                      child: Text(
                        entry.content,
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 세 번째 줄: 날짜 (박스 맨 밑)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '${formatDate(entry.createdAt)} · ${formatTime(entry.createdAt)}',
                        style: AppTypography.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // 삭제 모드 체크박스
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
                          color: isSelected 
                              ? const Color(0xFFB91C1C) // 더 부드러운 빨간색
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: isSelected 
                            ? const Color(0xFFDC2626).withOpacity(0.9) // 약간 투명한 빨간색
                            : Colors.white,
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
      ),
    );
  }
}


