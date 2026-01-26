import 'package:flutter/material.dart';
import '../../../../../shared/constants/emotion_character_map.dart';
import '../../../domain/entities/diary_entry.dart';

/// 일기 상세 페이지 상단 히어로 영역
class DetailHeroSection extends StatelessWidget {
  final DiaryEntry entry;

  const DetailHeroSection({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final primaryEmotion = entry.emotions.isNotEmpty ? entry.emotions.first : null;
    final pointColor = EmotionCharacterMap.getPointColor(primaryEmotion);
    final characterAsset = EmotionCharacterMap.getCharacterAsset(primaryEmotion);
    
    // 감정 정보 (최대 2개)
    final emotions = entry.emotions.take(2).toList();
    final emotionIntensities = entry.emotionIntensities;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  pointColor.withOpacity(0.2),
                  pointColor.withOpacity(0.1),
                  Theme.of(context).colorScheme.surface,
                ]
              : [
                  pointColor.withOpacity(0.4),
                  pointColor.withOpacity(0.1),
                  Colors.white,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단: 작성 방식 태그 (우측 상단)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 감정 캐릭터 크게 표시
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                characterAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.emoji_emotions,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 감정명 + 강도 (기쁨 8 형태)
          if (emotions.isNotEmpty)
            Wrap(
              spacing: 16, // 감정이 2개일 때 간격 조금 더 증가
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: emotions.map((emotion) {
                final intensity = emotionIntensities[emotion] ?? 5;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emotion,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : const Color(0xFF1F2937),
                        shadows: Theme.of(context).brightness == Brightness.dark
                            ? []
                            : [
                                Shadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$intensity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          // 날짜 · 시간
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(entry.createdAt),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '·',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(entry.createdAt),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

