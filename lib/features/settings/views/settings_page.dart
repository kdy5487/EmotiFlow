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

  /// 추후 개발 예정 기능 안내 다이얼로그
  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.construction, color: Colors.orange),
              const SizedBox(width: 8),
              Text('$featureName'),
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱 설정
            _buildExpandableSection(
              key: 'app',
              title: '앱 설정',
              emoji: '⚙️',
              isDark: isDark,
              children: [
                _buildSettingItem(
                  icon: Icons.music_note,
                  title: '음악 설정',
                  subtitle: '감정 기반 음악, 자동재생, 볼륨, 툴팁 노출',
                  onTap: () => context.push('/music'),
                  isDark: isDark,
                ),
                _buildSettingItem(
                  icon: Icons.dark_mode,
                  title: '테마 설정',
                  subtitle: '라이트/다크 모드 및 컬러',
                  onTap: () => context.push('/settings/theme'),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 위험한 작업
            _buildExpandableSection(
              key: 'danger',
              title: '위험한 작업',
              emoji: '⚠️',
              isDark: isDark,
              children: [
                _buildSettingItem(
                  icon: Icons.logout,
                  title: '로그아웃',
                  subtitle: '현재 계정에서 로그아웃',
                  onTap: () => _showLogoutDialog(),
                  isDanger: true,
                  isDark: isDark,
                ),
                _buildSettingItem(
                  icon: Icons.delete_forever,
                  title: '계정 삭제',
                  subtitle: '계정 및 모든 데이터 영구 삭제',
                  onTap: () => _showDeleteAccountDialog(),
                  isDanger: true,
                  isDark: isDark,
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
    required bool isDark,
  }) {
    final isExpanded = _expandedSections[key] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
    required bool isDark,
    bool isDanger = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDanger ? AppTheme.error : Theme.of(context).colorScheme.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDanger ? AppTheme.error : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
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
        final success =
            await ref.read(profileProvider.notifier).deleteAccount();
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
