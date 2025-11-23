import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/view_mode_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animations/zoom_transition.dart';
import 'microscope_view.dart';
import 'telescope_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏠', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              viewMode == ViewMode.microscope
                  ? AppStrings.homeTitle
                  : AppStrings.dashboardTitle,
            ),
          ],
        ),
        actions: [
          // 프로필 버튼
          IconButton(
            onPressed: () {
              // TODO: 프로필 화면으로 이동
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceVariant,
              child: currentUser.valueOrNull?.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        currentUser.valueOrNull!.profileImageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Text('👤', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ZoomTransition(
        showFirst: viewMode == ViewMode.microscope,
        first: const MicroscopeView(),
        second: const TelescopeView(),
      ),
      floatingActionButton: _ModeSwitchFAB(viewMode: viewMode),
    );
  }
}

class _ModeSwitchFAB extends ConsumerWidget {
  final ViewMode viewMode;

  const _ModeSwitchFAB({required this.viewMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        ref.read(viewModeProvider.notifier).toggle();
      },
      backgroundColor: AppColors.primary,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Icon(
          viewMode == ViewMode.microscope
              ? Icons.zoom_out_map_rounded  // 망원경 아이콘
              : Icons.zoom_in_map_rounded,   // 현미경 아이콘
          key: ValueKey(viewMode),
          color: Colors.white,
        ),
      ),
    );
  }
}
