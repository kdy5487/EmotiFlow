import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/layout/emoti_appbar.dart';
import '../../../shared/widgets/buttons/emoti_button.dart';
import '../../../shared/widgets/icons/emotion_icons.dart';
import '../../../theme/app_colors.dart';
import '../providers/profile_provider.dart';
import '../models/user_profile.dart';

/// 감정 프로필 페이지
class EmotionProfilePage extends ConsumerStatefulWidget {
  const EmotionProfilePage({super.key});

  @override
  ConsumerState<EmotionProfilePage> createState() => _EmotionProfilePageState();
}

class _EmotionProfilePageState extends ConsumerState<EmotionProfilePage> {
  final List<String> _availableEmotions = [
    'joy', 'gratitude', 'excitement', 'calm', 'love',
    'sadness', 'anger', 'fear', 'surprise', 'neutral'
  ];
  
  List<String> _selectedEmotions = [];
  Map<String, int> _emotionImportance = {};
  List<String> _expressionPreferences = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentEmotionProfile();
  }

  /// 현재 감정 프로필 로드
  void _loadCurrentEmotionProfile() {
    final profile = ref.read(profileProvider).profile;
    if (profile != null) {
      _selectedEmotions = List.from(profile.emotionProfile.preferredEmotions);
      _emotionImportance = Map.from(profile.emotionProfile.emotionImportance);
      _expressionPreferences = List.from(profile.emotionProfile.expressionPreferences);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).profile;
    
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: EmotiAppBar(
        title: '감정 프로필',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEmotionProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 감정 선택 섹션
          _buildEmotionSelectionSection(context),
          const SizedBox(height: 24),
          
          // 감정 중요도 섹션
          if (_selectedEmotions.isNotEmpty) ...[
            _buildEmotionImportanceSection(context),
            const SizedBox(height: 24),
          ],
          
          // 표현 방식 선호도 섹션
          _buildExpressionPreferencesSection(context),
          const SizedBox(height: 24),
          
          // 저장 버튼
          EmotiButton(
            text: '감정 프로필 저장',
            onPressed: _isLoading ? null : _saveEmotionProfile,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  /// 감정 선택 섹션
  Widget _buildEmotionSelectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💜 선호하는 감정 선택',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '자주 느끼거나 중요하게 생각하는 감정을 3-5개 선택해주세요',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableEmotions.map((emotion) {
            final isSelected = _selectedEmotions.contains(emotion);
            final emotionColor = EmotionIcons.getColor(emotion);
            final emotionIcon = EmotionIcons.getIcon(emotion);
            
            return GestureDetector(
              onTap: () => _toggleEmotionSelection(emotion),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? emotionColor.withOpacity(0.2)
                      : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? emotionColor : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      emotionIcon,
                      color: isSelected ? emotionColor : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getEmotionDisplayName(emotion),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? emotionColor : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        if (_selectedEmotions.length > 5) ...[
          const SizedBox(height: 12),
          Text(
            '감정은 최대 5개까지 선택할 수 있습니다',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.warning,
            ),
          ),
        ],
      ],
    );
  }

  /// 감정 중요도 섹션
  Widget _buildEmotionImportanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⭐ 감정별 중요도 설정',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '각 감정이 얼마나 중요한지 1-5점으로 평가해주세요',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        ...(_selectedEmotions.take(5).map((emotion) => 
          _buildEmotionImportanceItem(context, emotion)
        )),
      ],
    );
  }

  /// 감정 중요도 아이템
  Widget _buildEmotionImportanceItem(BuildContext context, String emotion) {
    final importance = _emotionImportance[emotion] ?? 3;
    final emotionColor = EmotionIcons.getColor(emotion);
    final emotionIcon = EmotionIcons.getIcon(emotion);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(emotionIcon, color: emotionColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getEmotionDisplayName(emotion),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$importance점',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: emotionColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 중요도 슬라이더
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: emotionColor,
              thumbColor: emotionColor,
              overlayColor: emotionColor.withOpacity(0.2),
            ),
            child: Slider(
              value: importance.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$importance점',
              onChanged: (value) {
                setState(() {
                  _emotionImportance[emotion] = value.round();
                });
              },
            ),
          ),
          
          // 중요도 설명
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '낮음',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                '높음',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 표현 방식 선호도 섹션
  Widget _buildExpressionPreferencesSection(BuildContext context) {
    final List<Map<String, dynamic>> expressionOptions = [
      {'key': 'text', 'label': '텍스트', 'icon': Icons.text_fields},
      {'key': 'image', 'label': '이미지', 'icon': Icons.image},
      {'key': 'music', 'label': '음악', 'icon': Icons.music_note},
      {'key': 'drawing', 'label': '그림', 'icon': Icons.brush},
      {'key': 'voice', 'label': '음성', 'icon': Icons.mic},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎨 표현 방식 선호도',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '감정을 표현할 때 선호하는 방식을 선택해주세요',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: expressionOptions.map((option) {
            final isSelected = _expressionPreferences.contains(option['key']);
            
            return GestureDetector(
              onTap: () => _toggleExpressionPreference(option['key'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option['label'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 감정 선택 토글
  void _toggleEmotionSelection(String emotion) {
    setState(() {
      if (_selectedEmotions.contains(emotion)) {
        _selectedEmotions.remove(emotion);
        _emotionImportance.remove(emotion);
      } else if (_selectedEmotions.length < 5) {
        _selectedEmotions.add(emotion);
        _emotionImportance[emotion] = 3; // 기본 중요도 3점
      }
    });
  }

  /// 표현 방식 선호도 토글
  void _toggleExpressionPreference(String preference) {
    setState(() {
      if (_expressionPreferences.contains(preference)) {
        _expressionPreferences.remove(preference);
      } else {
        _expressionPreferences.add(preference);
      }
    });
  }

  /// 감정 표시명 가져오기
  String _getEmotionDisplayName(String emotion) {
    const displayNames = {
      'joy': '기쁨',
      'gratitude': '감사',
      'excitement': '설렘',
      'calm': '평온',
      'love': '사랑',
      'sadness': '슬픔',
      'anger': '분노',
      'fear': '두려움',
      'surprise': '놀람',
      'neutral': '중립',
    };
    return displayNames[emotion] ?? emotion;
  }

  /// 감정 프로필 저장
  Future<void> _saveEmotionProfile() async {
    if (_selectedEmotions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나의 감정을 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = ref.read(profileProvider).profile;
      if (profile == null) return;

      final emotionProfile = EmotionProfile(
        preferredEmotions: _selectedEmotions.take(5).toList(),
        emotionImportance: Map.from(_emotionImportance),
        expressionPreferences: _expressionPreferences,
        emotionPatterns: profile.emotionProfile.emotionPatterns,
        lastUpdated: DateTime.now(),
      );

      final success = await ref.read(profileProvider.notifier)
          .updateEmotionProfile(emotionProfile);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('감정 프로필이 저장되었습니다')),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('감정 프로필 저장에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
