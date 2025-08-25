import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/theme_provider.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/features/music/providers/music_prompt_provider.dart';
import 'package:emoti_flow/features/music/providers/music_provider.dart';
import 'package:emoti_flow/features/settings/providers/settings_provider.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/features/diary/providers/diary_provider.dart';
import 'package:emoti_flow/features/diary/models/diary_entry.dart';
import 'package:emoti_flow/features/music/services/audio_player_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// 음악 재생 파동 효과를 그리는 CustomPainter
class MusicWavePainter extends CustomPainter {
  final double animationValue;
  
  MusicWavePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B7FF6).withOpacity(0.3) // 테마 색상 사용
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 파동 효과 그리기
    for (int i = 0; i < 3; i++) {
      final waveRadius = radius * (0.3 + i * 0.2) * (0.5 + animationValue * 0.5);
      final opacity = (1.0 - animationValue) * (0.8 - i * 0.2);
      
      if (opacity > 0) {
        paint.color = const Color(0xFF8B7FF6).withOpacity(opacity); // 테마 색상 사용
        canvas.drawCircle(center, waveRadius, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 홈 진입 시, 예약된 음악 전환 안내가 있으면 모달을 통해 간단하게 표시
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pending = ref.read(pendingMusicPromptProvider);
      if (pending != null) {
        final settings = ref.read(settingsProvider).settings.musicSettings;
        if (settings.enabled && settings.showPostDiaryMusicTip) {
          final confirm = await showModalBottomSheet<bool>(
            context: context,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => _musicPromptSheet(context, emotion: pending.emotion, intensity: pending.intensity),
          );
          if (confirm == true) {
            await ref.read(musicProvider.notifier).loadRecommendations(
                  emotion: pending.emotion,
                  intensity: pending.intensity,
                  source: pending.source,
                );
          }
        }
        // 소비하고 초기화
        ref.read(pendingMusicPromptProvider.notifier).state = null;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'EmotiFlow',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.construction, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text('알림'),
                      ],
                    ),
                    content: const Text(
                      '이 기능은 현재 개발 중입니다.\n\n추후 업데이트를 통해 제공될 예정이니\n잠시만 기다려주세요!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('확인'),
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: '알림',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테마 전환 테스트 카드
            _buildThemeTestCard(context, ref),
            const SizedBox(height: 24),
            
            // 오늘의 감정 체크 카드
            _buildEmotionCheckCard(context, ref),
            const SizedBox(height: 24),
            
            // 빠른 액션 섹션
            _buildQuickActionsSection(context),
            const SizedBox(height: 24),
            
            // 최근 일기 요약
            _buildRecentDiariesSection(context, ref),
            const SizedBox(height: 24),
            
            // 감정 트렌드 섹션
            _buildSimpleEmotionTrendSection(context, ref),
            const SizedBox(height: 24),
            
            // AI 일일 조언
            _buildAIDailyTipSection(context, ref),
          ],
        ),
      ),
      bottomSheet: _buildMiniPlayer(context, ref),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// 간단한 음악 전환 프롬프트 시트
  Widget _musicPromptSheet(BuildContext context, {required String emotion, required int intensity}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('음악 전환', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text('오늘의 감정("$emotion", 강도 $intensity)에 맞춰 음악을 바꿀까요?'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('나중에'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
                    child: const Text('바꾸기'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, WidgetRef ref) {
    final music = ref.watch(musicProvider);
    final settings = ref.watch(settingsProvider).settings.musicSettings;
    
    // 음악이 재생 중이 아니거나 홈 화면 미니 플레이어 표시가 비활성화된 경우 숨김
    if (music.nowPlaying == null || !settings.showHomeMiniPlayer) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
                          Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${music.nowPlaying!.title} · ${music.nowPlaying!.artist}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => ref.read(musicProvider.notifier).previous(),
            icon: const Icon(Icons.skip_previous),
          ),
          IconButton(
            onPressed: () {
              final t = music.nowPlaying;
              if (t == null) return;
              ref.read(musicProvider.notifier).play(t);
            },
            icon: const Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () => ref.read(musicProvider.notifier).next(),
            icon: const Icon(Icons.skip_next),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionCheckCard(BuildContext context, WidgetRef ref) {
    final String userName = ref.read(authProvider).user?.displayName ?? '사용자';
    final diaries = ref.watch(diaryProvider).diaryEntries;
    
    // 오늘 작성한 일기들
    final today = DateTime.now();
    final todayDiaries = diaries.where((diary) => 
      diary.createdAt.year == today.year && 
      diary.createdAt.month == today.month && 
      diary.createdAt.day == today.day
    ).toList();
    
    // 오늘 일기가 있으면 감정 상태 표시, 없으면 일기 작성 유도
    if (todayDiaries.isNotEmpty) {
      return _buildTodayEmotionSummary(context, ref, todayDiaries);
    } else {
      return _buildDiaryWritingPrompt(context, ref, userName);
    }
  }

  /// 오늘 작성한 일기의 감정 요약
  Widget _buildTodayEmotionSummary(BuildContext context, WidgetRef ref, List<DiaryEntry> todayDiaries) {
    // 감정별 평균 강도 계산
    final emotionIntensities = <String, List<int>>{};
    for (final diary in todayDiaries) {
      for (final emotion in diary.emotions) {
        final intensity = diary.emotionIntensities[emotion] ?? 5;
        emotionIntensities.putIfAbsent(emotion, () => []).add(intensity);
      }
    }
    
    final averageEmotions = emotionIntensities.map((emotion, intensities) => 
      MapEntry(emotion, intensities.reduce((a, b) => a + b) / intensities.length)
    );
    
    // 가장 강한 감정 찾기
    final dominantEmotion = averageEmotions.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 감정',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        EmotiCard(
          onTap: () => context.push('/diary'),
          isClickable: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '감정 요약',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${todayDiaries.length}개의 일기를 완성했어요',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.textTertiary,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 주요 감정 표시
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '주요 감정: ${dominantEmotion.key} (${dominantEmotion.value.toStringAsFixed(1)}/10)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 일기 작성 유도 섹션
  Widget _buildDiaryWritingPrompt(BuildContext context, WidgetRef ref, String userName) {
    return EmotiCard(
      onTap: () => context.push('/diary'),
      isClickable: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.emoji_emotions,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '안녕하세요, $userName님!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '오늘 하루는 어떠셨나요?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textTertiary,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 일기 작성 방법 선택
            Row(
              children: [
                Expanded(
                  child: _buildDiaryMethodCard(
                    context,
                    icon: Icons.edit,
                    title: '자유 일기',
                    subtitle: '직접 작성하기',
                    color: AppTheme.success,
                    onTap: () => context.push('/diary/write'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDiaryMethodCard(
                    context,
                    icon: Icons.chat,
                    title: 'AI 채팅 일기',
                    subtitle: 'AI와 대화하며',
                    color: AppTheme.info,
                    onTap: () => context.push('/diary/chat-write'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 일기 작성 방법 카드
  Widget _buildDiaryMethodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // 2x2 그리드 레이아웃
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.list,
                title: '일기 목록',
                color: AppTheme.primary,
                onTap: () => context.push('/diary'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.edit,
                title: '일기 작성',
                color: AppTheme.success,
                onTap: () => _showDiaryWritingOptions(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.music_note,
                title: '음악',
                color: AppTheme.secondary,
                onTap: () => context.push('/music'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.psychology,
                title: 'AI 분석',
                color: AppTheme.info,
                onTap: () => context.push('/ai'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 일기 작성 옵션 선택 다이얼로그
  void _showDiaryWritingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '일기 작성 방법 선택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildDiaryOptionCard(
                    context,
                    icon: Icons.edit,
                    title: '자유 일기',
                    subtitle: '직접 작성하기',
                    color: AppTheme.success,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/diary/write');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDiaryOptionCard(
                    context,
                    icon: Icons.chat,
                    title: 'AI 채팅 일기',
                    subtitle: 'AI와 대화하며',
                    color: AppTheme.info,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/diary/chat-write');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 일기 작성 옵션 카드
  Widget _buildDiaryOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleEmotionTrendSection(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryProvider);
    final entries = diaryState.diaryEntries;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '감정 트렌드',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        EmotiCard(
          onTap: () => context.push('/ai'),
          isClickable: true,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.info.withOpacity(0.05),
              border: Border.all(color: AppTheme.info.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.info,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 감정 분석',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.info,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '감정 패턴을 분석해보세요',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.textTertiary,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 간략한 감정 트렌드 그래프
                if (entries.isNotEmpty) ...[
                  Container(
                    height: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.info.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '주간 감정 변화',
                          style: TextStyle(
                            color: AppTheme.info,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 간단한 막대 그래프
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _buildWeeklyTrendBars(entries),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 감정 통계 요약
                  Row(
                    children: [
                      Expanded(
                        child: _buildEmotionStat(
                          '주요 감정',
                          _getDominantEmotion(entries),
                          '${_calculateAverageIntensity(entries).toStringAsFixed(1)}/10',
                          AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEmotionStat(
                          '분석 일기',
                          '${entries.length}개',
                          '최근 기록',
                          AppTheme.info,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.info.withOpacity(0.2)),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 24,
                            color: AppTheme.info,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '일기를 작성하면\n감정 트렌드를 볼 수 있어요',
                            style: TextStyle(
                              color: AppTheme.info,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 주간 트렌드 바 생성
  List<Widget> _buildWeeklyTrendBars(List<DiaryEntry> entries) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekData = List.filled(7, 0.0);
    final labels = ['월', '화', '수', '목', '금', '토', '일'];

    // 실제 데이터 기반으로 계산
    for (final entry in entries) {
      final entryDate = entry.createdAt is DateTime ? entry.createdAt : (entry.createdAt as dynamic).toDate();
      final daysDiff = entryDate.difference(weekStart).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        final intensity = entry.emotionIntensities.values.isNotEmpty 
            ? entry.emotionIntensities.values.first.toDouble() 
            : 5.0;
        weekData[daysDiff] = intensity;
      }
    }

    return List.generate(7, (index) => _buildTrendBar(
      labels[index], 
      weekData[index] / 10.0, // 0.0 ~ 1.0 범위로 정규화
      weekData[index] > 0 ? AppTheme.primary : AppTheme.textTertiary,
    ));
  }

  /// 트렌드 막대 그래프 바
  Widget _buildTrendBar(String label, double value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: 40 * value, // 최대 높이 40px
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 감정 통계 카드
  Widget _buildEmotionStat(String title, String emotion, String score, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            emotion,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            score,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 지배적인 감정 찾기
  String _getDominantEmotion(List<DiaryEntry> entries) {
    if (entries.isEmpty) return '평온';
    
    final emotionCounts = <String, int>{};
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }
    
    if (emotionCounts.isEmpty) return '평온';
    
    final dominant = emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return dominant.key;
  }

  /// 평균 강도 계산
  double _calculateAverageIntensity(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 5.0;
    
    double totalIntensity = 0.0;
    int count = 0;
    
    for (final entry in entries) {
      if (entry.emotionIntensities.isNotEmpty) {
        totalIntensity += entry.emotionIntensities.values.first.toDouble();
        count++;
      }
    }
    
    return count > 0 ? totalIntensity / count : 5.0;
  }

  Widget _buildAIDailyTipSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 일일 조언',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        EmotiCard(
          onTap: () => context.push('/ai'),
          isClickable: true,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.warning.withOpacity(0.05),
              border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 조언 카드',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warning,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI가 맞춤형 조언을 제공해드려요',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.textTertiary,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 오늘 뽑은 카드가 있으면 표시
                Consumer(
                  builder: (context, ref, child) {
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _loadTodaySelectedCard(),
                      builder: (context, snapshot) {
                        final selectedCard = snapshot.data;
                        
                        if (selectedCard != null) {
                          return FutureBuilder<String?>(
                            future: _loadTodayAdviceText(),
                            builder: (context, adviceSnapshot) {
                              final advice = adviceSnapshot.data ?? '';
                              
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: selectedCard['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: selectedCard['color'].withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          selectedCard['icon'],
                                          color: selectedCard['color'],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedCard['title'],
                                          style: TextStyle(
                                            color: selectedCard['color'],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      advice.isNotEmpty ? advice : '오늘의 조언을 확인해보세요',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.card_giftcard,
                                  color: AppTheme.warning,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '조언 카드를 뽑아보세요!',
                                    style: TextStyle(
                                      color: AppTheme.warning,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 오늘 선택된 카드 불러오기
  Future<Map<String, dynamic>?> _loadTodaySelectedCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastSelectedDate = prefs.getString('last_advice_card_date');
      
      if (lastSelectedDate == today) {
        final selectedCardId = prefs.getString('selected_advice_card_id');
        if (selectedCardId != null) {
          // AI 분석 페이지와 동일한 카드 목록 사용
          final defaultCards = [
            {
              'id': 'nature',
              'title': '자연과 힐링',
              'icon': Icons.nature,
              'color': Colors.green,
            },
            {
              'id': 'gratitude',
              'title': '감사와 성찰',
              'icon': Icons.favorite,
              'color': Colors.red,
            },
            {
              'id': 'growth',
              'title': '새로운 시작',
              'icon': Icons.trending_up,
              'color': Colors.blue,
            },
            {
              'id': 'relationship',
              'title': '관계와 소통',
              'icon': Icons.people,
              'color': Colors.purple,
            },
            {
              'id': 'selfcare',
              'title': '자기 돌봄',
              'icon': Icons.spa,
              'color': Colors.orange,
            },
            {
              'id': 'creativity',
              'title': '창의적 활동',
              'icon': Icons.brush,
              'color': Colors.teal,
            },
          ];
          
          return defaultCards.firstWhere(
            (card) => card['id'] == selectedCardId,
            orElse: () => defaultCards.first,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 오늘 선택된 카드의 조언 텍스트 불러오기
  Future<String?> _loadTodayAdviceText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastSelectedDate = prefs.getString('last_advice_card_date');
      
      if (lastSelectedDate == today) {
        return prefs.getString('selected_advice_text');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildRecentDiariesSection(BuildContext context, WidgetRef ref) {
    final diariesState = ref.watch(diaryProvider);
    final diaries = diariesState.diaryEntries;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 일기',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // 일기 작성으로 가는 버튼 (2개 아이콘)
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showDiaryWritingOptions(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/diary'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.list,
                      color: AppTheme.secondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 데이터 로딩 중이거나 비어있을 때
        if (diaries.isEmpty) 
          EmotiCard(
            onTap: () => context.push('/diary'),
            isClickable: true,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.primary.withOpacity(0.05),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book,
                      size: 24,
                      color: AppTheme.primary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '아직 일기가 없어요\n첫 번째 일기를 작성해보세요!',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: diaries.length > 3 ? 3 : diaries.length,
            itemBuilder: (context, index) {
              final diary = diaries[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: EmotiCard(
                  onTap: () => context.push('/diary/detail/${diary.id}'),
                  isClickable: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.emoji_emotions,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diary.title.isNotEmpty ? diary.title : '제목 없음',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(diary.createdAt),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.textTertiary,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// 날짜 포맷팅
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

  /// 시간 포맷팅 (MM:SS)
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }


  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // 홈 - 이미 있음
            break;
          case 1:
            context.push('/diary');
            break;
          case 2:
            context.push('/ai');
            break;
          case 3:
            context.push('/community');
            break;
          case 4:
            context.push('/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: '일기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: 'AI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: '커뮤니티',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '설정',
        ),
      ],
    );
  }

  /// 테마 테스트 카드
  Widget _buildThemeTestCard(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '테마 테스트',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '현재 테마: ${isDarkMode ? "다크 모드" : "라이트 모드"}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '테마를 변경하려면 설정 > 앱 테마 설정으로 이동하세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('테마 설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 테마 정보 카드
  Widget _buildThemeInfoCard(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '현재 테마 정보',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '테마 모드: ${isDarkMode ? "다크 모드" : "라이트 모드"}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '배경색: ${Theme.of(context).colorScheme.background.value.toRadixString(16).toUpperCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            '표면색: ${Theme.of(context).colorScheme.surface.value.toRadixString(16).toUpperCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            '프라이머리: ${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
