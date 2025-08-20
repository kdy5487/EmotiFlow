import 'package:cloud_firestore/cloud_firestore.dart';

/// 미디어 타입
enum MediaType {
  image,    // 사진
  drawing,  // 그림
  voice,    // 음성
  video,    // 영상
}

/// 미디어 파일 모델
class MediaFile {
  final String id;
  final String url;
  final MediaType type;
  final String? thumbnailUrl;
  final int? duration; // 음성/영상의 경우
  final Map<String, dynamic>? metadata; // 추가 정보

  MediaFile({
    required this.id,
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.duration,
    this.metadata,
  });

  factory MediaFile.fromFirestore(Map<String, dynamic> data) {
    return MediaFile(
      id: data['id'] ?? '',
      url: data['url'] ?? '',
      type: MediaType.values.firstWhere(
        (e) => e.toString() == 'MediaType.${data['type']}',
        orElse: () => MediaType.image,
      ),
      thumbnailUrl: data['thumbnailUrl'],
      duration: data['duration'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'url': url,
      'type': type.toString().split('.').last,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'metadata': metadata,
    };
  }
}

/// AI 분석 결과 모델
class AIAnalysis {
  final String id;
  final String summary; // 일기 요약
  final List<String> keywords; // 감정 키워드
  final Map<String, double> emotionScores; // 감정별 점수
  final String advice; // AI 조언
  final List<String> actionItems; // 실행 가능한 액션 아이템
  final String moodTrend; // 감정 변화 트렌드
  final DateTime analyzedAt; // 분석 시간

  AIAnalysis({
    required this.id,
    required this.summary,
    required this.keywords,
    required this.emotionScores,
    required this.advice,
    required this.actionItems,
    required this.moodTrend,
    required this.analyzedAt,
  });

  factory AIAnalysis.fromFirestore(Map<String, dynamic> data) {
    return AIAnalysis(
      id: data['id'] ?? '',
      summary: data['summary'] ?? '',
      keywords: List<String>.from(data['keywords'] ?? []),
      emotionScores: Map<String, double>.from(data['emotionScores'] ?? {}),
      advice: data['advice'] ?? '',
      actionItems: List<String>.from(data['actionItems'] ?? []),
      moodTrend: data['moodTrend'] ?? '',
      analyzedAt: (data['analyzedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'summary': summary,
      'keywords': keywords,
      'emotionScores': emotionScores,
      'advice': advice,
      'actionItems': actionItems,
      'moodTrend': moodTrend,
      'analyzedAt': Timestamp.fromDate(analyzedAt),
    };
  }
}

/// AI 대화 메시지 모델
class ChatMessage {
  final String id;
  final String content;
  final bool isFromAI;
  final DateTime timestamp;
  final String? emotion; // 감정 관련 질문인 경우
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromAI,
    required this.timestamp,
    this.emotion,
    this.metadata,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] ?? '',
      content: data['content'] ?? '',
      isFromAI: data['isFromAI'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      emotion: data['emotion'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'content': content,
      'isFromAI': isFromAI,
      'timestamp': Timestamp.fromDate(timestamp),
      'emotion': emotion,
      'metadata': metadata,
    };
  }
}

/// 일기 종류
enum DiaryType {
  free,     // 자유형 일기
  aiChat,   // AI 대화형 일기
}

/// 일기 엔트리 모델
class DiaryEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> emotions; // 감정 카테고리 리스트
  final Map<String, int> emotionIntensities; // 감정별 강도 (1-10)
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<MediaFile> mediaFiles; // 미디어 파일 리스트
  final AIAnalysis? aiAnalysis; // AI 분석 결과
  final List<ChatMessage> chatHistory; // AI 대화 히스토리
  final String? weather; // 날씨 정보
  final String? location; // 위치 정보
  final List<String> tags; // 태그
  final bool isPublic; // 공개 여부
  final DiaryType diaryType; // 일기 종류
  final Map<String, dynamic>? metadata; // 추가 메타데이터

  DiaryEntry({
    String? id,
    required this.userId,
    required this.title,
    required this.content,
    required this.emotions,
    required this.emotionIntensities,
    DateTime? createdAt,
    this.updatedAt,
    this.mediaFiles = const [],
    this.aiAnalysis,
    this.chatHistory = const [],
    this.weather,
    this.location,
    this.tags = const [],
    this.isPublic = false,
    this.diaryType = DiaryType.free, // 기본값은 자유형
    this.metadata,
  }) : 
    id = id ?? _generateId(),
    createdAt = createdAt ?? DateTime.now();

