import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';

class FontSettingsPage extends ConsumerStatefulWidget {
  const FontSettingsPage({super.key});

  @override
  ConsumerState<FontSettingsPage> createState() => _FontSettingsPageState();
}

class _FontSettingsPageState extends ConsumerState<FontSettingsPage> {
  double _fontSize = 16.0;
  double _lineHeight = 1.5;
  bool _useSystemFontSize = false;
  String _selectedFontFamily = 'Pretendard';

  final List<String> _fontFamilies = [
    'Pretendard',
    'Noto Sans KR',
    'Roboto',
    'SF Pro Display',
    'Helvetica Neue',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '폰트 설정',
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
            // 시스템 폰트 크기 사용
            _buildSystemFontSection(),
            const SizedBox(height: 24),
            
            // 폰트 크기 조정
            if (!_useSystemFontSize) ...[
              _buildFontSizeSection(),
              const SizedBox(height: 24),
            ],
            
            // 폰트 패밀리
            _buildFontFamilySection(),
            const SizedBox(height: 24),
            
            // 줄 간격
            _buildLineHeightSection(),
            const SizedBox(height: 24),
            
            // 미리보기
            _buildPreviewSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemFontSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: SwitchListTile(
        title: const Text(
          '시스템 폰트 크기 사용',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          '시스템 설정의 폰트 크기를 따릅니다',
        ),
        value: _useSystemFontSize,
        onChanged: (value) {
          setState(() {
            _useSystemFontSize = value;
          });
        },
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.settings_system_daydream,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.text_fields, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              '폰트 크기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('작게'),
                  Text(
                    '${_fontSize.round()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Text('크게'),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 12,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.border,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '샘플 텍스트',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFontFamilySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.font_download, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              '폰트 패밀리',
              style: TextStyle(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fontFamilies.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.divider,
            ),
            itemBuilder: (context, index) {
              final fontFamily = _fontFamilies[index];
              final isSelected = fontFamily == _selectedFontFamily;
              
              return RadioListTile<String>(
                title: Text(
                  fontFamily,
                  style: TextStyle(
                    fontFamily: fontFamily == 'Pretendard' ? null : fontFamily,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  '샘플 텍스트',
                  style: TextStyle(
                    fontFamily: fontFamily == 'Pretendard' ? null : fontFamily,
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                value: fontFamily,
                groupValue: _selectedFontFamily,
                onChanged: (value) {
                  setState(() {
                    _selectedFontFamily = value!;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLineHeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_line_spacing, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              '줄 간격',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('좁게'),
                  Text(
                    '${_lineHeight.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const Text('넓게'),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _lineHeight,
                min: 1.0,
                max: 2.0,
                divisions: 10,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.border,
                onChanged: (value) {
                  setState(() {
                    _lineHeight = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.visibility, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              '미리보기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '제목',
                style: TextStyle(
                  fontSize: _useSystemFontSize ? 20 : _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  fontFamily: _selectedFontFamily == 'Pretendard' ? null : _selectedFontFamily,
                  height: _lineHeight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이것은 본문 텍스트입니다. 폰트 크기와 줄 간격, 폰트 패밀리를 조정하여 가독성을 향상시킬 수 있습니다.',
                style: TextStyle(
                  fontSize: _useSystemFontSize ? 16 : _fontSize,
                  fontFamily: _selectedFontFamily == 'Pretendard' ? null : _selectedFontFamily,
                  height: _lineHeight,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '현재 설정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('폰트 크기: ${_useSystemFontSize ? '시스템' : '${_fontSize.round()}'}'),
                    Text('폰트 패밀리: $_selectedFontFamily'),
                    Text('줄 간격: ${_lineHeight.toStringAsFixed(1)}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
