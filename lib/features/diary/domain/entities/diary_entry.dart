import 'media_file.dart';
import 'ai_analysis.dart';
import 'chat_message.dart';

enum DiaryType { free, aiChat }

class DiaryEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> emotions;
  final Map<String, int> emotionIntensities;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<MediaFile> mediaFiles;
  final AIAnalysis? aiAnalysis;
  final List<ChatMessage> chatHistory;
  final String? weather;
  final String? location;
  final List<String> tags;
  final bool isPublic;
  final DiaryType diaryType;
  final Map<String, dynamic>? metadata;

  DiaryEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.emotions,
    required this.emotionIntensities,
    required this.createdAt,
    this.updatedAt,
    this.mediaFiles = const [],
    this.aiAnalysis,
    this.chatHistory = const [],
    this.weather,
    this.location,
    this.tags = const [],
    this.isPublic = false,
    this.diaryType = DiaryType.free,
    this.metadata,
  });

  /// 순수 비즈니스 로직: 가장 강한 감정 추출
  String? get strongestEmotion {
    if (emotionIntensities.isEmpty) return null;
    return emotionIntensities.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 미디어 파일 개수
  int get mediaCount => mediaFiles.length;

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

  /// AI 분석 결과 존재 여부
  bool get hasAIAnalysis => aiAnalysis != null;
}

