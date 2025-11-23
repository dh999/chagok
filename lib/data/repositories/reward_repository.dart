import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';
import '../services/firebase_service.dart';
import '../../core/exceptions/app_exceptions.dart';

class RewardRepository {
  final FirebaseService _firebaseService = FirebaseService();

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firebaseService.rewardsCollection;

  /// 모든 보상 조회
  Future<List<RewardModel>> getAllRewards() async {
    try {
      final snapshot = await _collection.get();

      // Firestore에 데이터가 없으면 기본 보상 반환
      if (snapshot.docs.isEmpty) {
        return RewardModel.defaultRewards;
      }

      return snapshot.docs.map((doc) => RewardModel.fromFirestore(doc)).toList();
    } catch (e) {
      // 오류 시 기본 보상 반환
      return RewardModel.defaultRewards;
    }
  }

  /// 특정 보상 조회
  Future<RewardModel?> getReward(String rewardId) async {
    try {
      final doc = await _collection.doc(rewardId).get();
      if (!doc.exists) {
        // 기본 보상에서 찾기
        return RewardModel.defaultRewards
            .where((r) => r.id == rewardId)
            .firstOrNull;
      }
      return RewardModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreException(
        message: '보상 정보를 불러오는데 실패했습니다.',
        originalError: e,
      );
    }
  }

  /// 해금 가능한 보상 체크
  List<RewardModel> checkUnlockableRewards({
    required int totalStreak,
    required int currentBlocks,
    required int rabbitLevel,
    required List<String> alreadyUnlocked,
  }) {
    final allRewards = RewardModel.defaultRewards;
    final unlockable = <RewardModel>[];

    for (final reward in allRewards) {
      // 이미 해금된 경우 스킵
      if (alreadyUnlocked.contains(reward.id)) continue;

      bool canUnlock = false;

      switch (reward.unlockCondition) {
        case UnlockCondition.streak7:
          canUnlock = totalStreak >= 7;
          break;
        case UnlockCondition.streak14:
          canUnlock = totalStreak >= 14;
          break;
        case UnlockCondition.streak30:
          canUnlock = totalStreak >= 30;
          break;
        case UnlockCondition.streak60:
          canUnlock = totalStreak >= 60;
          break;
        case UnlockCondition.streak100:
          canUnlock = totalStreak >= 100;
          break;
        case UnlockCondition.level5:
          canUnlock = rabbitLevel >= 5;
          break;
        case UnlockCondition.blocks100:
          canUnlock = currentBlocks >= 100;
          break;
        case UnlockCondition.blocks500:
          canUnlock = currentBlocks >= 500;
          break;
      }

      if (canUnlock) {
        unlockable.add(reward);
      }
    }

    return unlockable;
  }

  /// 기본 보상 데이터 초기화 (관리자용)
  Future<void> initializeDefaultRewards() async {
    try {
      final batch = _firebaseService.firestore.batch();

      for (final reward in RewardModel.defaultRewards) {
        final docRef = _collection.doc(reward.id);
        batch.set(docRef, reward.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw FirestoreException(
        message: '보상 초기화에 실패했습니다.',
        originalError: e,
      );
    }
  }
}
