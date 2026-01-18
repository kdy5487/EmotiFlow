import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ai_analysis.dart';

class AIAnalysisModel extends AIAnalysis {
  AIAnalysisModel({
    required super.id,
    required super.summary,
    required super.keywords,
    required super.emotionScores,
    required super.advice,
    required super.actionItems,
    required super.moodTrend,
    required super.analyzedAt,
  });

  factory AIAnalysisModel.fromMap(Map<String, dynamic> map) {
    return AIAnalysisModel(
      id: map['id'] ?? '',
      summary: map['summary'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      emotionScores: Map<String, double>.from(map['emotionScores'] ?? {}),
      advice: map['advice'] ?? '',
      actionItems: List<String>.from(map['actionItems'] ?? []),
      moodTrend: map['moodTrend'] ?? '',
      analyzedAt: (map['analyzedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
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
