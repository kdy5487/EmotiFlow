class AIAnalysis {
  final String id;
  final String summary;
  final List<String> keywords;
  final Map<String, double> emotionScores;
  final String advice;
  final List<String> actionItems;
  final String moodTrend;
  final DateTime analyzedAt;

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
}

