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
  @override
  void initState() {
    super.initState();
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
            onPressed: () {
              // 설정이 이미 실시간으로 적용되므로 저장 완료 메시지만 표시
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('테마 설정이 저장되었습니다.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
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
                  title: const Text('시스템 설정'),
                  subtitle: const Text('시스템 테마를 따릅니다'),
                  value: ThemeMode.system,
                  groupValue: themeState.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeProvider.notifier).setThemeMode(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('라이트 모드'),
                  subtitle: const Text('밝은 테마를 사용합니다'),
                  value: ThemeMode.light,
                  groupValue: themeState.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeProvider.notifier).setThemeMode(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('다크 모드'),
                  subtitle: const Text('어두운 테마를 사용합니다'),
                  value: ThemeMode.dark,
                  groupValue: themeState.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeProvider.notifier).setThemeMode(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 프라이머리 컬러
            _buildSection(
              title: '프라이머리 컬러',
              icon: Icons.palette,
              children: [
                SwitchListTile(
                  title: const Text('동적 컬러'),
                  subtitle: const Text('시스템 컬러를 따릅니다'),
                  value: themeState.useDynamicColors,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setUseDynamicColors(value);
                  },
                ),
                if (!themeState.useDynamicColors) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '컬러 선택',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _getPrimaryColorOptions().map((color) {
                      return GestureDetector(
                        onTap: () {
                          ref.read(themeProvider.notifier).setPrimaryColor(color);
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: themeState.primaryColor == color
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: themeState.primaryColor == color
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            
            // 미리보기
            _buildSection(
              title: '미리보기',
              icon: Icons.visibility,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeState.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '샘플 버튼',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '현재 선택된 컬러: ${themeState.primaryColor.value.toRadixString(16).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '현재 테마: ${isDarkMode ? "다크 모드" : "라이트 모드"}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '배경색: ${Theme.of(context).colorScheme.background.value.toRadixString(16).toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '표면색: ${Theme.of(context).colorScheme.surface.value.toRadixString(16).toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '텍스트색: ${Theme.of(context).colorScheme.onSurface.value.toRadixString(16).toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getPrimaryColorOptions() {
    return [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.joy,
      AppTheme.love,
      AppTheme.calm,
      AppTheme.sadness,
      AppTheme.anger,
      AppTheme.fear,
      AppTheme.surprise,
    ];
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
