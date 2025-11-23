import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/goal_category.dart';

class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final String? profileImageUrl;

  // 목표 관련
  final String? finalGoal;
  final GoalCategory? goalCategory;
  final DateTime? targetDate;
  final int totalBlocksNeeded;
  final int currentBlocks;

  // 게이미피케이션
  final int rabbitLevel;
  final int rabbitExp;
  final int monthlyStreak;
  final int totalStreak;
  final int longestStreak;
  final List<String> unlockedItems;

  // 메타
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool onboardingCompleted;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    this.finalGoal,
    this.goalCategory,
    this.targetDate,
    this.totalBlocksNeeded = 0,
    this.currentBlocks = 0,
    this.rabbitLevel = 1,
    this.rabbitExp = 0,
    this.monthlyStreak = 0,
    this.totalStreak = 0,
    this.longestStreak = 0,
    this.unlockedItems = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.onboardingCompleted = false,
    this.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      profileImageUrl: data['profile_image_url'],
      finalGoal: data['final_goal'],
      goalCategory: data['goal_category'] != null
          ? GoalCategory.fromString(data['goal_category'])
          : null,
      targetDate: data['target_date'] != null
          ? (data['target_date'] as Timestamp).toDate()
          : null,
      totalBlocksNeeded: data['total_blocks_needed'] ?? 0,
      currentBlocks: data['current_blocks'] ?? 0,
      rabbitLevel: data['rabbit_level'] ?? 1,
      rabbitExp: data['rabbit_exp'] ?? 0,
      monthlyStreak: data['monthly_streak'] ?? 0,
      totalStreak: data['total_streak'] ?? 0,
      longestStreak: data['longest_streak'] ?? 0,
      unlockedItems: List<String>.from(data['unlocked_items'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      lastLoginAt: data['last_login_at'] != null
          ? (data['last_login_at'] as Timestamp).toDate()
          : null,
      onboardingCompleted: data['onboarding_completed'] ?? false,
      fcmToken: data['fcm_token'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nickname': nickname,
      'profile_image_url': profileImageUrl,
      'final_goal': finalGoal,
      'goal_category': goalCategory?.value,
      'target_date': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'total_blocks_needed': totalBlocksNeeded,
      'current_blocks': currentBlocks,
      'rabbit_level': rabbitLevel,
      'rabbit_exp': rabbitExp,
      'monthly_streak': monthlyStreak,
      'total_streak': totalStreak,
      'longest_streak': longestStreak,
      'unlocked_items': unlockedItems,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'last_login_at': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'onboarding_completed': onboardingCompleted,
      'fcm_token': fcmToken,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nickname,
    String? profileImageUrl,
    String? finalGoal,
    GoalCategory? goalCategory,
    DateTime? targetDate,
    int? totalBlocksNeeded,
    int? currentBlocks,
    int? rabbitLevel,
    int? rabbitExp,
    int? monthlyStreak,
    int? totalStreak,
    int? longestStreak,
    List<String>? unlockedItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? onboardingCompleted,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      finalGoal: finalGoal ?? this.finalGoal,
      goalCategory: goalCategory ?? this.goalCategory,
      targetDate: targetDate ?? this.targetDate,
      totalBlocksNeeded: totalBlocksNeeded ?? this.totalBlocksNeeded,
      currentBlocks: currentBlocks ?? this.currentBlocks,
      rabbitLevel: rabbitLevel ?? this.rabbitLevel,
      rabbitExp: rabbitExp ?? this.rabbitExp,
      monthlyStreak: monthlyStreak ?? this.monthlyStreak,
      totalStreak: totalStreak ?? this.totalStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      unlockedItems: unlockedItems ?? this.unlockedItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  /// 공정률 계산 (퍼센트)
  double get progressRate {
    if (totalBlocksNeeded == 0) return 0;
    return (currentBlocks / totalBlocksNeeded) * 100;
  }

  /// 집 레벨 계산
  int get houseLevel {
    if (currentBlocks >= 7300) return 7;
    if (currentBlocks >= 5000) return 6;
    if (currentBlocks >= 3000) return 5;
    if (currentBlocks >= 1500) return 4;
    if (currentBlocks >= 500) return 3;
    if (currentBlocks >= 100) return 2;
    return 1;
  }
}
