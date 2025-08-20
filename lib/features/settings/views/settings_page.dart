import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/features/profile/providers/profile_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // 각 섹션의 펼침/접힘 상태
  final Map<String, bool> _expandedSections = {
    'account': false,
    'app': false,
    'privacy': false,
    'data': false,
    'support': false,
    'danger': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '설정',
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
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // 도움말 페이지로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 계정 설정
            _buildExpandableSection(
              key: 'account',
              title: '계정',
              emoji: '👤',
              children: [
                _buildSettingItem(
                  icon: Icons.edit,
                  title: '프로필 편집',
                  subtitle: '닉네임, 자기소개, 프로필 이미지',
                  onTap: () => context.push('/profile/edit'),
                ),
                _buildSettingItem(
                  icon: Icons.settings,
                  title: '계정 설정',
                  subtitle: '이메일, 비밀번호 변경',
                  onTap: () => context.push('/settings/account'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 앱 설정
            _buildExpandableSection(
              key: 'app',
              title: '앱 설정',
              emoji: '⚙️',
              children: [
                _buildSettingItem(
                  icon: Icons.notifications,
                  title: '알림 설정',
                  subtitle: '푸시 알림 및 이메일 설정',
                  onTap: () => context.push('/settings/notifications'),
                ),
                _buildSettingItem(
                  icon: Icons.dark_mode,
                  title: '테마 설정',
                  subtitle: '라이트/다크 모드 및 컬러',
                  onTap: () => context.push('/settings/theme'),
                ),
                _buildSettingItem(
                  icon: Icons.language,
                  title: '언어 설정',
                  subtitle: '앱 언어 및 지역 설정',
                  onTap: () => context.push('/settings/language'),
                ),
                _buildSettingItem(
                  icon: Icons.text_fields,
                  title: '폰트 설정',
                  subtitle: '폰트 크기 및 스타일',
                  onTap: () => context.push('/settings/font'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 개인정보 설정
            _buildExpandableSection(
              key: 'privacy',
              title: '개인정보',
              emoji: '🔒',
              children: [
                _buildSettingItem(
                  icon: Icons.security,
                  title: '보안 설정',
                  subtitle: '계정 보안 및 인증',
                  onTap: () => context.push('/settings/security'),
                ),
                _buildSettingItem(
                  icon: Icons.visibility,
                  title: '프라이버시 설정',
                  subtitle: '데이터 공개 범위 설정',
                  onTap: () => context.push('/settings/privacy'),
                ),
                _buildSettingItem(
                  icon: Icons.data_usage,
                  title: '데이터 공유 설정',
                  subtitle: '분석 데이터 수집 설정',
                  onTap: () => context.push('/settings/data-sharing'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 데이터 관리
            _buildExpandableSection(
              key: 'data',
              title: '데이터 관리',
              emoji: '💾',
              children: [
                _buildSettingItem(
                  icon: Icons.backup,
                  title: '데이터 백업',
                  subtitle: '클라우드에 데이터 백업',
                  onTap: () => context.push('/settings/backup'),
                ),
                _buildSettingItem(
                  icon: Icons.restore,
                  title: '데이터 복원',
                  subtitle: '백업에서 데이터 복원',
                  onTap: () => context.push('/settings/restore'),
                ),

                _buildSettingItem(
                  icon: Icons.delete_forever,
                  title: '데이터 삭제',
                  subtitle: '선택한 데이터 삭제',
                  onTap: () => context.push('/settings/data-delete'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 지원 및 정보
            _buildExpandableSection(
              key: 'support',
              title: '지원 및 정보',
              emoji: 'ℹ️',
              children: [
                _buildSettingItem(
                  icon: Icons.help,
                  title: '도움말',
                  subtitle: '앱 사용법 및 FAQ',
                  onTap: () => context.push('/settings/help'),
                ),
                _buildSettingItem(
                  icon: Icons.feedback,
                  title: '피드백 보내기',
                  subtitle: '의견 및 버그 신고',
                  onTap: () => context.push('/settings/feedback'),
                ),
                _buildSettingItem(
                  icon: Icons.info,
                  title: '앱 정보',
                  subtitle: '버전 및 라이선스 정보',
                  onTap: () => context.push('/settings/about'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 위험한 작업
            _buildExpandableSection(
              key: 'danger',
              title: '위험한 작업',
              emoji: '⚠️',
              children: [
                _buildSettingItem(
                  icon: Icons.logout,
                  title: '로그아웃',
                  subtitle: '현재 계정에서 로그아웃',
                  onTap: () => _showLogoutDialog(),
                  isDanger: true,
                ),
                _buildSettingItem(
                  icon: Icons.delete_forever,
                  title: '계정 삭제',
                  subtitle: '계정 및 모든 데이터 영구 삭제',
                  onTap: () => _showDeleteAccountDialog(),
                  isDanger: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String key,
    required String title,
    required String emoji,
    required List<Widget> children,
  }) {
    final isExpanded = _expandedSections[key] ?? false;
    
    return Container(
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
      child: Column(
        children: [
          // 헤더 (클릭 가능)
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[key] = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 구분선
          if (isExpanded)
            Divider(
              height: 1,
              color: AppTheme.divider,
              indent: 20,
              endIndent: 20,
            ),
          
          // 하위 항목들
          if (isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDanger ? AppTheme.error : AppTheme.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? AppTheme.error : AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textTertiary,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(profileProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text(
          '정말로 계정을 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없으며, 모든 데이터가 영구적으로 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _showDeleteAccountConfirmation();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('최종 확인'),
        content: const Text(
          '계정 삭제를 위한 최종 확인입니다.\n\n'
          '계정을 삭제하면:\n'
          '• 모든 프로필 데이터가 삭제됩니다\n'
          '• 모든 일기와 감정 기록이 삭제됩니다\n'
          '• Firebase 계정이 완전히 삭제됩니다\n'
          '• 이 작업은 되돌릴 수 없습니다\n\n'
          '정말로 진행하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('계정 삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final success = await ref.read(profileProvider.notifier).deleteAccount();
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계정이 삭제되었습니다')),
          );
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('계정 삭제에 실패했습니다: $e')),
          );
        }
      }
    }
  }
}
