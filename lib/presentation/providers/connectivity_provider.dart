import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/connectivity_service.dart';

/// Connectivity Service Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.startMonitoring();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Current Connectivity State Provider
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Sync State for offline actions
class OfflineSyncNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  OfflineSyncNotifier() : super([]);

  /// 오프라인 액션 추가 (나중에 동기화)
  void addPendingAction(Map<String, dynamic> action) {
    state = [...state, action];
  }

  /// 동기화 완료된 액션 제거
  void removePendingAction(int index) {
    final newState = [...state];
    if (index < newState.length) {
      newState.removeAt(index);
    }
    state = newState;
  }

  /// 모든 대기 중인 액션 조회
  List<Map<String, dynamic>> get pendingActions => state;

  /// 대기 중인 액션 개수
  int get pendingCount => state.length;

  /// 모든 대기 액션 삭제
  void clearAll() {
    state = [];
  }
}

final offlineSyncProvider =
    StateNotifierProvider<OfflineSyncNotifier, List<Map<String, dynamic>>>((ref) {
  return OfflineSyncNotifier();
});
