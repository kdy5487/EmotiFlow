import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/diary_entry.dart';
import '../../models/emotion.dart';

/// 일기 작성 화면의 상태를 관리하는 클래스
class DiaryWriteState {
  final String title;
  final String content;
  final List<String> selectedEmotions;
  final Map<String, int> emotionIntensities;
  final List<MediaFile> mediaFiles;
  final List<ChatMessage> chatHistory;
  final bool isLoading;
  final String? errorMessage;
  final bool isAIAnalysisEnabled;
  final bool isChatMode; // AI 대화형 모드 여부
  final DateTime selectedDate;
  final String? weather;
  final String? location;
  final List<String> tags;
  final bool isPublic;
  final bool isAutoSaveEnabled;
  final DateTime? lastAutoSave;

  DiaryWriteState({
    this.title = '',
    this.content = '',
    this.selectedEmotions = const [],
    this.emotionIntensities = const {},
    this.mediaFiles = const [],
    this.chatHistory = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isAIAnalysisEnabled = true,
    this.isChatMode = false,
    DateTime? selectedDate,
    this.weather,
    this.location,
    this.tags = const [],
    this.isPublic = false,
    this.isAutoSaveEnabled = true,
    this.lastAutoSave,
  }) : selectedDate = selectedDate ?? DateTime.now();

  DiaryWriteState copyWith({
    String? title,
    String? content,
    List<String>? selectedEmotions,
    Map<String, int>? emotionIntensities,
    List<MediaFile>? mediaFiles,
    List<ChatMessage>? chatHistory,
    bool? isLoading,
    String? errorMessage,
    bool? isAIAnalysisEnabled,
    bool? isChatMode,
    DateTime? selectedDate,
    String? weather,
    String? location,
    List<String>? tags,
    bool? isPublic,
    bool? isAutoSaveEnabled,
    DateTime? lastAutoSave,
  }) {
    return DiaryWriteState(
      title: title ?? this.title,
      content: content ?? this.content,
      selectedEmotions: selectedEmotions ?? this.selectedEmotions,
      emotionIntensities: emotionIntensities ?? this.emotionIntensities,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      chatHistory: chatHistory ?? this.chatHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAIAnalysisEnabled: isAIAnalysisEnabled ?? this.isAIAnalysisEnabled,
      isChatMode: isChatMode ?? this.isChatMode,
      selectedDate: selectedDate ?? this.selectedDate,
      weather: weather ?? this.weather,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isAutoSaveEnabled: isAutoSaveEnabled ?? this.isAutoSaveEnabled,
      lastAutoSave: lastAutoSave ?? this.lastAutoSave,
    );
  }
}

/// 일기 작성 화면의 상태와 로직을 관리하는 ViewModel
class DiaryWriteViewModel extends StateNotifier<DiaryWriteState> {
  DiaryWriteViewModel() : super(DiaryWriteState());

  // Getters
  String get title => state.title;
  String get content => state.content;
  List<String> get selectedEmotions => state.selectedEmotions;
  Map<String, int> get emotionIntensities => state.emotionIntensities;
  List<MediaFile> get mediaFiles => state.mediaFiles;
  List<ChatMessage> get chatHistory => state.chatHistory;
  bool get isLoading => state.isLoading;
  String? get errorMessage => state.errorMessage;
  bool get isAIAnalysisEnabled => state.isAIAnalysisEnabled;
  bool get isChatMode => state.isChatMode;
  DateTime get selectedDate => state.selectedDate;
  String? get weather => state.weather;
  String? get location => state.location;
  List<String> get tags => state.tags;
  bool get isPublic => state.isPublic;
  bool get isAutoSaveEnabled => state.isAutoSaveEnabled;
  DateTime? get lastAutoSave => state.lastAutoSave;
  
  bool get canSave => state.title.trim().isNotEmpty && state.content.trim().isNotEmpty;
  bool get hasChanges => state.title.isNotEmpty || state.content.isNotEmpty || state.selectedEmotions.isNotEmpty;

  /// 제목 설정
  void setTitle(String title) {
    state = state.copyWith(title: title);
    _autoSave();
  }

  /// 내용 설정
  void setContent(String content) {
    state = state.copyWith(content: content);
    _autoSave();
  }

