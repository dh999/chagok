import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatRole {
  user,
  assistant;

  String get value => name;

  static ChatRole fromString(String value) {
    return ChatRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChatRole.user,
    );
  }
}

class ChatMessageModel {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessageModel({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      role: map['role'] ?? 'user',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessageModel.user(String content) {
    return ChatMessageModel(
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessageModel.assistant(String content) {
    return ChatMessageModel(
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
