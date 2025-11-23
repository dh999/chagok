import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/enums/goal_category.dart';
import 'auth_provider.dart';

/// User Notifier for updating user data
class UserNotifier extends StateNotifier<AsyncValue<void>> {
  final UserRepository _userRepository;
  final String? _uid;

  UserNotifier(this._userRepository, this._uid)
      : super(const AsyncValue.data(null));

  /// 온보딩 완료
  Future<void> completeOnboarding({
    required String finalGoal,
    required GoalCategory goalCategory,
    required DateTime targetDate,
    required int totalBlocksNeeded,
  }) async {
    if (_uid == null) return;

    state = const AsyncValue.loading();
    try {
      await _userRepository.completeOnboarding(
        uid: _uid!,
        finalGoal: finalGoal,
        goalCategory: goalCategory,
        targetDate: targetDate,
        totalBlocksNeeded: totalBlocksNeeded,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 블록 추가
  Future<void> addBlocks(int blocks) async {
    if (_uid == null) return;

    try {
      await _userRepository.addBlocks(_uid!, blocks);
    } catch (e) {
      // 블록 추가 실패는 무시
    }
  }

  /// EXP 추가
  Future<void> addExp(int exp) async {
    if (_uid == null) return;

    try {
      await _userRepository.addExp(_uid!, exp);
    } catch (e) {
      // EXP 추가 실패는 무시
    }
  }

  /// Streak 업데이트
  Future<void> updateStreak({
    required int monthlyStreak,
    required int totalStreak,
  }) async {
    if (_uid == null) return;

    try {
      await _userRepository.updateStreak(
        uid: _uid!,
        monthlyStreak: monthlyStreak,
        totalStreak: totalStreak,
      );
    } catch (e) {
      // Streak 업데이트 실패는 무시
    }
  }

  /// 아이템 해금
  Future<void> unlockItem(String itemId) async {
    if (_uid == null) return;

    try {
      await _userRepository.unlockItem(_uid!, itemId);
    } catch (e) {
      // 아이템 해금 실패는 무시
    }
  }

  /// 닉네임 업데이트
  Future<void> updateNickname(String nickname) async {
    if (_uid == null) return;

    state = const AsyncValue.loading();
    try {
      await _userRepository.updateUser(_uid!, {'nickname': nickname});
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// User Notifier Provider
final userNotifierProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<void>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  return UserNotifier(userRepository, uid);
});

/// Is Onboarding Completed Provider
final isOnboardingCompletedProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.valueOrNull?.onboardingCompleted ?? false;
});

/// Progress Rate Provider
final progressRateProvider = Provider<double>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.valueOrNull?.progressRate ?? 0;
});

/// House Level Provider
final houseLevelProvider = Provider<int>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.valueOrNull?.houseLevel ?? 1;
});