  /// 감정 선택/해제 (최대 3개까지 선택 가능)
  void toggleEmotion(String emotion) {
    if (state.selectedEmotions.contains(emotion)) {
      // 이미 선택된 감정이면 해제
      final newEmotions = List<String>.from(state.selectedEmotions)..remove(emotion);
      final newIntensities = Map<String, int>.from(state.emotionIntensities)..remove(emotion);
      state = state.copyWith(
        selectedEmotions: newEmotions,
        emotionIntensities: newIntensities,
      );
    } else {
      // 새로운 감정 선택 (최대 3개 제한)
      if (state.selectedEmotions.length >= 3) {
        // 이미 3개가 선택된 경우 선택 불가
        return;
      }
      final newEmotions = List<String>.from(state.selectedEmotions)..add(emotion);
      final newIntensities = Map<String, int>.from(state.emotionIntensities)..[emotion] = 5;
      state = state.copyWith(
        selectedEmotions: newEmotions,
        emotionIntensities: newIntensities,
      );
    }
    _autoSave();
  }

  /// 감정 강도 설정
  void setEmotionIntensity(String emotion, int intensity) {
    if (state.selectedEmotions.contains(emotion)) {
      final newIntensities = Map<String, int>.from(state.emotionIntensities);
      newIntensities[emotion] = intensity.clamp(1, 10);
      state = state.copyWith(emotionIntensities: newIntensities);
      _autoSave();
    }
  }

  /// 미디어 파일 추가
  void addMediaFile(MediaFile mediaFile) {
    if (!state.mediaFiles.any((file) => file.id == mediaFile.id)) {
      final newFiles = List<MediaFile>.from(state.mediaFiles)..add(mediaFile);
      state = state.copyWith(mediaFiles: newFiles);
      _autoSave();
    }
  }

  /// 미디어 파일 제거
  void removeMediaFile(String mediaFileId) {
    final newFiles = state.mediaFiles.where((file) => file.id != mediaFileId).toList();
    state = state.copyWith(mediaFiles: newFiles);
    _autoSave();
  }

  /// AI 대화 메시지 추가
  void addChatMessage(ChatMessage message) {
    final newHistory = List<ChatMessage>.from(state.chatHistory)..add(message);
    state = state.copyWith(chatHistory: newHistory);
    _autoSave();
  }

  /// AI 대화 메시지 제거
  void removeChatMessage(String messageId) {
    final newHistory = state.chatHistory.where((msg) => msg.id != messageId).toList();
    state = state.copyWith(chatHistory: newHistory);
    _autoSave();
  }

  /// AI 대화 모드 전환
  void toggleChatMode() {
    state = state.copyWith(isChatMode: !state.isChatMode);
  }

  /// 날짜 선택
  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// 날씨 설정
  void setWeather(String weather) {
    state = state.copyWith(weather: weather);
  }

  /// 위치 설정
  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  /// 태그 추가
  void addTag(String tag) {
    if (!state.tags.contains(tag.trim())) {
      final newTags = List<String>.from(state.tags)..add(tag.trim());
      state = state.copyWith(tags: newTags);
      _autoSave();
    }
  }

  /// 태그 제거
  void removeTag(String tag) {
    final newTags = state.tags.where((t) => t != tag).toList();
    state = state.copyWith(tags: newTags);
    _autoSave();
  }

  /// 공개 설정 토글
  void togglePublic() {
    state = state.copyWith(isPublic: !state.isPublic);
  }

  /// AI 분석 활성화/비활성화
  void toggleAIAnalysis() {
    state = state.copyWith(isAIAnalysisEnabled: !state.isAIAnalysisEnabled);
  }

  /// 자동 저장 활성화/비활성화
  void toggleAutoSave() {
    state = state.copyWith(isAutoSaveEnabled: !state.isAIAnalysisEnabled);
  }

  /// 자동 저장 실행
  void _autoSave() {
    if (state.isAutoSaveEnabled && hasChanges) {
      state = state.copyWith(lastAutoSave: DateTime.now());
    }
  }

  /// 현재 입력된 데이터로 DiaryEntry 객체 생성
  DiaryEntry createDiaryEntry(String userId) {
    String title = state.title.trim();
    String content = state.content.trim();
    
    // AI 대화형 모드인 경우 제목과 내용 자동 생성
    if (state.isChatMode && state.chatHistory.isNotEmpty) {
      if (title.isEmpty) {
        title = _generateTitleFromChat();
      }
      if (content.isEmpty) {
        content = _generateContentFromChat();
      }
    }
    
    // 감정 자동 분석: AI 대화형이고 감정 미선택 시 자동 감정/강도 부여
    List<String> emotions = List.from(state.selectedEmotions);
    Map<String, int> intensities = Map.from(state.emotionIntensities);
    if (state.isChatMode && emotions.isEmpty) {
      final auto = _analyzeEmotionsFromChat();
      emotions = auto;
      intensities = { for (final e in auto) e: 5 };
    }

    return DiaryEntry(
      id: '', // Firestore에서 자동 생성
      userId: userId,
      title: title,
      content: content,
      emotions: emotions,
      emotionIntensities: intensities,
      createdAt: state.selectedDate,
      mediaFiles: List.from(state.mediaFiles),
      chatHistory: List.from(state.chatHistory),
      weather: state.weather,
      location: state.location,
      tags: List.from(state.tags),
      isPublic: state.isPublic,
      diaryType: state.isChatMode ? DiaryType.aiChat : DiaryType.free, // 일기 종류 설정
      aiAnalysis: null, // 나중에 AI 분석 결과로 업데이트
    );
  }

