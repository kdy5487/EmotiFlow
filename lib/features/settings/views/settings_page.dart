import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/app_typography.dart';
import 'package:emoti_flow/shared/widgets/cards/emoti_card.dart';
import 'package:emoti_flow/shared/widgets/buttons/emoti_button.dart';
import 'package:emoti_flow/shared/widgets/inputs/emoti_textfield.dart';
import '../widgets/settings_section_widget.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoBackupEnabled = true;
  bool _analyticsEnabled = false;
  String _language = '한국어';
  double _fontSize = 16.0;

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
            _buildAccountSection(),
            const SizedBox(height: 24),
            
            // 앱 설정
            _buildAppSettingsSection(),
            const SizedBox(height: 24),
            
            // 개인정보 설정
            _buildPrivacySection(),
            const SizedBox(height: 24),
            
            // 데이터 관리
            _buildDataManagementSection(),
            const SizedBox(height: 24),
            
            // 지원 및 정보
            _buildSupportSection(),
            const SizedBox(height: 24),
            
            // 위험한 작업
            _buildDangerZoneSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return SettingsSectionWidget(
      title: '계정',
      emoji: '👤',
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.error,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: const Text('사용자 프로필'),
          subtitle: const Text('프로필 정보 수정'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/profile/edit'),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('이메일'),
          subtitle: const Text('user@example.com'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 이메일 변경 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('비밀번호'),
          subtitle: const Text('마지막 변경: 30일 전'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 비밀번호 변경 페이지로 이동
          },
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection() {
    return SettingsSectionWidget(
      title: '앱 설정',
      emoji: '⚙️',
      children: [
        SwitchListTile(
          title: const Text('알림'),
          subtitle: const Text('푸시 알림 받기'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
          secondary: const Icon(Icons.notifications),
        ),
        SwitchListTile(
          title: const Text('다크 모드'),
          subtitle: const Text('어두운 테마 사용'),
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
          secondary: const Icon(Icons.dark_mode),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('언어'),
          subtitle: Text(_language),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showLanguageDialog();
          },
        ),
        ListTile(
          leading: const Icon(Icons.text_fields),
          title: const Text('글자 크기'),
          subtitle: Text('${_fontSize.round()}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showFontSizeDialog();
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return SettingsSectionWidget(
      title: '개인정보',
      emoji: '🔒',
      children: [
        SwitchListTile(
          title: const Text('분석 데이터 수집'),
          subtitle: const Text('앱 사용 통계 수집'),
          value: _analyticsEnabled,
          onChanged: (value) {
            setState(() {
              _analyticsEnabled = value;
            });
          },
          secondary: const Icon(Icons.analytics),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('개인정보 처리방침'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 개인정보 처리방침 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('이용약관'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 이용약관 페이지로 이동
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return SettingsSectionWidget(
      title: '데이터 관리',
      emoji: '💾',
      children: [
        SwitchListTile(
          title: const Text('자동 백업'),
          subtitle: const Text('클라우드에 자동 백업'),
          value: _autoBackupEnabled,
          onChanged: (value) {
            setState(() {
              _autoBackupEnabled = value;
            });
          },
          secondary: const Icon(Icons.backup),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('데이터 복원'),
          subtitle: const Text('백업에서 데이터 복원'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 데이터 복원 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('데이터 동기화'),
          subtitle: const Text('클라우드와 동기화'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 데이터 동기화 페이지로 이동
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return SettingsSectionWidget(
      title: '지원 및 정보',
      emoji: '❓',
      children: [
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('피드백 보내기'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 피드백 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('버그 신고'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 버그 신고 페이지로 이동
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('앱 정보'),
          subtitle: const Text('버전 1.0.0'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 앱 정보 페이지로 이동
          },
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return SettingsSectionWidget(
      title: '위험한 작업',
      emoji: '⚠️',
      children: [
        ListTile(
          leading: const Icon(Icons.delete_forever, color: AppTheme.error),
          title: const Text('계정 삭제'),
          subtitle: const Text('모든 데이터가 영구적으로 삭제됩니다'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _showDeleteAccountDialog();
          },
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('언어 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('한국어'),
              value: '한국어',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('글자 크기 조정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              label: _fontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
            Text(
              '샘플 텍스트',
              style: TextStyle(fontSize: _fontSize),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
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
          '정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없으며, 모든 데이터가 영구적으로 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 계정 삭제 로직 실행
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
}
