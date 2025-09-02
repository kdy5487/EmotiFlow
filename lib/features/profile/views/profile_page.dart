import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/core/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emoti_flow/features/profile/providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('로그인이 필요합니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('로그인하기'),
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
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 16,
              ),
            ),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 프로필 헤더
            _buildProfileHeader(authState.user!, ref),
            const SizedBox(height: 20),
            
            // 계정 설정
            _buildAccountSettingsSection(context),
            const SizedBox(height: 20),
            
            // 프로필 통계
            _buildProfileStats(),
            const SizedBox(height: 20),
            
            // 감정 프로필
            _buildEmotionProfile(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            backgroundImage: profile?.profileImageUrl != null 
                ? NetworkImage(profile!.profileImageUrl!) 
                : (user.photoURL != null ? NetworkImage(user.photoURL!) : null),
            child: (profile?.profileImageUrl == null && user.photoURL == null)
                ? const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.nickname ?? user.displayName ?? '사용자',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    profile?.email ?? user.email ?? '이메일 없음',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '활성 사용자',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // 섹션 헤더
          Container(
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  '계정 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // 구분선
          const Divider(height: 1, color: AppTheme.divider),
          
          // 설정 항목들
          _buildSettingItem(
            context: context,
            icon: Icons.edit,
            title: '프로필 편집',
            subtitle: '닉네임, 자기소개, 프로필 이미지',
            onTap: () => context.push('/profile/edit'),
          ),
          _buildSettingItem(
            context: context,
            icon: Icons.settings,
            title: '계정 설정',
            subtitle: '이메일, 비밀번호 변경',
            onTap: () => context.push('/settings/account'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textTertiary,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                '활동 통계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.edit_note,
                  value: '24',
                  label: '일기',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.favorite,
                  value: '156',
                  label: '감정 기록',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today,
                  value: '7',
                  label: '연속 기록',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppTheme.primary,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                '감정 프로필',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEmotionItem(
                  emoji: '😊',
                  label: '기쁨',
                  percentage: 35,
                ),
              ),
              Expanded(
                child: _buildEmotionItem(
                  emoji: '😌',
                  label: '평온',
                  percentage: 28,
                ),
              ),
              Expanded(
                child: _buildEmotionItem(
                  emoji: '😔',
                  label: '슬픔',
                  percentage: 22,
                ),
              ),
              Expanded(
                child: _buildEmotionItem(
                  emoji: '😤',
                  label: '스트레스',
                  percentage: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionItem({
    required String emoji,
    required String label,
    required int percentage,
  }) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
