import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../domain/enums/goal_category.dart';

class UserRepository {
  final FirebaseService _firebaseService = FirebaseService();

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firebaseService.usersCollection;

  /// 사용자 조회
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _collection.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreException(
        message: '사용자 정보를 불러오는데 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 사용자 스트림
  Stream<UserModel?> watchUser(String uid) {
    return _collection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// 새 사용자 생성
  Future<UserModel> createUser({
    required String uid,
    required String email,
    required String nickname,
    String? profileImageUrl,
  }) async {
    try {
      final now = DateTime.now();
      final user = UserModel(
        uid: uid,
        email: email,
        nickname: nickname,
        profileImageUrl: profileImageUrl,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      await _collection.doc(uid).set(user.toFirestore());
      return user;
    } catch (e) {
      throw FirestoreException(
        message: '사용자 생성에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 사용자 업데이트
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = Timestamp.now();
      await _collection.doc(uid).update(data);
    } catch (e) {
      throw FirestoreException(
        message: '사용자 정보 업데이트에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 온보딩 완료 처리
  Future<void> completeOnboarding({
    required String uid,
    required String finalGoal,
    required GoalCategory goalCategory,
    required DateTime targetDate,
    required int totalBlocksNeeded,
  }) async {
    try {
      await _collection.doc(uid).update({
        'final_goal': finalGoal,
        'goal_category': goalCategory.value,
        'target_date': Timestamp.fromDate(targetDate),
        'total_blocks_needed': totalBlocksNeeded,
        'onboarding_completed': true,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw FirestoreException(
        message: '온보딩 완료 처리에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 블록 추가
  Future<void> addBlocks(String uid, int blocks) async {
    try {
      await _collection.doc(uid).update({
        'current_blocks': FieldValue.increment(blocks),
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw FirestoreException(
        message: '블록 추가에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// EXP 추가 및 레벨업 체크
  Future<void> addExp(String uid, int exp) async {
    try {
      final user = await getUser(uid);
      if (user == null) return;

      int newExp = user.rabbitExp + exp;
      int newLevel = user.rabbitLevel;

      // 레벨업 체크
      final levelThresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
      while (newLevel < 10 && newExp >= levelThresholds[newLevel]) {
        newExp -= levelThresholds[newLevel];
        newLevel++;
      }

      await _collection.doc(uid).update({
        'rabbit_exp': newExp,
        'rabbit_level': newLevel,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw FirestoreException(
        message: 'EXP 추가에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// Streak 업데이트
  Future<void> updateStreak({
    required String uid,
    required int monthlyStreak,
    required int totalStreak,
  }) async {
    try {
      final user = await getUser(uid);
      final longestStreak = user != null
          ? (totalStreak > user.longestStreak ? totalStreak : user.longestStreak)
          : totalStreak;

      await _collection.doc(uid).update({
        'monthly_streak': monthlyStreak,
        'total_streak': totalStreak,
        'longest_streak': longestStreak,
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw FirestoreException(
        message: 'Streak 업데이트에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 아이템 해금
  Future<void> unlockItem(String uid, String itemId) async {
    try {
      await _collection.doc(uid).update({
        'unlocked_items': FieldValue.arrayUnion([itemId]),
        'updated_at': Timestamp.now(),
      });
    } catch (e) {
      throw FirestoreException(
        message: '아이템 해금에 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 마지막 로그인 시간 업데이트
  Future<void> updateLastLogin(String uid) async {
    try {
      await _collection.doc(uid).update({
        'last_login_at': Timestamp.now(),
      });
    } catch (e) {
      // 로그인 시간 업데이트 실패는 무시
    }
  }

  /// FCM 토큰 업데이트
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _collection.doc(uid).update({
        'fcm_token': token,
      });
    } catch (e) {
      // FCM 토큰 업데이트 실패는 무시
    }
  }

  /// 사용자 삭제
  Future<void> deleteUser(String uid) async {
    try {
      await _collection.doc(uid).delete();
    } catch (e) {
      throw FirestoreException(
        message: '사용자 삭제에 실패했습니다.',
        originalError: e,
      );
    }
  }
}
