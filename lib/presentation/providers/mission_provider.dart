import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mission_model.dart';
import '../../data/repositories/mission_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/reward_repository.dart';
import '../../domain/enums/mission_type.dart';
import '../../domain/enums/difficulty.dart';
import 'auth_provider.dart';

/// Mission Repository Provider
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MissionRepository();
});

/// Reward Repository Provider
final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository();
});

/// Today's Missions Stream Provider
final todayMissionsProvider = StreamProvider<List<MissionModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;

  if (uid == null) return Stream.value([]);

  final missionRepository = ref.watch(missionRepositoryProvider);
  return missionRepository.watchTodayMissions(uid);
});

/// Pending Missions Provider (미완료 미션만)
final pendingMissionsProvider = Provider<List<MissionModel>>((ref) {
  final todayMissions = ref.watch(todayMissionsProvider);
  return todayMissions.valueOrNull?.where((m) => !m.isCompleted).toList() ?? [];
});

/// Completed Missions Provider (완료된 미션만)
final completedMissionsProvider = Provider<List<MissionModel>>((ref) {
  final todayMissions = ref.watch(todayMissionsProvider);
  return todayMissions.valueOrNull?.where((m) => m.isCompleted).toList() ?? [];
});

/// Mission Notifier
class MissionNotifier extends StateNotifier<AsyncValue<void>> {
  final MissionRepository _missionRepository;
  final UserRepository _userRepository;
  final RewardRepository _rewardRepository;
  final String? _uid;

  MissionNotifier(
    this._missionRepository,
    this._userRepository,
    this._rewardRepository,
    this._uid,
  ) : super(const AsyncValue.data(null));

  /// 미션 완료 처리
  Future<bool> completeMission(MissionModel mission) async {
    if (_uid == null) return false;

    state = const AsyncValue.loading();
    try {
      // 미션 완료 처리
      await _missionRepository.completeMission(mission.id);

      // 블록 추가
      await _userRepository.addBlocks(_uid!, mission.blockValue);

      // EXP 추가 (기본 10)
      int expToAdd = 10;

      // 오늘 모든 미션 완료 체크 (보너스)
      final allCompleted = await _missionRepository.areAllMissionsCompleted(
        _uid!,
        DateTime.now(),
      );

      if (allCompleted) {
        // 올클리어 보너스
        expToAdd += 30;
        await _userRepository.addBlocks(_uid!, 1); // 보너스 블록
      }

      await _userRepository.addExp(_uid!, expToAdd);

      // Streak 업데이트
      await _updateStreak();

      // 보상 해금 체크
      await _checkRewardUnlocks();

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 미션 생성
  Future<void> createMission({
    required String content,
    required MissionType type,
    Difficulty difficulty = Difficulty.easy,
  }) async {
    if (_uid == null) return;

    state = const AsyncValue.loading();
    try {
      final mission = MissionModel.create(
        uid: _uid!,
        content: content,
        type: type,
        difficulty: difficulty,
        generatedBy: 'USER',
      );

      await _missionRepository.createMission(mission);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// AI 생성 미션 저장
  Future<void> saveMissionsFromAI(List<Map<String, dynamic>> missionsData) async {
    if (_uid == null) return;

    state = const AsyncValue.loading();
    try {
      final missions = missionsData.map((data) {
        return MissionModel.create(
          uid: _uid!,
          content: data['content'] as String,
          type: MissionType.fromString(data['type'] as String? ?? 'TASK'),
          difficulty: Difficulty.fromString(data['difficulty'] as String? ?? 'EASY'),
          generatedBy: 'AI',
          aiContext: data['context'] as String?,
        );
      }).toList();

      await _missionRepository.createMissions(missions);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Streak 업데이트
  Future<void> _updateStreak() async {
    if (_uid == null) return;

    try {
      final user = await _userRepository.getUser(_uid!);
      if (user == null) return;

      // 어제 미션 완료 여부 확인
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final hadCompletedYesterday = await _missionRepository.hasCompletedMissionOnDate(
        _uid!,
        yesterday,
      );

      int newTotalStreak = hadCompletedYesterday ? user.totalStreak + 1 : 1;
      int newMonthlyStreak = hadCompletedYesterday ? user.monthlyStreak + 1 : 1;

      // 월이 바뀌었으면 월간 스트릭 리셋
      final now = DateTime.now();
      if (user.lastLoginAt != null && user.lastLoginAt!.month != now.month) {
        newMonthlyStreak = 1;
      }

      await _userRepository.updateStreak(
        uid: _uid!,
        monthlyStreak: newMonthlyStreak,
        totalStreak: newTotalStreak,
      );
    } catch (e) {
      // Streak 업데이트 실패는 무시
    }
  }

  /// 보상 해금 체크
  Future<void> _checkRewardUnlocks() async {
    if (_uid == null) return;

    try {
      final user = await _userRepository.getUser(_uid!);
      if (user == null) return;

      final unlockable = _rewardRepository.checkUnlockableRewards(
        totalStreak: user.totalStreak,
        currentBlocks: user.currentBlocks,
        rabbitLevel: user.rabbitLevel,
        alreadyUnlocked: user.unlockedItems,
      );

      for (final reward in unlockable) {
        await _userRepository.unlockItem(_uid!, reward.id);
      }
    } catch (e) {
      // 보상 해금 실패는 무시
    }
  }

  /// 미션 스킵
  Future<void> skipMission(String missionId) async {
    state = const AsyncValue.loading();
    try {
      await _missionRepository.skipMission(missionId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Mission Notifier Provider
final missionNotifierProvider =
    StateNotifierProvider<MissionNotifier, AsyncValue<void>>((ref) {
  final missionRepository = ref.watch(missionRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final rewardRepository = ref.watch(rewardRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  return MissionNotifier(missionRepository, userRepository, rewardRepository, uid);
});

/// Monthly Missions Provider (캘린더용)
final monthlyMissionsProvider =
    FutureProvider.family<Map<DateTime, List<MissionModel>>, ({int year, int month})>(
        (ref, params) async {
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;

  if (uid == null) return {};

  final missionRepository = ref.watch(missionRepositoryProvider);
  return missionRepository.getMonthlyMissions(uid, params.year, params.month);
});
