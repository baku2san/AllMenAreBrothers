/// 水滸伝戦略ゲーム 英雄システム拡張
/// フェーズ3: 英雄レベルアップ・経験値・スキルシステム
library;

import 'dart:math' as math;

import '../models/water_margin_strategy_game.dart';

/// 英雄の経験値タイプ
enum ExperienceType {
  combat, // 戦闘経験値
  administration, // 内政経験値
  diplomacy, // 外交経験値
  leadership, // 統率経験値
}

/// 英雄の階級システム
enum HeroRank {
  recruit, // 新人 (Lv1-10)
  veteran, // 古参 (Lv11-25)
  elite, // 精鋭 (Lv26-50)
  master, // 達人 (Lv51-75)
  legend, // 伝説 (Lv76-100)
}

/// 英雄のレベルアップ時習得スキル
enum HeroLevelSkill {
  // 戦闘系スキル
  berserker, // 狂戦士 - 戦闘力+20%
  tactician, // 戦術家 - 部隊指揮+30%
  duelMaster, // 一騎討ち名人 - 一騎討ち勝率+50%
  siegeExpert, // 攻城専門家 - 攻城戦+40%

  // 内政系スキル
  administrator, // 行政官 - 内政効率+25%
  economist, // 経済学者 - 収入+20%
  engineer, // 技術者 - 建設速度+30%
  scholar, // 学者 - 研究速度+25%

  // 外交系スキル
  negotiator, // 交渉人 - 外交成功率+30%
  spy, // 諜報員 - 情報収集+40%
  ambassador, // 大使 - 同盟維持+25%

  // 統率系スキル
  inspiring, // 鼓舞 - 部隊士気+20%
  strategist, // 戦略家 - 全体戦略+15%
  trainer, // 訓練官 - 兵士成長+25%
}

/// 英雄の詳細ステータス（レベルアップ対応）
class HeroAdvancedStats {
  const HeroAdvancedStats({
    required this.baseStats,
    required this.level,
    required this.experience,
    required this.skills,
    this.equipment,
  });

  final HeroStats baseStats; // 基本能力値
  final int level; // レベル (1-100)
  final Map<ExperienceType, int> experience; // 各種経験値
  final Set<HeroLevelSkill> skills; // 習得スキル
  final HeroEquipment? equipment; // 装備

  /// 経験値をレベルに変換
  static int calculateLevel(int totalExp) {
    if (totalExp < 100) return 1;
    if (totalExp < 500) return 2;
    if (totalExp < 1200) return 3;
    if (totalExp < 2500) return 4;
    if (totalExp < 5000) return 5;

    // レベル6以降は指数的増加
    for (int level = 6; level <= 100; level++) {
      final requiredExp = _getRequiredExpForLevel(level);
      if (totalExp < requiredExp) {
        return level - 1;
      }
    }
    return 100; // 最大レベル
  }

  /// 指定レベルに必要な経験値
  static int _getRequiredExpForLevel(int level) {
    if (level <= 1) return 0;
    if (level <= 5) {
      const baseExp = [0, 100, 500, 1200, 2500, 5000];
      return baseExp[level];
    }
    // レベル6以降: 5000 * (level - 5)^1.5
    return (5000 * math.pow(level - 5, 1.5)).round();
  }

  /// 次のレベルまでの必要経験値
  int get expToNextLevel {
    final totalExp = experience.values.fold(0, (sum, exp) => sum + exp);
    final nextLevelExp = _getRequiredExpForLevel(level + 1);
    return nextLevelExp - totalExp;
  }

  /// 現在の階級
  HeroRank get rank {
    if (level <= 10) return HeroRank.recruit;
    if (level <= 25) return HeroRank.veteran;
    if (level <= 50) return HeroRank.elite;
    if (level <= 75) return HeroRank.master;
    return HeroRank.legend;
  }

  /// レベルボーナス計算
  HeroStats get effectiveStats {
    final levelBonus = (level - 1) * 2; // レベル毎に+2
    final skillBonus = _calculateSkillBonus();
    final equipBonus = equipment?.totalBonus ??
        const HeroStats(
          force: 0,
          intelligence: 0,
          charisma: 0,
          leadership: 0,
          loyalty: 0,
        );

    return HeroStats(
      force: (baseStats.force + levelBonus + skillBonus.force + equipBonus.force).clamp(1, 150),
      intelligence:
          (baseStats.intelligence + levelBonus + skillBonus.intelligence + equipBonus.intelligence).clamp(1, 150),
      charisma: (baseStats.charisma + levelBonus + skillBonus.charisma + equipBonus.charisma).clamp(1, 150),
      leadership: (baseStats.leadership + levelBonus + skillBonus.leadership + equipBonus.leadership).clamp(1, 150),
      loyalty: (baseStats.loyalty + skillBonus.loyalty + equipBonus.loyalty).clamp(1, 150),
    );
  }

