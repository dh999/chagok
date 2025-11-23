import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/reward_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mission_provider.dart';
import 'widgets/pixel_calendar.dart';
import 'widgets/stats_card.dart';

class TelescopeView extends ConsumerWidget {
  const TelescopeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final user = currentUser.valueOrNull;

    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 공정률
          StatsCard(
            title: AppStrings.progressRate,
            value: '${user.progressRate.toStringAsFixed(2)}%',
            icon: '🏗️',
            progress: user.progressRate / 100,
            color: AppColors.primary,
          ),

          const SizedBox(height: AppSizes.md),

          // 블록 / Streak 정보
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: '누적 블록',
                  value: '${user.currentBlocks}',
                  icon: '🧱',
                  subtitle: '/ ${user.totalBlocksNeeded}',
                  color: AppColors.blockGold,
                  compact: true,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: StatsCard(
                  title: '연속 성공',
                  value: '${user.totalStreak}일',
                  icon: '🔥',
                  subtitle: '최고: ${user.longestStreak}일',
                  color: AppColors.error,
                  compact: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.md),

          // 이번 달 성실도
          StatsCard(
            title: AppStrings.monthlyRate,
            value: '${_calculateMonthlyRate(user.monthlyStreak)}%',
            icon: '📊',
            progress: _calculateMonthlyRate(user.monthlyStreak) / 100,
            color: AppColors.success,
          ),

          const SizedBox(height: AppSizes.lg),

          // 픽셀 캘린더
          const Text(
            '이번 달 기록',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          const PixelCalendar(),

          const SizedBox(height: AppSizes.lg),

          // 보상 아이템
          const Text(
            AppStrings.rewards,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          _RewardGrid(unlockedItems: user.unlockedItems),

          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  double _calculateMonthlyRate(int monthlyStreak) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    return (monthlyStreak / daysPassed * 100).clamp(0, 100);
  }
}

class _RewardGrid extends StatelessWidget {
  final List<String> unlockedItems;

  const _RewardGrid({required this.unlockedItems});

  @override
  Widget build(BuildContext context) {
    final rewards = RewardModel.defaultRewards;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSizes.sm,
        crossAxisSpacing: AppSizes.sm,
        childAspectRatio: 1,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final isUnlocked = unlockedItems.contains(reward.id);

        return _RewardItem(
          reward: reward,
          isUnlocked: isUnlocked,
        );
      },
    );
  }
}

class _RewardItem extends StatelessWidget {
  final RewardModel reward;
  final bool isUnlocked;

  const _RewardItem({
    required this.reward,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(reward.name),
            content: Text(
              isUnlocked
                  ? '획득한 아이템이에요! 🎉'
                  : reward.description,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.blockGold.withOpacity(0.2)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isUnlocked
                ? AppColors.blockGold
                : AppColors.textHint.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: isUnlocked
              ? Text(
                  _getRewardEmoji(reward.id),
                  style: const TextStyle(fontSize: 28),
                )
              : const Icon(
                  Icons.lock_outline,
                  color: AppColors.textHint,
                  size: 28,
                ),
        ),
      ),
    );
  }

  String _getRewardEmoji(String id) {
    switch (id) {
      case 'item_flower_pot':
        return '🪴';
      case 'item_fence':
        return '🏚️';
      case 'item_bicycle':
        return '🚲';
      case 'item_garden':
        return '🌳';
      case 'item_second_floor':
        return '🏗️';
      default:
        return '🎁';
    }
  }
}
