import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off,
                size: 64,
                color: AppTheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '로그인이 필요합니다',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 24),
              EmotiButton(
                text: '로그인하기',
                onPressed: () => context.push('/auth/login'),
                isFullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 프로필 헤더
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            
            // 프로필 통계
            _buildProfileStats(),
            const SizedBox(height: 24),
            
            // 감정 프로필
            _buildEmotionProfile(),
            const SizedBox(height: 24),
            
            // 프로필 관리
            _buildProfileManagementSection(context),
            const SizedBox(height: 24),
            
            // 계정 관리
            _buildAccountManagementSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primary,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? '사용자',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email ?? '',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 통계 요약',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('총 일기', '24', Icons.book),
                ),
                Expanded(
                  child: _buildStatItem('연속 기록', '7일', Icons.local_fire_department),
                ),
                Expanded(
                  child: _buildStatItem('감정 점수', '8.5', Icons.sentiment_satisfied),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionProfile() {
    return EmotiCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '😊 감정 프로필',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '주요 감정: 기쁨, 평온, 감사',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '감정 패턴: 긍정적인 감정이 주를 이루며, 스트레스 관리에 능숙함',
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileManagementSection(BuildContext context) {
    return EmotiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '프로필 관리',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('프로필 편집'),
            subtitle: const Text('개인정보 및 프로필 사진 변경'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/edit'),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions),
            title: const Text('감정 프로필 설정'),
            subtitle: const Text('감정 분석 및 추천 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/emotion'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagementSection(BuildContext context, WidgetRef ref) {
    return EmotiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '계정 관리',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('보안 설정'),
            subtitle: const Text('비밀번호 변경 및 보안 옵션'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 보안 설정 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 설정'),
            subtitle: const Text('앱 알림 및 이메일 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 알림 설정 페이지로 이동
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('개인정보'),
            subtitle: const Text('개인정보 처리방침 및 이용약관'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 개인정보 페이지로 이동
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.textTertiary),
            title: const Text('로그아웃'),
            subtitle: const Text('현재 계정에서 로그아웃'),
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말로 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
