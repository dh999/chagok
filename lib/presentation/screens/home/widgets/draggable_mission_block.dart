import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/haptic_util.dart';
import '../../../../data/models/mission_model.dart';
import '../../../../domain/enums/mission_type.dart';
import '../../../providers/mission_provider.dart';

class DraggableMissionBlock extends ConsumerWidget {
  final MissionModel mission;

  const DraggableMissionBlock({
    super.key,
    required this.mission,
  });

  Color get _blockColor {
    switch (mission.type) {
      case MissionType.study:
        return AppColors.blockStudy;
      case MissionType.saving:
        return AppColors.blockSaving;
      case MissionType.health:
        return AppColors.blockHealth;
      case MissionType.task:
        return AppColors.blockTask;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () => _showMissionOptions(context, ref),
      child: Draggable<MissionModel>(
        data: mission,
        onDragStarted: () => HapticUtil.light(),
        feedback: Material(
          color: Colors.transparent,
          child: _buildBlock(isDragging: true),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildBlock(),
        ),
        child: _buildBlock(),
      ),
    );
  }

  void _showMissionOptions(BuildContext context, WidgetRef ref) {
    HapticUtil.medium();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            // 미션 내용
            Text(
              mission.content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            // 스킵 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('미션 스킵'),
                      content: const Text(
                        '이 미션을 스킵하시겠어요?\n스킵한 미션은 블록을 받을 수 없어요.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('스킵'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ref
                        .read(missionNotifierProvider.notifier)
                        .skipMission(mission.id);
                  }
                },
                icon: const Icon(Icons.skip_next),
                label: const Text('오늘은 스킵하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            // 취소 버튼
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock({bool isDragging = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isDragging ? AppSizes.blockSizeLg : null,
      constraints: BoxConstraints(
        maxWidth: isDragging ? AppSizes.blockSizeLg : 200,
      ),
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: _blockColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: _blockColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: isDragging
          ? Center(
              child: Text(
                mission.type.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타입 아이콘
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      mission.type.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                // 미션 내용
                Flexible(
                  child: Text(
                    mission.content,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }
}
