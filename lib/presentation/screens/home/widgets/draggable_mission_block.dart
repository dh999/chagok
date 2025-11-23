import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/haptic_util.dart';
import '../../../../data/models/mission_model.dart';
import '../../../../domain/enums/mission_type.dart';

class DraggableMissionBlock extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Draggable<MissionModel>(
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
