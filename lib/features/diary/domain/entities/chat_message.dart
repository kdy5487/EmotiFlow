class ChatMessage {
  final String id;
  final String content;
  final bool isFromAI;
  final DateTime timestamp;
  final String? emotion;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromAI,
    required this.timestamp,
    this.emotion,
    this.metadata,
  });
}

