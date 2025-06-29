/// サンプル装備データ
/// フェーズ3: 英雄装備システムのテスト用データ
library;

import '../models/water_margin_strategy_game.dart';

/// 装備のレアリティ
enum EquipmentRarity {
  common, // 一般
  uncommon, // 珍品
  rare, // 稀少
  epic, // 叙事詩
  legendary, // 伝説
}

/// 装備の種類
enum EquipmentType {
  weapon, // 武器
  armor, // 防具
  accessory, // 装身具
  mount, // 騎乗動物
}

/// 装備アイテム
class Equipment {
  const Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.statBonus,
    required this.description,
    this.specialEffect,
  });

  final String id;
  final String name;
  final EquipmentType type;
  final EquipmentRarity rarity;
  final HeroStats statBonus;
  final String description;
  final String? specialEffect;

  /// レアリティによる色分け
  int get rarityColor {
    switch (rarity) {
      case EquipmentRarity.common:
        return 0xFF9E9E9E; // グレー
      case EquipmentRarity.uncommon:
        return 0xFF4CAF50; // グリーン
      case EquipmentRarity.rare:
        return 0xFF2196F3; // ブルー
      case EquipmentRarity.epic:
        return 0xFF9C27B0; // パープル
      case EquipmentRarity.legendary:
        return 0xFFFF9800; // オレンジ
    }
  }
}

/// 英雄の装備セット
class HeroEquipment {
  const HeroEquipment({
    this.weapon,
    this.armor,
    this.accessory,
    this.mount,
  });

  final Equipment? weapon;
  final Equipment? armor;
  final Equipment? accessory;
  final Equipment? mount;

  /// 装備による総合ステータスボーナス
  HeroStats get totalStatBonus {
    var totalForce = 0;
    var totalIntelligence = 0;
    var totalCharisma = 0;
    var totalLeadership = 0;
    var totalLoyalty = 0;

    final equipments = [weapon, armor, accessory, mount];
    for (final equipment in equipments) {
      if (equipment != null) {
        totalForce += equipment.statBonus.force;
        totalIntelligence += equipment.statBonus.intelligence;
        totalCharisma += equipment.statBonus.charisma;
        totalLeadership += equipment.statBonus.leadership;
        totalLoyalty += equipment.statBonus.loyalty;
      }
    }

    return HeroStats(
      force: totalForce,
      intelligence: totalIntelligence,
      charisma: totalCharisma,
      leadership: totalLeadership,
      loyalty: totalLoyalty,
    );
  }

  HeroEquipment copyWith({
    Equipment? weapon,
    Equipment? armor,
    Equipment? accessory,
    Equipment? mount,
  }) {
    return HeroEquipment(
      weapon: weapon ?? this.weapon,
      armor: armor ?? this.armor,
      accessory: accessory ?? this.accessory,
      mount: mount ?? this.mount,
    );
  }
}

/// サンプル装備データクラス
class SampleEquipment {
  /// 武器一覧
  static const List<Equipment> weapons = [
    Equipment(
      id: 'wooden_sword',
      name: '木刀',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.common,
      statBonus: HeroStats(
        force: 5,
        intelligence: 0,
        charisma: 0,
        leadership: 0,
        loyalty: 0,
      ),
      description: '基本的な練習用武器',
    ),
    Equipment(
      id: 'iron_sword',
      name: '鉄剣',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.uncommon,
      statBonus: HeroStats(
        force: 12,
        intelligence: 0,
        charisma: 2,
        leadership: 0,
        loyalty: 0,
      ),
      description: '丈夫な鉄製の剣',
    ),
    Equipment(
      id: 'steel_blade',
      name: '鋼の刀',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.rare,
      statBonus: HeroStats(
        force: 20,
        intelligence: 0,
        charisma: 5,
        leadership: 3,
        loyalty: 0,
      ),
      description: '鋭く美しい鋼の刀',
    ),
    Equipment(
      id: 'demon_slayer',
      name: '降魔剣',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.epic,
      statBonus: HeroStats(
        force: 30,
        intelligence: 5,
        charisma: 8,
        leadership: 5,
        loyalty: 5,
      ),
      description: '悪を断つ霊剣',
      specialEffect: '戦闘時、相手の士気を-10',
    ),
    Equipment(
      id: 'heavenly_halberd',
      name: '天罡戟',
      type: EquipmentType.weapon,
      rarity: EquipmentRarity.legendary,
      statBonus: HeroStats(
        force: 45,
        intelligence: 10,
        charisma: 15,
        leadership: 12,
        loyalty: 8,
      ),
      description: '天地を貫く伝説の戟',
      specialEffect: '一騎討ちで必ず先制攻撃',
    ),
  ];

  /// 防具一覧
  static const List<Equipment> armors = [
    Equipment(
      id: 'cloth_robe',
      name: '布の袍',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.common,
      statBonus: HeroStats(
        force: 0,
        intelligence: 3,
        charisma: 2,
        leadership: 0,
        loyalty: 0,
      ),
      description: '簡素な布の衣服',
    ),
    Equipment(
      id: 'leather_armor',
      name: '革鎧',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.uncommon,
      statBonus: HeroStats(
        force: 5,
        intelligence: 0,
        charisma: 0,
        leadership: 3,
        loyalty: 2,
      ),
      description: '軽量で動きやすい革製の鎧',
    ),
    Equipment(
      id: 'chain_mail',
      name: '鎖帷子',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.rare,
      statBonus: HeroStats(
        force: 8,
        intelligence: 0,
        charisma: 5,
        leadership: 8,
        loyalty: 3,
      ),
      description: '金属の鎖で編まれた防具',
    ),
    Equipment(
      id: 'dragon_scale_armor',
      name: '竜鱗甲',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.epic,
      statBonus: HeroStats(
        force: 15,
        intelligence: 5,
        charisma: 12,
        leadership: 15,
        loyalty: 8,
      ),
      description: '竜の鱗で作られた神秘の鎧',
      specialEffect: '物理攻撃ダメージ-20%',
    ),
    Equipment(
      id: 'celestial_robes',
      name: '天衣無縫',
      type: EquipmentType.armor,
      rarity: EquipmentRarity.legendary,
      statBonus: HeroStats(
        force: 10,
        intelligence: 25,
        charisma: 20,
        leadership: 18,
        loyalty: 15,
      ),
      description: '天界の織物で作られた完璧な衣',
      specialEffect: '全ての状態異常を無効化',
    ),
  ];

