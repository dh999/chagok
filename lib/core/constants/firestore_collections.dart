/// Firestore 컬렉션명 상수
class FirestoreCollections {
  FirestoreCollections._();

  /// 사용자 컬렉션
  static const String users = 'users';

  /// 미션 컬렉션
  static const String missions = 'missions';

  /// 채팅 세션 컬렉션
  static const String chatSessions = 'chat_sessions';

  /// 보상 컬렉션
  static const String rewards = 'rewards';

  /// 알림 컬렉션
  static const String notifications = 'notifications';

  /// 앱 설정 컬렉션
  static const String appConfig = 'app_config';
}

/// Firestore 필드명 상수
class FirestoreFields {
  FirestoreFields._();

  // 공통 필드
  static const String uid = 'uid';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // 사용자 필드
  static const String email = 'email';
  static const String nickname = 'nickname';
  static const String profileImageUrl = 'profile_image_url';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String finalGoal = 'final_goal';
  static const String goalCategory = 'goal_category';
  static const String targetDate = 'target_date';
  static const String currentBlocks = 'current_blocks';
  static const String totalBlocksNeeded = 'total_blocks_needed';
  static const String rabbitLevel = 'rabbit_level';
  static const String rabbitExp = 'rabbit_exp';
  static const String monthlyStreak = 'monthly_streak';
  static const String totalStreak = 'total_streak';
  static const String longestStreak = 'longest_streak';
  static const String unlockedItems = 'unlocked_items';
  static const String fcmToken = 'fcm_token';
  static const String lastLoginAt = 'last_login_at';

  // 미션 필드
  static const String content = 'content';
  static const String missionType = 'mission_type';
  static const String difficulty = 'difficulty';
  static const String blockValue = 'block_value';
  static const String isCompleted = 'is_completed';
  static const String isSkipped = 'is_skipped';
  static const String completedAt = 'completed_at';
  static const String scheduledDate = 'scheduled_date';
  static const String generatedBy = 'generated_by';
  static const String aiContext = 'ai_context';

  // 채팅 세션 필드
  static const String sessionType = 'session_type';
  static const String messages = 'messages';
  static const String closedAt = 'closed_at';
  static const String resultJson = 'result_json';

  // 보상 필드
  static const String title = 'title';
  static const String description = 'description';
  static const String iconEmoji = 'icon_emoji';
  static const String category = 'category';
  static const String unlockCondition = 'unlock_condition';
  static const String conditionValue = 'condition_value';
}
