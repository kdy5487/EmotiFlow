import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_entry.dart';
import '../models/emotion.dart';

/// 일기 작성 화면의 상태를 관리하는 클래스
class DiaryWriteState {
  final String title;
  final String content;
  final List<String> selectedEmotions;
  final Map<String, int> emotionIntensities;
  final List<String> mediaUrls;
  final bool isLoading;
  final String? errorMessage;
  final bool isAIAnalysisEnabled;

  const DiaryWriteState({
    this.title = '',
    this.content = '',
    this.selectedEmotions = const [],
    this.emotionIntensities = const {},
    this.mediaUrls = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isAIAnalysisEnabled = true,
  });

  DiaryWriteState copyWith({
    String? title,
    String? content,
    List<String>? selectedEmotions,
    Map<String, int>? emotionIntensities,
    List<String>? mediaUrls,
    bool? isLoading,
    String? errorMessage,
    bool? isAIAnalysisEnabled,
  }) {
    return DiaryWriteState(
      title: title ?? this.title,
      content: content ?? this.content,
      selectedEmotions: selectedEmotions ?? this.selectedEmotions,
      emotionIntensities: emotionIntensities ?? this.emotionIntensities,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAIAnalysisEnabled: isAIAnalysisEnabled ?? this.isAIAnalysisEnabled,
    );
  }
}

/// 일기 작성 화면의 상태와 로직을 관리하는 ViewModel
class DiaryWriteViewModel extends StateNotifier<DiaryWriteState> {
  DiaryWriteViewModel() : super(const DiaryWriteState());

  // Getters
  String get title => state.title;
  String get content => state.content;
  List<String> get selectedEmotions => state.selectedEmotions;
  Map<String, int> get emotionIntensities => state.emotionIntensities;
  List<String> get mediaUrls => state.mediaUrls;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  bool get isAIAnalysisEnabled => state.isAIAnalysisEnabled;
  bool get canSave => state.title.trim().isNotEmpty && state.content.trim().isNotEmpty;

  /// 제목 설정
  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  /// 내용 설정
  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  /// 감정 선택/해제
  void toggleEmotion(String emotion) {
    if (state.selectedEmotions.contains(emotion)) {
      final newEmotions = List<String>.from(state.selectedEmotions)..remove(emotion);
      final newIntensities = Map<String, int>.from(state.emotionIntensities)..remove(emotion);
      state = state.copyWith(
        selectedEmotions: newEmotions,
        emotionIntensities: newIntensities,
      );
    } else {
      final newEmotions = List<String>.from(state.selectedEmotions)..add(emotion);
      final newIntensities = Map<String, int>.from(state.emotionIntensities)..[emotion] = 5;
      state = state.copyWith(
        selectedEmotions: newEmotions,
        emotionIntensities: newIntensities,
      );
    }
  }

  /// 감정 강도 설정
  void setEmotionIntensity(String emotion, int intensity) {
    if (state.selectedEmotions.contains(emotion)) {
      final newIntensities = Map<String, int>.from(state.emotionIntensities);
      newIntensities[emotion] = intensity.clamp(1, 10);
      state = state.copyWith(emotionIntensities: newIntensities);
    }
  }

  /// 미디어 URL 추가
  void addMediaUrl(String url) {
    if (!state.mediaUrls.contains(url)) {
      final newUrls = List<String>.from(state.mediaUrls)..add(url);
      state = state.copyWith(mediaUrls: newUrls);
    }
  }

  /// 미디어 URL 제거
  void removeMediaUrl(String url) {
    final newUrls = List<String>.from(state.mediaUrls)..remove(url);
    state = state.copyWith(mediaUrls: newUrls);
  }

  /// AI 분석 활성화/비활성화
  void toggleAIAnalysis() {
    state = state.copyWith(isAIAnalysisEnabled: !state.isAIAnalysisEnabled);
  }

  /// 현재 입력된 데이터로 DiaryEntry 객체 생성
  DiaryEntry createDiaryEntry(String userId) {
    return DiaryEntry(
      id: '', // Firestore에서 자동 생성
      userId: userId,
      title: state.title.trim(),
      content: state.content.trim(),
      emotions: List.from(state.selectedEmotions),
      emotionIntensities: Map.from(state.emotionIntensities),
      createdAt: DateTime.now(),
      mediaUrls: List.from(state.mediaUrls),
      aiAnalysis: null, // 나중에 AI 분석 결과로 업데이트
    );
  }

  /// 폼 초기화
  void resetForm() {
    state = const DiaryWriteState();
  }

  /// 기존 일기 데이터로 폼 초기화 (수정 모드)
  void initializeWithEntry(DiaryEntry entry) {
    state = DiaryWriteState(
      title: entry.title,
      content: entry.content,
      selectedEmotions: List.from(entry.emotions),
      emotionIntensities: Map.from(entry.emotionIntensities),
      mediaUrls: List.from(entry.mediaUrls),
    );
  }

  /// 로딩 상태 설정
  void _setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  /// 에러 메시지 설정
  void _setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 유효성 검사
  String? validateForm() {
    if (state.title.trim().isEmpty) {
      return '제목을 입력해주세요.';
    }
    if (state.content.trim().isEmpty) {
      return '내용을 입력해주세요.';
    }
    if (state.selectedEmotions.isEmpty) {
      return '최소 하나의 감정을 선택해주세요.';
    }
    return null;
  }

  /// 선택된 감정들의 평균 강도 계산
  double getAverageEmotionIntensity() {
    if (state.emotionIntensities.isEmpty) return 0.0;
    
    final total = state.emotionIntensities.values.reduce((a, b) => a + b);
    return total / state.emotionIntensities.length;
  }

  /// 가장 강한 감정 찾기
  String? getStrongestEmotion() {
    if (state.emotionIntensities.isEmpty) return null;
    
    String strongestEmotion = '';
    int maxIntensity = 0;
    
    state.emotionIntensities.forEach((emotion, intensity) {
      if (intensity > maxIntensity) {
        maxIntensity = intensity;
        strongestEmotion = emotion;
      }
    });
    
    return strongestEmotion;
  }
}

/// DiaryWriteViewModel을 위한 Riverpod provider
final diaryWriteProvider = StateNotifierProvider<DiaryWriteViewModel, DiaryWriteState>((ref) {
  return DiaryWriteViewModel();
});
