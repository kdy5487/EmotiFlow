import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/features/music/providers/music_prompt_provider.dart';
import 'package:emoti_flow/features/music/providers/music_provider.dart';
import 'package:emoti_flow/features/settings/providers/settings_provider.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 홈 진입 시, 예약된 음악 전환 안내가 있으면 모달을 통해 간단하게 표시
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pending = ref.read(pendingMusicPromptProvider);
      if (pending != null) {
        final settings = ref.read(settingsProvider).settings.musicSettings;
        if (settings.enabled && settings.showPostDiaryMusicTip) {
          final confirm = await showModalBottomSheet<bool>(
            context: context,
            backgroundColor: Colors.white,
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'EmotiFlow',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
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
                      textAlign: TextAlign.center,
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
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
            tooltip: '프로필',
          ),
          IconButton(
            icon: const Icon(Icons.library_music_outlined),
            tooltip: '감정 기반 음악',
            onPressed: () => context.push('/music'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 감정 요약
            _buildTodayMoodSection(context, ref),
            const SizedBox(height: 24),
            
            // 빠른 액션 버튼들
            _buildQuickActionsSection(context),
            const SizedBox(height: 24),
            
            // 최근 일기 미리보기
            _buildRecentEntriesSection(context),
            const SizedBox(height: 24),
            
            // AI 일일 조언
            _buildAIDailyTipSection(context),
            const SizedBox(height: 24),
            
            // 감정 트렌드 미니 차트
            _buildEmotionTrendSection(context),
          ],
        ),
      ),
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
                const Icon(Icons.music_note, color: AppTheme.primary),
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
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

  Widget _buildTodayMoodSection(BuildContext context, WidgetRef ref) {
    final String userName = ref.read(authProvider).user?.displayName ?? '사용자';
    return EmotiCard(
      backgroundColor: AppTheme.primary.withOpacity(0.1),
      borderColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.joy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$userName님의 오늘의 감정',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '기쁨 - 행복한 하루였어요!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: EmotiButton(
                  text: '일기 목록',
                  onPressed: () => context.push('/diary'),
                  type: EmotiButtonType.primary,
                  size: EmotiButtonSize.medium,
                  icon: Icons.list,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EmotiButton(
                  text: 'AI 대화형',
                  onPressed: () => context.push('/diary/chat-write'),
                  type: EmotiButtonType.outline,
                  size: EmotiButtonSize.medium,
                  icon: Icons.chat,
                  isFullWidth: true,
                  textColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
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
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.edit,
                title: '자유형 일기',
                subtitle: '직접 작성하기',
                color: AppTheme.success,
                onTap: () => context.push('/diary/write'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.music_note,
                title: '음악 듣기',
                subtitle: '감정에 맞는 음악',
                color: AppTheme.secondary,
                onTap: () => context.push('/music'),
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
                icon: Icons.analytics,
                title: '트렌드 보기',
                subtitle: '감정 변화 분석',
                color: AppTheme.info,
                onTap: () => context.push('/analytics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.psychology,
                title: 'AI 분석',
                subtitle: '감정 분석 및 조언',
                color: AppTheme.primary,
                onTap: () => context.push('/ai'),
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
                icon: Icons.people,
                title: '커뮤니티',
                subtitle: '다른 사용자와 소통',
                color: AppTheme.warning,
                onTap: () => context.push('/community'),
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
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return EmotiCard(
      onTap: onTap,
      isClickable: true,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntriesSection(BuildContext context) {
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
            TextButton(
              onPressed: () => context.push('/diary'),
              child: const Text('더보기'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecentEntryCard(
          context,
          emotion: '기쁨',
          emotionColor: AppTheme.joy,
          title: '오늘은 정말 좋은 날이었어요',
          date: '2024년 12월 19일',
          onTap: () => context.push('/diary/detail'),
        ),
        const SizedBox(height: 12),
        _buildRecentEntryCard(
          context,
          emotion: '평온',
          emotionColor: AppTheme.calm,
          title: '차분한 마음으로 하루를 마무리',
          date: '2024년 12월 18일',
          onTap: () => context.push('/diary/detail'),
        ),
      ],
    );
  }

  Widget _buildRecentEntryCard(
    BuildContext context, {
    required String emotion,
    required Color emotionColor,
    required String title,
    required String date,
    required VoidCallback onTap,
  }) {
    return EmotiCard(
      onTap: onTap,
      isClickable: true,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: emotionColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                emotion,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAIDailyTipSection(BuildContext context) {
    return EmotiCard(
      backgroundColor: AppTheme.secondary.withOpacity(0.1),
      borderColor: AppTheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark,
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
                      'AI 일일 조언',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘의 감정을 기록하고 성장해보세요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          EmotiButton(
            text: 'AI와 대화하기',
            onPressed: () => context.push('/ai'),
            type: EmotiButtonType.outline,
            size: EmotiButtonSize.medium,
            icon: Icons.chat,
            isFullWidth: true,
            textColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionTrendSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '감정 트렌드',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/analytics'),
              child: const Text('자세히 보기'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        EmotiCard(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.divider,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 32,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '감정 차트가 여기에 표시됩니다',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
}
