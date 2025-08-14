import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
              // TODO: 알림 페이지로 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘의 감정 요약
            _buildTodayMoodSection(context),
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

  Widget _buildTodayMoodSection(BuildContext context) {
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
                      '오늘의 감정',
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
                  text: '일기 작성하기',
                  onPressed: () => context.push('/diary/create'),
                  type: EmotiButtonType.primary,
                  size: EmotiButtonSize.medium,
                  icon: Icons.edit,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EmotiButton(
                  text: 'AI 분석',
                  onPressed: () => context.push('/ai'),
                  type: EmotiButtonType.outline,
                  size: EmotiButtonSize.medium,
                  icon: Icons.psychology,
                  isFullWidth: true,
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
                icon: Icons.music_note,
                title: '음악 듣기',
                subtitle: '감정에 맞는 음악',
                color: AppTheme.secondary,
                onTap: () => context.push('/music'),
              ),
            ),
            const SizedBox(width: 12),
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
                  color: AppTheme.secondary,
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
            type: EmotiButtonType.secondary,
            size: EmotiButtonSize.medium,
            icon: Icons.chat,
            isFullWidth: true,
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
