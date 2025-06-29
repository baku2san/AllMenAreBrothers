/// 州の施設建設サービス
library;

import '../models/province_facility.dart';

/// 施設建設管理サービス
class FacilityService {
  /// 施設テンプレートを取得
  static Facility? getFacilityTemplate(FacilityType type) {
    switch (type) {
      // 軍事施設
      case FacilityType.barracks:
        return const Facility(
          type: FacilityType.barracks,
          name: '兵舎',
          emoji: '🏭',
          description: '兵士の訓練と駐屯を行う施設。軍事力を向上させる。',
          level: 1,
          maxLevel: 5,
          buildCost: {
            ResourceType.wood: 50,
            ResourceType.iron: 30,
            ResourceType.gold: 100,
          },
          upkeepCost: {
            ResourceType.food: 5,
            ResourceType.gold: 10,
          },
          buildTime: 3,
          effects: {
            ResourceType.military: 20,
          },
          unlockRequirements: {
            ResourceType.population: 500,
          },
          specialEffects: {
            'recruitment_bonus': 1.2,
            'training_speed': 1.15,
          },
        );

      case FacilityType.armory:
        return const Facility(
          type: FacilityType.armory,
          name: '武器庫',
          emoji: '⚔️',
          description: '武器や防具を製造・保管する施設。',
          level: 1,
          maxLevel: 4,
          buildCost: {
            ResourceType.wood: 40,
            ResourceType.iron: 60,
            ResourceType.gold: 80,
          },
          upkeepCost: {
            ResourceType.iron: 3,
            ResourceType.gold: 5,
          },
          buildTime: 2,
          effects: {
            ResourceType.military: 15,
          },
          unlockRequirements: {
            ResourceType.iron: 100,
          },
          specialEffects: {
            'equipment_quality': 1.3,
            'upgrade_cost_reduction': 0.9,
          },
        );

      case FacilityType.watchtower:
        return const Facility(
          type: FacilityType.watchtower,
          name: '見張り台',
          emoji: '🗼',
          description: '敵の侵攻を早期発見し、防御力を高める。',
          level: 1,
          maxLevel: 3,
          buildCost: {
            ResourceType.wood: 30,
            ResourceType.gold: 50,
          },
          upkeepCost: {
            ResourceType.food: 2,
          },
          buildTime: 1,
          effects: {
            ResourceType.military: 8,
          },
          unlockRequirements: {},
          specialEffects: {
            'defense_bonus': 1.2,
            'early_warning': 1.0,
          },
        );

      case FacilityType.fortress:
        return const Facility(
          type: FacilityType.fortress,
          name: '要塞',
          emoji: '🏰',
          description: '強固な防御施設。大幅な防御力向上。',
          level: 1,
          maxLevel: 3,
          buildCost: {
            ResourceType.wood: 100,
            ResourceType.iron: 80,
            ResourceType.gold: 200,
          },
          upkeepCost: {
            ResourceType.food: 8,
            ResourceType.gold: 15,
          },
          buildTime: 5,
          effects: {
            ResourceType.military: 50,
          },
          unlockRequirements: {
            ResourceType.population: 1000,
            ResourceType.military: 100,
          },
          specialEffects: {
            'defense_bonus': 1.5,
            'siege_resistance': 1.4,
          },
        );

      // 経済施設
      case FacilityType.market:
        return const Facility(
          type: FacilityType.market,
          name: '市場',
          emoji: '🏪',
          description: '商業の中心地。金銭収入を増加させる。',
          level: 1,
          maxLevel: 4,
          buildCost: {
            ResourceType.wood: 40,
            ResourceType.gold: 60,
          },
          upkeepCost: {
            ResourceType.gold: 3,
          },
          buildTime: 2,
          effects: {
            ResourceType.gold: 25,
          },
          unlockRequirements: {
            ResourceType.population: 300,
          },
          specialEffects: {
            'trade_bonus': 1.2,
            'tax_efficiency': 1.1,
          },
        );

      case FacilityType.warehouse:
        return const Facility(
          type: FacilityType.warehouse,
          name: '倉庫',
          emoji: '🏬',
          description: '資源を大量に保管できる施設。',
          level: 1,
          maxLevel: 4,
          buildCost: {
            ResourceType.wood: 60,
            ResourceType.gold: 40,
          },
          upkeepCost: {
            ResourceType.gold: 2,
          },
          buildTime: 2,
          effects: {},
          unlockRequirements: {
            ResourceType.population: 200,
          },
          specialEffects: {
            'storage_capacity': 2.0,
            'resource_preservation': 0.95,
          },
        );

      case FacilityType.workshop:
        return const Facility(
          type: FacilityType.workshop,
          name: '工房',
          emoji: '🔨',
          description: '様々な物品を製造する工房。',
          level: 1,
          maxLevel: 4,
          buildCost: {
            ResourceType.wood: 50,
            ResourceType.iron: 20,
            ResourceType.gold: 70,
          },
          upkeepCost: {
            ResourceType.iron: 2,
            ResourceType.gold: 5,
          },
          buildTime: 2,
          effects: {
            ResourceType.culture: 10,
          },
          unlockRequirements: {
            ResourceType.population: 400,
          },
          specialEffects: {
            'production_bonus': 1.2,
            'craft_quality': 1.15,
          },
        );

      case FacilityType.mine:
        return const Facility(
          type: FacilityType.mine,
          name: '鉱山',
          emoji: '⛏️',
          description: '鉄や金を採掘する施設。',
          level: 1,
          maxLevel: 4,
          buildCost: {
            ResourceType.wood: 80,
            ResourceType.gold: 120,
          },
          upkeepCost: {
            ResourceType.food: 8,
            ResourceType.gold: 6,
          },
          buildTime: 4,
          effects: {
            ResourceType.iron: 15,
            ResourceType.gold: 10,
          },
          unlockRequirements: {
            ResourceType.population: 600,
          },
          specialEffects: {
            'mining_efficiency': 1.3,
            'resource_discovery': 0.1,
          },
        );

      // 文化施設
      case FacilityType.academy:
        return const Facility(
          type: FacilityType.academy,
          name: '学院',
          emoji: '🎓',
          description: '教育施設。文化レベルを向上させる。',
          level: 1,
          maxLevel: 4,
          buildCost: {
            ResourceType.wood: 70,
            ResourceType.gold: 100,
          },
          upkeepCost: {
            ResourceType.gold: 12,
          },
          buildTime: 4,
          effects: {
            ResourceType.culture: 20,
          },
          unlockRequirements: {
            ResourceType.population: 800,
            ResourceType.culture: 50,
          },
          specialEffects: {
            'hero_exp_bonus': 1.3,
            'skill_learning_speed': 1.2,
          },
        );

      case FacilityType.temple:
        return const Facility(
          type: FacilityType.temple,
          name: '神社',
          emoji: '⛩️',
          description: '人々の士気を高め、文化を向上させる。',
          level: 1,
          maxLevel: 3,
          buildCost: {
            ResourceType.wood: 50,
            ResourceType.gold: 80,
          },
          upkeepCost: {
            ResourceType.gold: 5,
          },
          buildTime: 3,
          effects: {
            ResourceType.culture: 15,
          },
          unlockRequirements: {
            ResourceType.population: 400,
          },
          specialEffects: {
            'morale_bonus': 1.15,
            'loyalty_bonus': 1.1,
          },
        );

      case FacilityType.library:
        return const Facility(
          type: FacilityType.library,
          name: '図書館',
          emoji: '📚',
          description: '知識を蓄積し、技術発展を促進する。',
          level: 1,
          maxLevel: 3,
          buildCost: {
            ResourceType.wood: 60,
            ResourceType.gold: 90,
          },
          upkeepCost: {
            ResourceType.gold: 8,
          },
          buildTime: 3,
          effects: {
            ResourceType.culture: 18,
          },
          unlockRequirements: {
            ResourceType.culture: 30,
          },
          specialEffects: {
            'research_speed': 1.25,
            'technology_bonus': 1.15,
          },
        );

      // 特殊施設
      case FacilityType.docks:
        return const Facility(
          type: FacilityType.docks,
          name: '港湾',
          emoji: '🚢',
          description: '水上交通の拠点。交易を活発化させる。',
          level: 1,
          maxLevel: 3,
          buildCost: {
            ResourceType.wood: 100,
            ResourceType.iron: 30,
            ResourceType.gold: 150,
          },
          upkeepCost: {
            ResourceType.gold: 10,
          },
          buildTime: 4,
          effects: {
            ResourceType.gold: 30,
          },
          unlockRequirements: {
            ResourceType.population: 600,
          },
          specialEffects: {
            'naval_transport': 1.0,
            'trade_range': 2.0,
            'water_access': 1.0,
          },
        );

      case FacilityType.embassy:
        return const Facility(
          type: FacilityType.embassy,
          name: '外交館',
          emoji: '🏛️',
          description: '他勢力との外交交渉を行う施設。',
          level: 1,
          maxLevel: 3,
          buildCost: {
            ResourceType.wood: 80,
            ResourceType.gold: 120,
          },
          upkeepCost: {
            ResourceType.gold: 15,
          },
          buildTime: 3,
          effects: {
            ResourceType.culture: 10,
          },
          unlockRequirements: {
            ResourceType.population: 1000,
            ResourceType.culture: 50,
          },
          specialEffects: {
            'diplomacy_bonus': 1.3,
            'treaty_effectiveness': 1.2,
          },
        );

      case FacilityType.spyNetwork:
        return const Facility(
          type: FacilityType.spyNetwork,
          name: '諜報網',
          emoji: '🕵️',
          description: '秘密情報を収集し、諜報活動を行う。',
          level: 1,
          maxLevel: 4,
          buildCost: {
            ResourceType.gold: 150,
          },
          upkeepCost: {
            ResourceType.gold: 20,
          },
          buildTime: 3,
          effects: {},
          unlockRequirements: {
            ResourceType.population: 800,
            ResourceType.culture: 30,
          },
          specialEffects: {
            'intelligence_gathering': 1.5,
            'sabotage_effectiveness': 1.3,
            'stealth_bonus': 1.4,
          },
        );
    }
  }

  /// 建設可能な施設リストを取得
  static List<FacilityType> getAvailableFacilities(
    ProvinceFacilities facilities,
    Map<ResourceType, int> resources,
  ) {
    final available = <FacilityType>[];

    for (final type in FacilityType.values) {
      if (canBuildFacility(type, facilities, resources)) {
        available.add(type);
      }
    }

    return available;
  }

  /// 施設を建設可能かチェック
  static bool canBuildFacility(
    FacilityType type,
    ProvinceFacilities facilities,
    Map<ResourceType, int> resources,
  ) {
    final template = getFacilityTemplate(type);
    if (template == null) return false;

    // 建設条件をチェック
    for (final requirement in template.unlockRequirements.entries) {
      if ((resources[requirement.key] ?? 0) < requirement.value) {
        return false;
      }
    }

    // 建設コストをチェック
    for (final cost in template.buildCost.entries) {
      if ((resources[cost.key] ?? 0) < cost.value) {
        return false;
      }
    }

    return true;
  }

  /// 施設建設のコストを計算
  static Map<ResourceType, int> calculateBuildCost(FacilityType type) {
    final template = getFacilityTemplate(type);
    if (template == null) return {};
    return template.buildCost;
  }
}
