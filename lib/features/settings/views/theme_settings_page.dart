import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';
import 'package:emoti_flow/theme/theme_provider.dart';

class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  ThemeMode _selectedThemeMode = ThemeMode.light;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // 현재 테마 모드로 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentThemeMode = ref.read(themeProvider).themeMode;
      setState(() {
        _selectedThemeMode = currentThemeMode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          '테마 설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _hasChanges ? () {
              // 선택된 테마 모드 적용
              ref.read(themeProvider.notifier).setThemeMode(_selectedThemeMode);
              
              // 저장 완료 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('테마 설정이 저장되었습니다.'),
                  duration: Duration(seconds: 2),
                ),
              );
              
              // 홈페이지로 이동
              context.go('/');
            } : null,
            child: const Text('저장'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테마 모드
            _buildSection(
              title: '테마 모드',
              icon: Icons.brightness_6,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('라이트 모드'),
                  subtitle: const Text('밝은 테마를 사용합니다'),
                  value: ThemeMode.light,
                  groupValue: _selectedThemeMode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedThemeMode = value;
                        _hasChanges = true;
                      });
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('다크 모드'),
                  subtitle: const Text('어두운 테마를 사용합니다'),
                  value: ThemeMode.dark,
                  groupValue: _selectedThemeMode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedThemeMode = value;
                        _hasChanges = true;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 미리보기
            _buildSection(
              title: '미리보기',
              icon: Icons.visibility,
              children: [
                // 라이트 모드 미리보기
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.light_mode,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '라이트 모드',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '이것은 라이트 모드의 샘플 텍스트입니다.',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 다크 모드 미리보기
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.dark_mode,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '다크 모드',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '이것은 다크 모드의 샘플 텍스트입니다.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  '현재 선택된 테마: ${_selectedThemeMode == ThemeMode.light ? "라이트 모드" : "다크 모드"}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
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
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
