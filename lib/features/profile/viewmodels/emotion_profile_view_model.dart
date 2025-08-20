import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

/// 감정 프로필 페이지의 ViewModel
/// UI 로직과 비즈니스 로직을 분리하여 관리
class EmotionProfileViewModel extends ChangeNotifier {
  final WidgetRef ref;
  
  EmotionProfileViewModel(this.ref);

  // 상태 변수들
  List<String> _selectedEmotions = [];
  Map<String, int> _emotionImportance = {};
  List<String> _expressionPreferences = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<String> get selectedEmotions => _selectedEmotions;
  Map<String, int> get emotionImportance => _emotionImportance;
  List<String> get expressionPreferences => _expressionPreferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setters
  set selectedEmotions(List<String> value) {
    _selectedEmotions = value;
    notifyListeners();
  }

  set emotionImportance(Map<String, int> value) {
    _emotionImportance = value;
    notifyListeners();
  }

  set expressionPreferences(List<String> value) {
    _expressionPreferences = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  /// 사용 가능한 감정 목록
  static const List<String> availableEmotions = [
    'joy', 'gratitude', 'excitement', 'calm', 'love',
    'sadness', 'anger', 'fear', 'surprise', 'neutral'
  ];

  /// 표현 방식 옵션
  static const List<Map<String, dynamic>> expressionOptions = [
    {'key': 'text', 'label': '텍스트', 'icon': Icons.text_fields},
    {'key': 'image', 'label': '이미지', 'icon': Icons.image},
    {'key': 'music', 'label': '음악', 'icon': Icons.music_note},
    {'key': 'drawing', 'label': '그림', 'icon': Icons.brush},
    {'key': 'voice', 'label': '음성', 'icon': Icons.mic},
  ];

  /// 감정 표시명 매핑
  static const Map<String, String> emotionDisplayNames = {
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

  /// 현재 감정 프로필 로드
  Future<void> loadCurrentEmotionProfile() async {
    try {
      isLoading = true;
      error = null;
      
      final profile = ref.read(profileProvider).profile;
      if (profile != null) {
        _selectedEmotions = List.from(profile.emotionProfile.preferredEmotions);
        _emotionImportance = Map.from(profile.emotionProfile.emotionImportance);
        _expressionPreferences = List.from(profile.emotionProfile.expressionPreferences);
      }
    } catch (e) {
      error = '감정 프로필을 불러올 수 없습니다: $e';
    } finally {
      isLoading = false;
    }
  }

  /// 감정 선택 토글
  void toggleEmotionSelection(String emotion) {
    if (_selectedEmotions.contains(emotion)) {
      _selectedEmotions.remove(emotion);
      _emotionImportance.remove(emotion);
    } else if (_selectedEmotions.length < 5) {
      _selectedEmotions.add(emotion);
      _emotionImportance[emotion] = 3; // 기본 중요도 3점
    }
    notifyListeners();
  }

  /// 감정 중요도 업데이트
  void updateEmotionImportance(String emotion, int importance) {
    if (_selectedEmotions.contains(emotion)) {
      _emotionImportance[emotion] = importance;
      notifyListeners();
    }
  }

  /// 표현 방식 선호도 토글
  void toggleExpressionPreference(String preference) {
    if (_expressionPreferences.contains(preference)) {
      _expressionPreferences.remove(preference);
    } else {
      _expressionPreferences.add(preference);
    }
    notifyListeners();
  }

  /// 감정 표시명 가져오기
  String getEmotionDisplayName(String emotion) {
    return emotionDisplayNames[emotion] ?? emotion;
  }

  /// 감정 프로필 저장
  Future<bool> saveEmotionProfile() async {
    try {
      if (_selectedEmotions.isEmpty) {
        error = '최소 하나의 감정을 선택해주세요';
        return false;
      }

      isLoading = true;
      error = null;

      final currentProfile = ref.read(profileProvider).profile;
      if (currentProfile == null) {
        error = '현재 프로필을 찾을 수 없습니다';
        return false;
      }

      // 감정 프로필 업데이트
      final updatedEmotionProfile = currentProfile.emotionProfile.copyWith(
        preferredEmotions: _selectedEmotions,
        emotionImportance: _emotionImportance,
        expressionPreferences: _expressionPreferences,
        lastUpdated: DateTime.now(),
      );

      await ref.read(profileProvider.notifier).updateEmotionProfile(updatedEmotionProfile);
      
      return true;
    } catch (e) {
      error = '감정 프로필을 저장할 수 없습니다: $e';
      return false;
    } finally {
      isLoading = false;
    }
  }

  /// 감정 프로필 초기화
  void resetEmotionProfile() {
    _selectedEmotions = [];
    _emotionImportance = {};
    _expressionPreferences = [];
    _error = null;
    notifyListeners();
  }

  /// 유효성 검사
  bool get isValid => _selectedEmotions.isNotEmpty;

  /// 변경사항이 있는지 확인
  bool get hasChanges {
    final currentProfile = ref.read(profileProvider).profile;
    if (currentProfile == null) return false;
    
    final currentEmotionProfile = currentProfile.emotionProfile;
    
    // 감정 목록 비교
    if (_selectedEmotions.length != currentEmotionProfile.preferredEmotions.length) {
      return true;
    }
    
    for (final emotion in _selectedEmotions) {
      if (!currentEmotionProfile.preferredEmotions.contains(emotion)) {
        return true;
      }
    }
    
    // 중요도 비교
    for (final emotion in _selectedEmotions) {
      if (_emotionImportance[emotion] != currentEmotionProfile.emotionImportance[emotion]) {
        return true;
      }
    }
    
    // 표현 방식 비교
    if (_expressionPreferences.length != currentEmotionProfile.expressionPreferences.length) {
      return true;
    }
    
    for (final preference in _expressionPreferences) {
      if (!currentEmotionProfile.expressionPreferences.contains(preference)) {
        return true;
      }
    }
    
    return false;
  }

  /// 선택된 감정 개수
  int get selectedEmotionsCount => _selectedEmotions.length;

  /// 최대 선택 가능한 감정 개수
  int get maxEmotionsCount => 5;

  /// 감정이 선택되었는지 확인
  bool isEmotionSelected(String emotion) => _selectedEmotions.contains(emotion);

  /// 표현 방식이 선택되었는지 확인
  bool isExpressionPreferenceSelected(String preference) => 
      _expressionPreferences.contains(preference);
}
