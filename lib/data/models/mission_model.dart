import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/mission_type.dart';
import '../../domain/enums/mission_status.dart';
import '../../domain/enums/difficulty.dart';

class MissionModel {
  final String id;
  final String uid;
  final DateTime date;
  final String content;
  final MissionType type;
  final Difficulty difficulty;
  final int blockValue;
  final MissionStatus status;
  final bool isCompleted;
  final DateTime? completedAt;
  final String generatedBy;
  final String? aiContext;
  final DateTime createdAt;
  final DateTime updatedAt;

  MissionModel({
    required this.id,
    required this.uid,
    required this.date,
    required this.content,
    required this.type,
    required this.difficulty,
    required this.blockValue,
    required this.status,
    required this.isCompleted,
    this.completedAt,
    required this.generatedBy,
    this.aiContext,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MissionModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      content: data['content'] ?? '',
      type: MissionType.fromString(data['type'] ?? 'TASK'),
      difficulty: Difficulty.fromString(data['difficulty'] ?? 'EASY'),
      blockValue: data['block_value'] ?? 1,
      status: MissionStatus.fromString(data['status'] ?? 'PENDING'),
      isCompleted: data['is_completed'] ?? false,
      completedAt: data['completed_at'] != null
          ? (data['completed_at'] as Timestamp).toDate()
          : null,
      generatedBy: data['generated_by'] ?? 'SYSTEM',
      aiContext: data['ai_context'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'content': content,
      'type': type.value,
      'difficulty': difficulty.value,
      'block_value': blockValue,
      'status': status.value,
      'is_completed': isCompleted,
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'generated_by': generatedBy,
      'ai_context': aiContext,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  MissionModel copyWith({
    String? id,
    String? uid,
    DateTime? date,
    String? content,
    MissionType? type,
    Difficulty? difficulty,
    int? blockValue,
    MissionStatus? status,
    bool? isCompleted,
    DateTime? completedAt,
    String? generatedBy,
    String? aiContext,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MissionModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      date: date ?? this.date,
      content: content ?? this.content,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      blockValue: blockValue ?? this.blockValue,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      generatedBy: generatedBy ?? this.generatedBy,
      aiContext: aiContext ?? this.aiContext,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 새 미션 생성용 factory
  factory MissionModel.create({
    required String uid,
    required String content,
    required MissionType type,
    Difficulty difficulty = Difficulty.easy,
    String generatedBy = 'AI',
    String? aiContext,
  }) {
    final now = DateTime.now();
    return MissionModel(
      id: '',
      uid: uid,
      date: DateTime(now.year, now.month, now.day),
      content: content,
      type: type,
      difficulty: difficulty,
      blockValue: difficulty.blockValue,
      status: MissionStatus.pending,
      isCompleted: false,
      generatedBy: generatedBy,
      aiContext: aiContext,
      createdAt: now,
      updatedAt: now,
    );
  }
}