  /// スキルによるボーナス計算
  HeroStats _calculateSkillBonus() {
    int forceBonus = 0;
    int intBonus = 0;
    int charismaBonus = 0;
    int leadershipBonus = 0;
    int loyaltyBonus = 0;

    for (final skill in skills) {
      switch (skill) {
        case HeroLevelSkill.berserker:
          forceBonus += 15;
          break;
        case HeroLevelSkill.tactician:
          leadershipBonus += 20;
          break;
        case HeroLevelSkill.administrator:
          intBonus += 15;
          break;
        case HeroLevelSkill.economist:
          intBonus += 10;
          charismaBonus += 10;
          break;
        case HeroLevelSkill.negotiator:
          charismaBonus += 20;
          break;
        case HeroLevelSkill.inspiring:
          leadershipBonus += 15;
          loyaltyBonus += 10;
          break;
        case HeroLevelSkill.strategist:
          intBonus += 20;
          leadershipBonus += 10;
          break;
        case HeroLevelSkill.duelMaster:
          forceBonus += 12;
          break;
        case HeroLevelSkill.siegeExpert:
          forceBonus += 8;
          intBonus += 8;
          break;
        case HeroLevelSkill.engineer:
          intBonus += 15;
          break;
        case HeroLevelSkill.scholar:
          intBonus += 18;
          break;
        case HeroLevelSkill.spy:
          intBonus += 10;
          charismaBonus += 8;
          break;
        case HeroLevelSkill.ambassador:
          charismaBonus += 15;
          break;
        case HeroLevelSkill.trainer:
          leadershipBonus += 12;
          break;
      }
    }

    return HeroStats(
      force: forceBonus,
      intelligence: intBonus,
      charisma: charismaBonus,
      leadership: leadershipBonus,
      loyalty: loyaltyBonus,
    );
  }

  /// 経験値追加
  HeroAdvancedStats addExperience(ExperienceType type, int amount) {
    final newExperience = Map<ExperienceType, int>.from(experience);
    newExperience[type] = (newExperience[type] ?? 0) + amount;

    final totalExp = newExperience.values.fold(0, (sum, exp) => sum + exp);
    final newLevel = calculateLevel(totalExp);

    // レベルアップ時のスキル習得チェック
    Set<HeroLevelSkill> newSkills = Set.from(skills);
    if (newLevel > level) {
      final learnedSkills = _checkSkillLearning(newLevel);
      newSkills.addAll(learnedSkills);
    }

    return HeroAdvancedStats(
      baseStats: baseStats,
      level: newLevel,
      experience: newExperience,
      skills: newSkills,
      equipment: equipment,
    );
  }

  /// レベルアップ時のスキル習得判定
  Set<HeroLevelSkill> _checkSkillLearning(int newLevel) {
    final learnedSkills = <HeroLevelSkill>{};

    // レベル固定習得スキル
    if (newLevel == 10 && baseStats.force >= 80) {
      learnedSkills.add(HeroLevelSkill.berserker);
    }
    if (newLevel == 15 && baseStats.intelligence >= 80) {
      learnedSkills.add(HeroLevelSkill.administrator);
    }
    if (newLevel == 20 && baseStats.leadership >= 80) {
      learnedSkills.add(HeroLevelSkill.tactician);
    }
    if (newLevel == 25 && baseStats.charisma >= 80) {
      learnedSkills.add(HeroLevelSkill.negotiator);
    }

    // 高レベルスキル
    if (newLevel == 50 && baseStats.intelligence >= 90) {
      learnedSkills.add(HeroLevelSkill.strategist);
    }

    return learnedSkills;
  }

  /// コピー作成
  HeroAdvancedStats copyWith({
    HeroStats? baseStats,
    int? level,
    Map<ExperienceType, int>? experience,
    Set<HeroLevelSkill>? skills,
    HeroEquipment? equipment,
  }) {
    return HeroAdvancedStats(
      baseStats: baseStats ?? this.baseStats,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      equipment: equipment ?? this.equipment,
    );
  }
}

/// 英雄装備システム
class HeroEquipment {
  const HeroEquipment({
    this.weapon,
    this.armor,
    this.accessory,
  });

  final Equipment? weapon;
  final Equipment? armor;
  final Equipment? accessory;

