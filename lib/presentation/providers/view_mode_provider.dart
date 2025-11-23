import 'package:flutter_riverpod/flutter_riverpod.dart';

/// View Mode Enum
enum ViewMode {
  microscope, // 현미경 모드 (메인)
  telescope,  // 망원경 모드 (대시보드)
}

/// View Mode Notifier
class ViewModeNotifier extends StateNotifier<ViewMode> {
  ViewModeNotifier() : super(ViewMode.microscope);

  /// 모드 전환
  void toggle() {
    state = state == ViewMode.microscope
        ? ViewMode.telescope
        : ViewMode.microscope;
  }

  /// 현미경 모드로 전환
  void toMicroscope() {
    state = ViewMode.microscope;
  }

  /// 망원경 모드로 전환
  void toTelescope() {
    state = ViewMode.telescope;
  }
}

/// View Mode Provider
final viewModeProvider = StateNotifierProvider<ViewModeNotifier, ViewMode>((ref) {
  return ViewModeNotifier();
});

/// Is Microscope Mode Provider
final isMicroscopeModeProvider = Provider<bool>((ref) {
  return ref.watch(viewModeProvider) == ViewMode.microscope;
});

/// Is Telescope Mode Provider
final isTelescopeModeProvider = Provider<bool>((ref) {
  return ref.watch(viewModeProvider) == ViewMode.telescope;
});