  /// Firestore에서 데이터를 가져와 DiaryEntry 객체로 변환
  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      emotions: List<String>.from(data['emotions'] ?? []),
      emotionIntensities: Map<String, int>.from(data['emotionIntensities'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      mediaFiles: (data['mediaFiles'] as List<dynamic>?)
          ?.map((item) => MediaFile.fromFirestore(item))
          .toList() ?? [],
      aiAnalysis: data['aiAnalysis'] != null 
          ? AIAnalysis.fromFirestore(data['aiAnalysis'])
          : null,
      chatHistory: (data['chatHistory'] as List<dynamic>?)
          ?.map((item) => ChatMessage.fromFirestore(item))
          .toList() ?? [],
      weather: data['weather'],
      location: data['location'],
      tags: List<String>.from(data['tags'] ?? []),
      isPublic: data['isPublic'] ?? false,
      diaryType: DiaryType.values.firstWhere(
        (e) => e.toString() == 'DiaryType.${data['diaryType'] ?? 'free'}',
        orElse: () => DiaryType.free,
      ),
      metadata: data['metadata'],
    );
  }

  /// DiaryEntry 객체를 Firestore에 저장할 수 있는 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'emotions': emotions,
      'emotionIntensities': emotionIntensities,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'mediaFiles': mediaFiles.map((file) => file.toFirestore()).toList(),
      'aiAnalysis': aiAnalysis?.toFirestore(),
      'chatHistory': chatHistory.map((msg) => msg.toFirestore()).toList(),
      'weather': weather,
      'location': location,
      'tags': tags,
      'isPublic': isPublic,
      'diaryType': diaryType.toString().split('.').last,
      'metadata': metadata,
    };
  }

  /// 고유 ID 생성
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + DateTime.now().microsecond % 1000).toString();
  }

  /// 일기 내용을 복사하여 새로운 객체 생성
  DiaryEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    List<String>? emotions,
    Map<String, int>? emotionIntensities,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MediaFile>? mediaFiles,
    AIAnalysis? aiAnalysis,
    List<ChatMessage>? chatHistory,
    String? weather,
    String? location,
    List<String>? tags,
    bool? isPublic,
    DiaryType? diaryType,
    Map<String, dynamic>? metadata,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      emotions: emotions ?? this.emotions,
      emotionIntensities: emotionIntensities ?? this.emotionIntensities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      chatHistory: chatHistory ?? this.chatHistory,
      weather: weather ?? this.weather,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      diaryType: diaryType ?? this.diaryType,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 감정 강도 평균 계산
  double get averageEmotionIntensity {
    if (emotionIntensities.isEmpty) return 0.0;
    final total = emotionIntensities.values.reduce((a, b) => a + b);
    return total / emotionIntensities.length;
  }

  /// 가장 강한 감정 찾기
  String? get strongestEmotion {
    if (emotionIntensities.isEmpty) return null;
    String strongest = '';
    int maxIntensity = 0;
    emotionIntensities.forEach((emotion, intensity) {
      if (intensity > maxIntensity) {
        maxIntensity = intensity;
        strongest = emotion;
      }
    });
    return strongest;
  }

  /// 감정 타입 분류 (긍정/부정/중립)
  String get moodType {
    if (emotions.isEmpty) return 'neutral';
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final emotion in emotions) {
      // 감정 모델에서 moodType 확인
      // 여기서는 간단한 분류 로직 사용
      if (['기쁨', '평온', '설렘', '감사'].contains(emotion)) {
        positiveCount++;
      } else if (['슬픔', '분노', '걱정'].contains(emotion)) {
        negativeCount++;
      }
    }
    
    if (positiveCount > negativeCount) return 'positive';
    if (negativeCount > positiveCount) return 'negative';
    return 'neutral';
  }

  /// 일기 길이 (글자 수)
  int get contentLength => content.length;

  /// 단어 수
  int get wordCount => content.split(' ').where((word) => word.isNotEmpty).length;

  /// 미디어 파일 개수
  int get mediaCount => mediaFiles.length;

  /// 이미지 파일 개수
  int get imageCount => mediaFiles.where((file) => file.type == MediaType.image).length;

  /// 그림 파일 개수
  int get drawingCount => mediaFiles.where((file) => file.type == MediaType.drawing).length;

  /// 음성 파일 개수
  int get voiceCount => mediaFiles.where((file) => file.type == MediaType.voice).length;

  /// AI 분석 완료 여부
  bool get hasAIAnalysis => aiAnalysis != null;

  /// AI 대화 완료 여부
  bool get hasChatHistory => chatHistory.isNotEmpty;

  /// 공개 가능한 일기인지 확인
  bool get canBePublic => !isPublic && content.isNotEmpty && emotions.isNotEmpty;

  /// 커버 이미지 URL (첫 번째 이미지 파일)
  String? get coverImageUrl {
    final firstImage = mediaFiles.where((file) => file.type == MediaType.image).firstOrNull;
    return firstImage?.url;
  }

  /// 첫 번째 로컬 이미지 경로
  String? get firstLocalImagePath {
    final firstImage = mediaFiles.where((file) => file.type == MediaType.image).firstOrNull;
    return firstImage?.url;
  }
}
