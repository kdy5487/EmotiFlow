import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.id,
    required super.content,
    required super.isFromAI,
    required super.timestamp,
    super.emotion,
    super.metadata,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      isFromAI: map['isFromAI'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      emotion: map['emotion'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
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

