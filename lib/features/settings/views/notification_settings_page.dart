import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = false;
  bool _dailyReminderEnabled = true;
  bool _weeklyReportEnabled = true;
  bool _moodTrackingReminderEnabled = true;
  bool _communityUpdatesEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '알림 설정',
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
            // 푸시 알림
            _buildSection(
              title: '푸시 알림',
              icon: Icons.notifications,
              children: [
                SwitchListTile(
                  title: const Text('푸시 알림'),
                  subtitle: const Text('모든 푸시 알림을 받습니다'),
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 이메일 알림
            _buildSection(
              title: '이메일 알림',
              icon: Icons.email,
              children: [
                SwitchListTile(
                  title: const Text('이메일 알림'),
                  subtitle: const Text('이메일로 알림을 받습니다'),
                  value: _emailNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailNotificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 일일 알림
            _buildSection(
              title: '일일 알림',
              icon: Icons.schedule,
              children: [
                SwitchListTile(
                  title: const Text('일일 감정 기록 알림'),
                  subtitle: const Text('매일 감정을 기록하도록 알려줍니다'),
                  value: _dailyReminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dailyReminderEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('감정 추적 알림'),
                  subtitle: const Text('감정 변화를 추적하도록 알려줍니다'),
                  value: _moodTrackingReminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _moodTrackingReminderEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 주간 리포트
            _buildSection(
              title: '주간 리포트',
              icon: Icons.analytics,
              children: [
                SwitchListTile(
                  title: const Text('주간 감정 리포트'),
                  subtitle: const Text('주간 감정 요약을 받습니다'),
                  value: _weeklyReportEnabled,
                  onChanged: (value) {
                    setState(() {
                      _weeklyReportEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 커뮤니티
            _buildSection(
              title: '커뮤니티',
              icon: Icons.people,
              children: [
                SwitchListTile(
                  title: const Text('커뮤니티 업데이트'),
                  subtitle: const Text('커뮤니티 활동 알림을 받습니다'),
                  value: _communityUpdatesEnabled,
                  onChanged: (value) {
                    setState(() {
                      _communityUpdatesEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
