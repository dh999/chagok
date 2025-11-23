import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/haptic_util.dart';
import '../../../core/utils/sound_util.dart';
import '../../../data/models/mission_model.dart';
import '../../providers/mission_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/draggable_mission_block.dart';
import 'widgets/pixel_house.dart';
import 'widgets/rabbit_character.dart';

class MicroscopeView extends ConsumerStatefulWidget {
  const MicroscopeView({super.key});

  @override
  ConsumerState<MicroscopeView> createState() => _MicroscopeViewState();
}

class _MicroscopeViewState extends ConsumerState<MicroscopeView> {
  String? _rabbitMessage;
  bool _showCelebration = false;

  void _onMissionCompleted(MissionModel mission) async {
    // 햅틱 피드백
    await HapticUtil.heavy();
    await SoundUtil.playBlockDrop();

    // 미션 완료 처리
    final success =
        await ref.read(missionNotifierProvider.notifier).completeMission(mission);

    if (success) {
      setState(() {
        _showCelebration = true;
        _rabbitMessage = AppStrings.blockAdded;
      });

      // 메시지 숨기기
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
            _rabbitMessage = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingMissions = ref.watch(pendingMissionsProvider);
    final completedMissions = ref.watch(completedMissionsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final houseLevel = currentUser.valueOrNull?.houseLevel ?? 1;

    return Stack(
      children: [
        // 배경
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.surfaceVariant,
              ],
            ),
          ),
        ),

        // 메인 컨텐츠
        Column(
          children: [
            // 오늘의 미션 (드래그 가능한 블록)
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        AppStrings.todayMission,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${completedMissions.length}/${pendingMissions.length + completedMissions.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  if (pendingMissions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Row(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          const Text(
                            '오늘의 미션을 모두 완료했어요!',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: pendingMissions.map((mission) {
                        return DraggableMissionBlock(mission: mission);
                      }).toList(),
                    ),
                ],
              ),
            ),

            // 집과 토끼 영역
            Expanded(
              child: DragTarget<MissionModel>(
                onWillAcceptWithDetails: (details) {
                  HapticUtil.light();
                  return !details.data.isCompleted;
                },
                onAcceptWithDetails: (details) {
                  _onMissionCompleted(details.data);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHighlighted = candidateData.isNotEmpty;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // 드롭 가이드
                      if (isHighlighted)
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(AppSizes.xl),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.5),
                                width: 3,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusXl),
                            ),
                          ),
                        ),

                      // 집
                      PixelHouse(
                        level: houseLevel,
                        isHighlighted: isHighlighted,
                      ),

                      // 토끼
                      Positioned(
                        bottom: 80,
                        child: RabbitCharacter(
                          isJumping: _showCelebration,
                          message: _rabbitMessage,
                        ),
                      ),

                      // 축하 파티클
                      if (_showCelebration)
                        const Positioned.fill(
                          child: _CelebrationParticles(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),

        // 드래그 힌트
        if (pendingMissions.isNotEmpty)
          Positioned(
            bottom: AppSizes.xl,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: const Text(
                  AppStrings.dragToComplete,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CelebrationParticles extends StatefulWidget {
  const _CelebrationParticles();

  @override
  State<_CelebrationParticles> createState() => _CelebrationParticlesState();
}

class _CelebrationParticlesState extends State<_CelebrationParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(progress: _controller.value),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 3.14159 * 2;
      final distance = 50 + progress * 100;
      final opacity = (1 - progress).clamp(0.0, 1.0);

      paint.color = [
        AppColors.blockGold,
        AppColors.primary,
        AppColors.success,
      ][i % 3].withOpacity(opacity);

      final offset = Offset(
        center.dx + distance * math.cos(angle),
        center.dy + distance * math.sin(angle) - progress * 50,
      );

      canvas.drawCircle(offset, 6 * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
