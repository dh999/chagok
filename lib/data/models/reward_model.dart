import 'package:cloud_firestore/cloud_firestore.dart';

enum RewardCategory {
  decoration('DECORATION'),
  character('CHARACTER'),
  effect('EFFECT');

  final String value;
  const RewardCategory(this.value);

  static RewardCategory fromString(String value) {
    return RewardCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RewardCategory.decoration,
    );
  }
}

enum UnlockCondition {
  streak7('STREAK_7', 7),
  streak14('STREAK_14', 14),
  streak30('STREAK_30', 30),
  streak60('STREAK_60', 60),
  streak100('STREAK_100', 100),
  level5('LEVEL_5', 5),
  blocks100('BLOCKS_100', 100),
  blocks500('BLOCKS_500', 500);

  final String value;
  final int requirement;
  const UnlockCondition(this.value, this.requirement);

  static UnlockCondition fromString(String value) {
    return UnlockCondition.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UnlockCondition.streak7,
    );
  }
}

class RewardModel {
  final String id;
  final String name;
  final String description;
  final UnlockCondition unlockCondition;
  final String assetPath;
  final RewardCategory category;

  RewardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.unlockCondition,
    required this.assetPath,
    required this.category,
  });

  factory RewardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RewardModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      unlockCondition: UnlockCondition.fromString(data['unlock_condition'] ?? 'STREAK_7'),
      assetPath: data['asset_path'] ?? '',
      category: RewardCategory.fromString(data['category'] ?? 'DECORATION'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'unlock_condition': unlockCondition.value,
      'asset_path': assetPath,
      'category': category.value,
    };
  }

  /// 기본 보상 목록
  static List<RewardModel> get defaultRewards => [
        RewardModel(
          id: 'item_flower_pot',
          name: '화분',
          description: '7일 연속 미션 성공 보상',
          unlockCondition: UnlockCondition.streak7,
          assetPath: 'assets/images/items/flower_pot.png',
          category: RewardCategory.decoration,
        ),
        RewardModel(
          id: 'item_fence',
          name: '울타리',
          description: '14일 연속 미션 성공 보상',
          unlockCondition: UnlockCondition.streak14,
          assetPath: 'assets/images/items/fence.png',
          category: RewardCategory.decoration,
        ),
        RewardModel(
          id: 'item_bicycle',
          name: '자전거',
          description: '30일 연속 미션 성공 보상',
          unlockCondition: UnlockCondition.streak30,
          assetPath: 'assets/images/items/bicycle.png',
          category: RewardCategory.decoration,
        ),
        RewardModel(
          id: 'item_garden',
          name: '정원',
          description: '60일 연속 미션 성공 보상',
          unlockCondition: UnlockCondition.streak60,
          assetPath: 'assets/images/items/garden.png',
          category: RewardCategory.decoration,
        ),
        RewardModel(
          id: 'item_second_floor',
          name: '2층 증축',
          description: '100일 연속 미션 성공 보상',
          unlockCondition: UnlockCondition.streak100,
          assetPath: 'assets/images/items/second_floor.png',
          category: RewardCategory.decoration,
        ),
      ];
}