  /// 채팅 내용에서 제목 자동 생성
  String _generateTitleFromChat() {
    if (state.chatHistory.isEmpty) return 'AI와의 대화';
    
    // 사용자 메시지에서 첫 번째 의미있는 내용 추출
    final userMessages = state.chatHistory.where((msg) => !msg.isFromAI).toList();
    if (userMessages.isNotEmpty) {
      final firstUserMessage = userMessages.first.content;
      if (firstUserMessage.length > 10) {
        return '${firstUserMessage.substring(0, 10)}...';
      }
      return firstUserMessage;
    }
    
    return 'AI와의 대화';
  }

  /// 채팅 내용에서 일기 내용 자동 생성
  String _generateContentFromChat() {
    if (state.chatHistory.isEmpty) return '';
    
    // 모든 대화 내용을 하나의 텍스트로 결합
    final allMessages = state.chatHistory.map((msg) => msg.content).join('\n\n');
    
    // 너무 길면 자르기
    if (allMessages.length > 500) {
      return '${allMessages.substring(0, 500)}...';
    }
    
    return allMessages;
  }

  /// 채팅 내용에서 감정 자동 분석
  List<String> _analyzeEmotionsFromChat() {
    if (state.chatHistory.isEmpty) return ['평온'];
    
    final allText = state.chatHistory.map((msg) => msg.content).join(' ').toLowerCase();
    final emotions = <String>[];
    
    // 감정 키워드 분석
    if (allText.contains('기쁘') || allText.contains('행복') || allText.contains('좋아')) {
      emotions.add('기쁨');
    }
    if (allText.contains('슬프') || allText.contains('우울') || allText.contains('힘들')) {
      emotions.add('슬픔');
    }
    if (allText.contains('화나') || allText.contains('분노') || allText.contains('짜증')) {
      emotions.add('분노');
    }
    if (allText.contains('평온') || allText.contains('차분') || allText.contains('편안')) {
      emotions.add('평온');
    }
    if (allText.contains('설렘') || allText.contains('기대') || allText.contains('떨림')) {
      emotions.add('설렘');
    }
    if (allText.contains('걱정') || allText.contains('불안') || allText.contains('긴장')) {
      emotions.add('걱정');
    }
    if (allText.contains('감사') || allText.contains('고마워') || allText.contains('축복')) {
      emotions.add('감사');
    }
    if (allText.contains('지루') || allText.contains('따분') || allText.contains('재미없')) {
      emotions.add('지루함');
    }
    
    // 감정이 분석되지 않은 경우 기본값
    if (emotions.isEmpty) {
      emotions.add('평온');
    }
    
    return emotions;
  }

  /// 폼 초기화
  void resetForm() {
    state = DiaryWriteState();
  }

