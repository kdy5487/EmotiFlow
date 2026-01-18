import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/diary_entry.dart';
import 'media_file_model.dart';
import 'ai_analysis_model.dart';
import 'chat_message_model.dart';

class DiaryModel extends DiaryEntry {
  DiaryModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.emotions,
    required super.emotionIntensities,
    required super.createdAt,
    super.updatedAt,
    super.mediaFiles,
    super.aiAnalysis,
    super.chatHistory,
    super.weather,
    super.location,
    super.tags,
    super.isPublic,
    super.diaryType,
    super.metadata,
  });

  factory DiaryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      emotions: List<String>.from(data['emotions'] ?? []),
      emotionIntensities: Map<String, int>.from(data['emotionIntensities'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      mediaFiles: (data['mediaFiles'] as List<dynamic>?)
              ?.map((item) => MediaFileModel.fromMap(item))
              .toList() ?? [],
      aiAnalysis: data['aiAnalysis'] != null ? AIAnalysisModel.fromMap(data['aiAnalysis']) : null,
      chatHistory: (data['chatHistory'] as List<dynamic>?)
              ?.map((item) => ChatMessageModel.fromMap(item))
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'emotions': emotions,
      'emotionIntensities': emotionIntensities,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'mediaFiles': mediaFiles.map((file) {
        if (file is MediaFileModel) return file.toMap();
        return MediaFileModel(
          id: file.id, url: file.url, type: file.type, 
          thumbnailUrl: file.thumbnailUrl, duration: file.duration, metadata: file.metadata
        ).toMap();
      }).toList(),
      'aiAnalysis': aiAnalysis != null ? (aiAnalysis is AIAnalysisModel ? (aiAnalysis as AIAnalysisModel).toMap() : AIAnalysisModel(
        id: aiAnalysis!.id, summary: aiAnalysis!.summary, keywords: aiAnalysis!.keywords,
        emotionScores: aiAnalysis!.emotionScores, advice: aiAnalysis!.advice,
        actionItems: aiAnalysis!.actionItems, moodTrend: aiAnalysis!.moodTrend,
        analyzedAt: aiAnalysis!.analyzedAt
      ).toMap()) : null,
      'chatHistory': chatHistory.map((msg) {
        if (msg is ChatMessageModel) return msg.toMap();
        return ChatMessageModel(
          id: msg.id, content: msg.content, isFromAI: msg.isFromAI, 
          timestamp: msg.timestamp, emotion: msg.emotion, metadata: msg.metadata
        ).toMap();
      }).toList(),
      'weather': weather,
      'location': location,
      'tags': tags,
      'isPublic': isPublic,
      'diaryType': diaryType.toString().split('.').last,
      'metadata': metadata,
    };
  }

  factory DiaryModel.fromEntity(DiaryEntry entity) {
    return DiaryModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      content: entity.content,
      emotions: entity.emotions,
      emotionIntensities: entity.emotionIntensities,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      mediaFiles: entity.mediaFiles,
      aiAnalysis: entity.aiAnalysis,
      chatHistory: entity.chatHistory,
      weather: entity.weather,
      location: entity.location,
      tags: entity.tags,
      isPublic: entity.isPublic,
      diaryType: entity.diaryType,
      metadata: entity.metadata,
    );
  }
}

