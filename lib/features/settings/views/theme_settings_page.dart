import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';

class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ConsumerState<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  ThemeMode _selectedThemeMode = ThemeMode.system;
  Color _selectedPrimaryColor = AppTheme.primary;
  bool _useDynamicColors = false;

  final List<Color> _primaryColorOptions = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '테마 설정',
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
            // 테마 모드
            _buildSection(
              title: '테마 모드',
              icon: Icons.brightness_6,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('시스템 설정'),
                  subtitle: const Text('시스템 테마를 따릅니다'),
                  value: ThemeMode.system,
                  groupValue: _selectedThemeMode,
                  onChanged: (value) {
                    setState(() {
                      _selectedThemeMode = value!;
                    });
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('라이트 모드'),
                  subtitle: const Text('밝은 테마를 사용합니다'),
                  value: ThemeMode.light,
                  groupValue: _selectedThemeMode,
                  onChanged: (value) {
                    setState(() {
                      _selectedThemeMode = value!;
                    });
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('다크 모드'),
                  subtitle: const Text('어두운 테마를 사용합니다'),
                  value: ThemeMode.dark,
                  groupValue: _selectedThemeMode,
                  onChanged: (value) {
                    setState(() {
                      _selectedThemeMode = value!;
                    });
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
                  value: _useDynamicColors,
                  onChanged: (value) {
                    setState(() {
                      _useDynamicColors = value;
                    });
                  },
                ),
                if (!_useDynamicColors) ...[
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
                    children: _primaryColorOptions.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPrimaryColor = color;
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedPrimaryColor == color
                                  ? AppTheme.textPrimary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: _selectedPrimaryColor == color
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
                    color: _selectedPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
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
                  '현재 선택된 컬러: ${_selectedPrimaryColor.value.toRadixString(16).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
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
