import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/emotion_character_map.dart';
import '../../diary/domain/entities/diary_entry.dart';

/// 감정 체크 카드 (오늘 일기 작성 여부에 따라 다른 UI)
class EmotionCheckCard extends StatelessWidget {
  final List<DiaryEntry> todayDiaries;
  final String userName;

  const EmotionCheckCard({
    super.key,
    required this.todayDiaries,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    if (todayDiaries.isNotEmpty) {
      return _buildTodayEmotionSummary(context);
    } else {
      return _buildWritingPrompt(context);
    }
  }

  /// 오늘 작성한 일기의 감정 요약
  Widget _buildTodayEmotionSummary(BuildContext context) {
    final theme = Theme.of(context);
    
    // 감정별 평균 강도 계산
    final emotionIntensities = <String, List<int>>{};
    for (final diary in todayDiaries) {
      for (final emotion in diary.emotions) {
        final intensity = diary.emotionIntensities[emotion] ?? 5;
        emotionIntensities.putIfAbsent(emotion, () => []).add(intensity);
      }
    }

    final averageEmotions = emotionIntensities.map((emotion, intensities) =>
        MapEntry(
            emotion, intensities.reduce((a, b) => a + b) / intensities.length));

    // 가장 강한 감정 찾기
    final dominantEmotion =
        averageEmotions.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    final characterAsset = EmotionCharacterMap.getCharacterAsset(dominantEmotion.key);
    final emotionColors = EmotionCharacterMap.getEmotionColors(dominantEmotion.key);

    return GestureDetector(
      onTap: () => context.push('/diaries'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              emotionColors['primary']!.withOpacity(0.1),
              emotionColors['secondary']!.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: emotionColors['primary']!.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 캐릭터 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: emotionColors['primary']!.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  characterAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: emotionColors['primary']!.withOpacity(0.2),
                      child: Icon(
                        Icons.emoji_emotions,
                        color: emotionColors['primary'],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 주요 감정',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dominantEmotion.key,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.auto_graph,
                        size: 16,
                        color: emotionColors['primary'],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '강도: ${dominantEmotion.value.toStringAsFixed(1)}/10',
                        style: TextStyle(
                          fontSize: 13,
                          color: emotionColors['primary'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  /// 일기 작성 유도 카드
  Widget _buildWritingPrompt(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => context.push('/diaries/write'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.15),
              theme.colorScheme.secondary.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.edit_note,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 감정을',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '기록해보세요',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '오늘 하루는 어땠나요?',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