  /// 装備による総合ボーナス
  HeroStats get totalBonus {
    final weaponBonus =
        weapon?.statBonus ?? const HeroStats(force: 0, intelligence: 0, charisma: 0, leadership: 0, loyalty: 0);
    final armorBonus =
        armor?.statBonus ?? const HeroStats(force: 0, intelligence: 0, charisma: 0, leadership: 0, loyalty: 0);
    final accessoryBonus =
        accessory?.statBonus ?? const HeroStats(force: 0, intelligence: 0, charisma: 0, leadership: 0, loyalty: 0);

    return HeroStats(
      force: weaponBonus.force + armorBonus.force + accessoryBonus.force,
      intelligence: weaponBonus.intelligence + armorBonus.intelligence + accessoryBonus.intelligence,
      charisma: weaponBonus.charisma + armorBonus.charisma + accessoryBonus.charisma,
      leadership: weaponBonus.leadership + armorBonus.leadership + accessoryBonus.leadership,
      loyalty: weaponBonus.loyalty + armorBonus.loyalty + accessoryBonus.loyalty,
    );
  }
}

/// 装備アイテム
class Equipment {
  const Equipment({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.statBonus,
    this.specialEffect,
    this.description,
  });

  final String id;
  final String name;
  final EquipmentType type;
  final EquipmentRarity rarity;
  final HeroStats statBonus;
  final String? specialEffect;
  final String? description;
}

/// 装備の種類
enum EquipmentType {
  weapon, // 武器
  armor, // 防具
  accessory, // アクセサリ
}

/// 装備のレア度
enum EquipmentRarity {
  common, // 一般
  uncommon, // 上質
  rare, // 稀少
  epic, // 英雄級
  legendary, // 伝説級
}

/// 英雄の拡張情報（レベルアップ対応）
class AdvancedHero {
  const AdvancedHero({
    required this.baseHero,
    required this.advancedStats,
    this.assignedProvince,
    this.specialMissions,
  });

  final Hero baseHero;
  final HeroAdvancedStats advancedStats;
  final String? assignedProvince; // 配置州
  final List<String>? specialMissions; // 特殊任務

  /// 実際の戦闘力（レベル・装備補正込み）
  int get effectiveCombatPower {
    final stats = advancedStats.effectiveStats;
    int basePower = ((stats.force + stats.leadership) * 0.6 + stats.intelligence * 0.4).round();

    // スキルボーナス
    if (advancedStats.skills.contains(HeroLevelSkill.berserker)) {
      basePower = (basePower * 1.2).round();
    }
    if (advancedStats.skills.contains(HeroLevelSkill.tactician)) {
      basePower = (basePower * 1.15).round();
    }

    return basePower;
  }

  /// 実際の内政力（レベル・装備補正込み）
  int get effectiveAdministrativePower {
    final stats = advancedStats.effectiveStats;
    int basePower = ((stats.intelligence + stats.charisma) * 0.7 + stats.leadership * 0.3).round();

    // スキルボーナス
    if (advancedStats.skills.contains(HeroLevelSkill.administrator)) {
      basePower = (basePower * 1.25).round();
    }
    if (advancedStats.skills.contains(HeroLevelSkill.economist)) {
      basePower = (basePower * 1.2).round();
    }

    return basePower;
  }

  /// レベルアップ
  AdvancedHero gainExperience(ExperienceType type, int amount) {
    return AdvancedHero(
      baseHero: baseHero,
      advancedStats: advancedStats.addExperience(type, amount),
      assignedProvince: assignedProvince,
      specialMissions: specialMissions,
    );
  }

  /// 装備変更
  AdvancedHero equipItem(Equipment equipment) {
    HeroEquipment newEquipment;
    final currentEquip = advancedStats.equipment ?? const HeroEquipment();

    switch (equipment.type) {
      case EquipmentType.weapon:
        newEquipment = HeroEquipment(
          weapon: equipment,
          armor: currentEquip.armor,
          accessory: currentEquip.accessory,
        );
        break;
      case EquipmentType.armor:
        newEquipment = HeroEquipment(
          weapon: currentEquip.weapon,
          armor: equipment,
          accessory: currentEquip.accessory,
        );
        break;
      case EquipmentType.accessory:
        newEquipment = HeroEquipment(
          weapon: currentEquip.weapon,
          armor: currentEquip.armor,
          accessory: equipment,
        );
        break;
    }

    return AdvancedHero(
      baseHero: baseHero,
      advancedStats: advancedStats.copyWith(equipment: newEquipment),
      assignedProvince: assignedProvince,
      specialMissions: specialMissions,
    );
  }
}