  /// 装身具一覧
  static const List<Equipment> accessories = [
    Equipment(
      id: 'wooden_ring',
      name: '木の指輪',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.common,
      statBonus: HeroStats(
        force: 0,
        intelligence: 2,
        charisma: 1,
        leadership: 0,
        loyalty: 1,
      ),
      description: '素朴な木製の指輪',
    ),
    Equipment(
      id: 'silver_amulet',
      name: '銀のお守り',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.uncommon,
      statBonus: HeroStats(
        force: 0,
        intelligence: 5,
        charisma: 3,
        leadership: 2,
        loyalty: 5,
      ),
      description: '邪気を払う銀のお守り',
    ),
    Equipment(
      id: 'jade_pendant',
      name: '翡翠の垂飾',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.rare,
      statBonus: HeroStats(
        force: 0,
        intelligence: 10,
        charisma: 8,
        leadership: 5,
        loyalty: 7,
      ),
      description: '美しい翡翠で作られた装身具',
    ),
    Equipment(
      id: 'phoenix_feather',
      name: '鳳凰の羽',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.epic,
      statBonus: HeroStats(
        force: 5,
        intelligence: 15,
        charisma: 20,
        leadership: 12,
        loyalty: 10,
      ),
      description: '不死鳥の美しい羽根',
      specialEffect: '戦闘不能時に1度だけ復活',
    ),
    Equipment(
      id: 'imperial_seal',
      name: '皇帝の印璽',
      type: EquipmentType.accessory,
      rarity: EquipmentRarity.legendary,
      statBonus: HeroStats(
        force: 10,
        intelligence: 20,
        charisma: 30,
        leadership: 25,
        loyalty: 5,
      ),
      description: '皇帝の権威を示す印璽',
      specialEffect: '外交交渉で必ず成功',
    ),
  ];

  /// 騎乗動物一覧
  static const List<Equipment> mounts = [
    Equipment(
      id: 'farm_horse',
      name: '農馬',
      type: EquipmentType.mount,
      rarity: EquipmentRarity.common,
      statBonus: HeroStats(
        force: 3,
        intelligence: 0,
        charisma: 0,
        leadership: 2,
        loyalty: 0,
      ),
      description: '農作業用の丈夫な馬',
    ),
    Equipment(
      id: 'war_horse',
      name: '軍馬',
      type: EquipmentType.mount,
      rarity: EquipmentRarity.uncommon,
      statBonus: HeroStats(
        force: 8,
        intelligence: 0,
        charisma: 3,
        leadership: 5,
        loyalty: 0,
      ),
      description: '戦場で鍛えられた馬',
    ),
    Equipment(
      id: 'stallion',
      name: '駿馬',
      type: EquipmentType.mount,
      rarity: EquipmentRarity.rare,
      statBonus: HeroStats(
        force: 15,
        intelligence: 2,
        charisma: 8,
        leadership: 10,
        loyalty: 0,
      ),
      description: '足の速い美しい馬',
    ),
    Equipment(
      id: 'dragon_horse',
      name: '竜馬',
      type: EquipmentType.mount,
      rarity: EquipmentRarity.epic,
      statBonus: HeroStats(
        force: 25,
        intelligence: 5,
        charisma: 15,
        leadership: 18,
        loyalty: 5,
      ),
      description: '竜の血を引く神馬',
      specialEffect: '移動速度+50%',
    ),
    Equipment(
      id: 'celestial_steed',
      name: '天馬',
      type: EquipmentType.mount,
      rarity: EquipmentRarity.legendary,
      statBonus: HeroStats(
        force: 35,
        intelligence: 10,
        charisma: 25,
        leadership: 30,
        loyalty: 10,
      ),
      description: '天空を駆ける伝説の馬',
      specialEffect: '空中移動可能、地形制限無視',
    ),
  ];

  /// 全装備リスト
  static List<Equipment> get allEquipments => [
        ...weapons,
        ...armors,
        ...accessories,
        ...mounts,
      ];

  /// レアリティ別装備リスト
  static List<Equipment> getEquipmentsByRarity(EquipmentRarity rarity) {
    return allEquipments.where((equipment) => equipment.rarity == rarity).toList();
  }

  /// タイプ別装備リスト
  static List<Equipment> getEquipmentsByType(EquipmentType type) {
    return allEquipments.where((equipment) => equipment.type == type).toList();
  }

  /// IDで装備を検索
  static Equipment? getEquipmentById(String id) {
    try {
      return allEquipments.firstWhere((equipment) => equipment.id == id);
    } catch (e) {
      return null;
    }
  }

  /// ランダムな装備を取得
  static Equipment getRandomEquipment([EquipmentRarity? rarity]) {
    final equipments = rarity != null ? getEquipmentsByRarity(rarity) : allEquipments;
    final random = DateTime.now().millisecondsSinceEpoch % equipments.length;
    return equipments[random];
  }
}
