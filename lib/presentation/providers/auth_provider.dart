import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Auth State Provider (Firebase User)
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Current User Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final userRepository = ref.watch(userRepositoryProvider);
      return userRepository.watchUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Auth Notifier
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthNotifier(this._authRepository, this._userRepository)
      : super(const AsyncValue.data(null));

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authRepository.signInWithGoogle();
      await _createUserIfNeeded(credential);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Apple 로그인
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authRepository.signInWithApple();
      await _createUserIfNeeded(credential);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 신규 사용자 생성 (필요시)
  Future<void> _createUserIfNeeded(UserCredential credential) async {
    final user = credential.user;
    if (user == null) return;

    final existingUser = await _userRepository.getUser(user.uid);
    if (existingUser == null) {
      // 신규 사용자 생성
      await _userRepository.createUser(
        uid: user.uid,
        email: user.email ?? '',
        nickname: user.displayName ?? '건축가',
        profileImageUrl: user.photoURL,
      );
    } else {
      // 기존 사용자 로그인 시간 업데이트
      await _userRepository.updateLastLogin(user.uid);
    }
  }
}

/// Auth Notifier Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthNotifier(authRepository, userRepository);
});