  /// 기존 일기 데이터로 폼 초기화 (수정 모드)
  void initializeWithEntry(DiaryEntry entry) {
    state = DiaryWriteState(
      title: entry.title,
      content: entry.content,
      selectedEmotions: List.from(entry.emotions),
      emotionIntensities: Map.from(entry.emotionIntensities),
      mediaFiles: List.from(entry.mediaFiles),
      chatHistory: List.from(entry.chatHistory),
      selectedDate: entry.createdAt,
      weather: entry.weather,
      location: entry.location,
      tags: List.from(entry.tags),
      isPublic: entry.isPublic,
    );
  }



  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 유효성 검사
  String? validateForm() {
    // AI 대화형은 모든 조건을 우회
    if (state.isChatMode) return null;

    if (state.selectedEmotions.isEmpty) {
      return '최소 하나의 감정을 선택해주세요.';
    }
    if (state.selectedDate.isAfter(DateTime.now())) {
      return '미래 날짜는 선택할 수 없습니다.';
    }
    
    // AI 대화형 모드인 경우 제목과 내용 검증 생략
    if (!state.isChatMode) {
      if (state.title.trim().isEmpty) {
        return '제목을 입력해주세요.';
      }
      if (state.content.trim().isEmpty) {
        return '내용을 입력해주세요.';
      }
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

  /// 감정 타입 분류 (긍정/부정/중립)
  String getMoodType() {
    if (state.selectedEmotions.isEmpty) return 'neutral';
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final emotion in state.selectedEmotions) {
      final emotionModel = Emotion.findByName(emotion);
      if (emotionModel != null) {
        if (emotionModel.moodType == 'positive') {
          positiveCount++;
        } else if (emotionModel.moodType == 'negative') {
          negativeCount++;
        }
      }
    }
    
    if (positiveCount > negativeCount) return 'positive';
    if (negativeCount > positiveCount) return 'negative';
    return 'neutral';
  }

  /// AI 대화 완료 여부
  bool get isChatComplete {
    if (!state.isChatMode) return false;
    if (state.chatHistory.isEmpty) return false;
    
    // AI 메시지와 사용자 메시지가 번갈아가며 있는지 확인
    final aiMessages = state.chatHistory.where((msg) => msg.isFromAI).length;
    final userMessages = state.chatHistory.where((msg) => !msg.isFromAI).length;
    
    // 최소 1개의 AI 메시지와 1개의 사용자 메시지가 있어야 함
    // 마지막 메시지가 사용자 메시지여야 대화가 완료된 것으로 간주
    final lastMessage = state.chatHistory.isNotEmpty ? state.chatHistory.last : null;
    final isLastMessageFromUser = lastMessage != null && !lastMessage.isFromAI;
    
    final isComplete = aiMessages > 0 && userMessages > 0 && isLastMessageFromUser;
    
    print('AI 대화 완료 확인: AI=$aiMessages, 사용자=$userMessages, 마지막사용자메시지=$isLastMessageFromUser, 완료=$isComplete');
    
    return isComplete;
  }

  /// 미디어 파일 개수
  int get mediaCount => state.mediaFiles.length;

  /// 이미지 파일 개수
  int get imageCount => state.mediaFiles.where((file) => file.type == MediaType.image).length;

  /// 그림 파일 개수
  int get drawingCount => state.mediaFiles.where((file) => file.type == MediaType.drawing).length;

  /// 음성 파일 개수
  int get voiceCount => state.mediaFiles.where((file) => file.type == MediaType.voice).length;

  /// 일기 길이 (글자 수)
  int get contentLength => state.content.length;

  /// 단어 수
  int get wordCount => state.content.split(' ').where((word) => word.isNotEmpty).length;

  /// AI 대화형 모드 설정
  void setIsChatMode(bool isChatMode) {
    state = state.copyWith(isChatMode: isChatMode);
  }

  /// 제목 업데이트
  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  /// 내용 업데이트
  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  /// 선택된 감정 업데이트
  void updateSelectedEmotions(List<String> emotions) {
    state = state.copyWith(selectedEmotions: emotions);
  }

  /// 저장 가능한 상태인지 확인
  bool get canSaveEntry {
    print('=== 저장 조건 확인 ===');
    print('선택된 감정: ${state.selectedEmotions}');
    print('AI 대화형 모드: ${state.isChatMode}');
    print('제목: "${state.title.trim()}"');
    print('내용: "${state.content.trim()}"');
    print('채팅 히스토리: ${state.chatHistory.length}개');
    
    // AI 대화형 모드인 경우 - 모든 조건 제거, 채팅만으로 저장 가능
    if (state.isChatMode) {
      print('✅ AI 대화형 저장 가능 - 모든 조건 무시');
      return true;
    }
    
    // 자유형 모드인 경우
    // 감정이 선택되지 않았으면 저장 불가
    if (state.selectedEmotions.isEmpty) {
      print('❌ 감정이 선택되지 않음');
      return false;
    }
    
    if (state.title.trim().isEmpty) {
      print('❌ 제목이 비어있음');
      return false;
    }
    if (state.content.trim().isEmpty) {
      print('❌ 내용이 비어있음');
      return false;
    }
    
    print('✅ 자유형 저장 가능');
    return true;
  }

  /// 자동 저장 필요 여부
  bool get needsAutoSave {
    return state.isAutoSaveEnabled && 
           hasChanges && 
           (state.lastAutoSave == null || 
            DateTime.now().difference(state.lastAutoSave!).inMinutes >= 1);
  }

  /// 자동 저장 실행
  void executeAutoSave() {
    if (needsAutoSave) {
      _autoSave();
    }
  }
}

/// DiaryWriteViewModel을 위한 Riverpod provider
final diaryWriteProvider = StateNotifierProvider<DiaryWriteViewModel, DiaryWriteState>((ref) {
  return DiaryWriteViewModel();
});
