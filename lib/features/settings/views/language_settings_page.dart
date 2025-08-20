import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:emoti_flow/theme/app_theme.dart';

class LanguageSettingsPage extends ConsumerStatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  ConsumerState<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends ConsumerState<LanguageSettingsPage> {
  String _selectedLanguage = 'ko';
  String _selectedRegion = 'KR';

  final List<Map<String, String>> _languages = [
    {'code': 'ko', 'name': '한국어', 'nativeName': '한국어', 'region': 'KR'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'region': 'US'},
    {'code': 'ja', 'name': '日本語', 'nativeName': '日本語', 'region': 'JP'},
    {'code': 'zh', 'name': '中文', 'nativeName': '中文', 'region': 'CN'},
    {'code': 'es', 'name': 'Español', 'nativeName': 'Español', 'region': 'ES'},
    {'code': 'fr', 'name': 'Français', 'nativeName': 'Français', 'region': 'FR'},
    {'code': 'de', 'name': 'Deutsch', 'nativeName': 'Deutsch', 'region': 'DE'},
    {'code': 'it', 'name': 'Italiano', 'nativeName': 'Italiano', 'region': 'IT'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '언어 설정',
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
            // 현재 언어
            _buildCurrentLanguageSection(),
            const SizedBox(height: 24),
            
            // 언어 선택
            _buildLanguageSelectionSection(),
            const SizedBox(height: 24),
            
            // 지역 설정
            _buildRegionSection(),
            const SizedBox(height: 24),
            
            // 언어 변경 안내
            _buildLanguageChangeInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLanguageSection() {
    final currentLanguage = _languages.firstWhere(
      (lang) => lang['code'] == _selectedLanguage,
      orElse: () => _languages.first,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.language,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 언어',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentLanguage['nativeName']} (${currentLanguage['name']})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.translate, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              '언어 선택',
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
            itemCount: _languages.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.divider,
            ),
            itemBuilder: (context, index) {
              final language = _languages[index];
              final isSelected = language['code'] == _selectedLanguage;
              
              return RadioListTile<String>(
                title: Text(
                  language['nativeName']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  language['name']!,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                value: language['code']!,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                    _selectedRegion = language['region']!;
                  });
                },
                secondary: Container(
                  width: 32,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Center(
                    child: Text(
                      language['code']!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.public, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            const Text(
              '지역 설정',
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.flag, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '현재 지역',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRegionName(_selectedRegion),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _selectedRegion,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageChangeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.info,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '언어를 변경하면 앱을 재시작해야 할 수 있습니다.',
              style: TextStyle(
                color: AppTheme.info,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRegionName(String regionCode) {
    switch (regionCode) {
      case 'KR':
        return '대한민국';
      case 'US':
        return '미국';
      case 'JP':
        return '일본';
      case 'CN':
        return '중국';
      case 'ES':
        return '스페인';
      case 'FR':
        return '프랑스';
      case 'DE':
        return '독일';
      case 'IT':
        return '이탈리아';
      default:
        return '알 수 없음';
    }
  }
}
