import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<String> mediaUrls; // 미디어 파일 URL 리스트
  final String? aiAnalysis; // AI 분석 결과
  final Map<String, dynamic>? metadata; // 추가 메타데이터

  DiaryEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.emotions,
    required this.emotionIntensities,
    required this.createdAt,
    this.updatedAt,
    this.mediaUrls = const [],
    this.aiAnalysis,
    this.metadata,
  });

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
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      aiAnalysis: data['aiAnalysis'],
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
      'mediaUrls': mediaUrls,
      'aiAnalysis': aiAnalysis,
      'metadata': metadata,
    };
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
    List<String>? mediaUrls,
    String? aiAnalysis,
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
      mediaUrls: mediaUrls ?? this.mediaUrls,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      metadata: metadata ?? this.metadata,
    );
  }
}
