import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../providers/view_mode_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/animations/zoom_transition.dart';
import '../../widgets/dialogs/level_up_dialog.dart';
import 'microscope_view.dart';
import 'telescope_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _initialLevelSet = false;

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(viewModeProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentLevel = ref.watch(rabbitLevelProvider);

    // 초기 레벨 설정 (한 번만 실행)
    if (!_initialLevelSet) {
      _initialLevelSet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(levelChangeNotifierProvider.notifier).checkLevelChange(currentLevel);
      });
    }

    // 레벨 변경 감지 및 알림 표시
    ref.listen<int>(rabbitLevelProvider, (previous, next) {
      if (previous != null && next > previous) {
        LevelUpDialog.show(context, next);
      }
    });

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
          // 토끼 상담 버튼
          IconButton(
            onPressed: () => context.push(AppRoutes.onboarding),
            tooltip: '토끼와 상담하기',
            icon: const Text('🐰', style: TextStyle(fontSize: 24)),
          ),
          // 프로필 버튼
          IconButton(
            onPressed: () => context.push(AppRoutes.profile),
            tooltip: '프로필',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceVariant,
              child: currentUser.valueOrNull?.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        currentUser.valueOrNull!.profileImageUrl!,
                        fit: BoxFit.cover,
                        width: 32,
                        height: 32,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 32,
                            height: 32,
                            child: Center(
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('👤', style: TextStyle(fontSize: 16));
                        },
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
