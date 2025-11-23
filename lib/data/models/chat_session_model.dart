import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_message_model.dart';

enum SessionType {
  onboarding('ONBOARDING'),
  dailyCheck('DAILY_CHECK'),
  counseling('COUNSELING');

  final String value;
  const SessionType(this.value);

  static SessionType fromString(String value) {
    return SessionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SessionType.counseling,
    );
  }
}

class ChatSessionModel {
  final String id;
  final String uid;
  final SessionType sessionType;
  final List<ChatMessageModel> messages;
  final Map<String, dynamic>? resultJson;
  final DateTime createdAt;
  final DateTime? closedAt;

  ChatSessionModel({
    required this.id,
    required this.uid,
    required this.sessionType,
    required this.messages,
    this.resultJson,
    required this.createdAt,
    this.closedAt,
  });

  factory ChatSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSessionModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      sessionType: SessionType.fromString(data['session_type'] ?? 'COUNSELING'),
      messages: (data['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessageModel.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      resultJson: data['result_json'] as Map<String, dynamic>?,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      closedAt: data['closed_at'] != null
          ? (data['closed_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'session_type': sessionType.value,
      'messages': messages.map((m) => m.toMap()).toList(),
      'result_json': resultJson,
      'created_at': Timestamp.fromDate(createdAt),
      'closed_at': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
    };
  }

  ChatSessionModel copyWith({
    String? id,
    String? uid,
    SessionType? sessionType,
    List<ChatMessageModel>? messages,
    Map<String, dynamic>? resultJson,
    DateTime? createdAt,
    DateTime? closedAt,
  }) {
    return ChatSessionModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      sessionType: sessionType ?? this.sessionType,
      messages: messages ?? this.messages,
      resultJson: resultJson ?? this.resultJson,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  /// 새 세션 생성용 factory
  factory ChatSessionModel.create({
    required String uid,
    SessionType sessionType = SessionType.onboarding,
  }) {
    return ChatSessionModel(
      id: '',
      uid: uid,
      sessionType: sessionType,
      messages: [],
      createdAt: DateTime.now(),
    );
  }

  bool get isClosed => closedAt != null;
  bool get hasResult => resultJson != null;
}
