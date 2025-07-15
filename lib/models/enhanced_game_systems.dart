/// 改善されたゲームシステム設計
/// 兵糧システム、改良された戦闘システム、英雄管理、兵力移動などを含む
library;

import 'water_margin_strategy_game.dart';

/// 兵糧システム
class SupplySystem {
  /// 1人の兵士が1ターンに消費する兵糧
  static const int foodPerSoldierPerTurn = 2;

  /// 兵糧不足時の戦闘力減少率
  static const double starvationPenalty = 0.5;

  /// 州の兵糧消費量を計算
  static int calculateFoodConsumption(Province province) {
    return province.currentTroops * foodPerSoldierPerTurn;
  }

  /// 州の兵糧生産量を計算
  static int calculateFoodProduction(Province province) {
    return province.state.foodProduction;
  }

  /// 兵糧収支を計算
  static int calculateFoodBalance(Province province) {
    return calculateFoodProduction(province) - calculateFoodConsumption(province);
  }
}

/// 改良された戦闘結果
enum EnhancedBattleResult {
  victory, // 完全勝利
  majorVictory, // 大勝利
  minorVictory, // 小勝利
  draw, // 引き分け
  minorDefeat, // 小敗北
  majorDefeat, // 大敗北
  defeat, // 完全敗北
  retreat, // 撤退
  surrender, // 降伏
}

/// 戦闘詳細結果
class DetailedBattleResult {
  const DetailedBattleResult({
    required this.result,
    required this.attackerLosses,
    required this.defenderLosses,
    required this.attackerSurvivors,
    required this.defenderSurvivors,
    required this.capturedTroops,
    required this.heroActions,
  });

  final EnhancedBattleResult result;
  final int attackerLosses;
  final int defenderLosses;
  final int attackerSurvivors;
  final int defenderSurvivors;
  final int capturedTroops; // 降伏・捕虜兵力
  final List<String> heroActions; // 英雄の活躍

  /// 勝者の判定
  bool get isAttackerVictory => [
        EnhancedBattleResult.victory,
        EnhancedBattleResult.majorVictory,
        EnhancedBattleResult.minorVictory,
      ].contains(result);

  /// 損失率（攻撃側）
  double get attackerLossRate => attackerLosses / (attackerLosses + attackerSurvivors);

  /// 損失率（防御側）
  double get defenderLossRate => defenderLosses / (defenderLosses + defenderSurvivors);
}

/// 英雄のレベルアップシステム
class HeroLevelSystem {
  /// 経験値からレベルを計算
  static int calculateLevel(int experience) {
    if (experience < 100) return 1;
    if (experience < 300) return 2;
    if (experience < 600) return 3;
    if (experience < 1000) return 4;
    if (experience < 1500) return 5;
    if (experience < 2100) return 6;
    if (experience < 2800) return 7;
    if (experience < 3600) return 8;
    if (experience < 4500) return 9;
    return 10; // 最大レベル
  }

  /// 次のレベルまでの必要経験値
  static int experienceToNextLevel(int currentExp) {
    final currentLevel = calculateLevel(currentExp);
    if (currentLevel >= 10) return 0;

    final nextLevelExp = _getExpForLevel(currentLevel + 1);
    return nextLevelExp - currentExp;
  }

  /// 指定レベルに必要な経験値
  static int _getExpForLevel(int level) {
    switch (level) {
      case 1:
        return 0;
      case 2:
        return 100;
      case 3:
        return 300;
      case 4:
        return 600;
      case 5:
        return 1000;
      case 6:
        return 1500;
      case 7:
        return 2100;
      case 8:
        return 2800;
      case 9:
        return 3600;
      case 10:
        return 4500;
      default:
        return 4500;
    }
  }

  /// レベルアップによる能力値ボーナス
  static HeroStats calculateLevelBonus(HeroStats baseStats, int experience) {
    final level = calculateLevel(experience);
    final bonus = level - 1; // レベル1では+0、レベル10では+9

    return HeroStats(
      force: (baseStats.force + bonus).clamp(1, 100),
      intelligence: (baseStats.intelligence + bonus).clamp(1, 100),
      charisma: (baseStats.charisma + bonus).clamp(1, 100),
      leadership: (baseStats.leadership + bonus).clamp(1, 100),
      loyalty: baseStats.loyalty, // 義理は成長しない
    );
  }

  /// 英雄が戦闘で得られる経験値
  static int calculateBattleExperience(
    bool isVictory,
    int enemyTroops,
    HeroSkill heroSkill,
  ) {
    int baseExp = (enemyTroops / 100).clamp(10, 100).toInt();

    if (isVictory) {
      baseExp = (baseExp * 1.5).toInt();
    }

    // 武将は戦闘で多くの経験値を得る
    if (heroSkill == HeroSkill.warrior) {
      baseExp = (baseExp * 1.2).toInt();
    }

    return baseExp;
  }

  /// 英雄が内政で得られる経験値
  static int calculateAdministrationExperience(
    DevelopmentType type,
    HeroSkill heroSkill,
  ) {
    int baseExp = 20;

    // 政治家は内政で多くの経験値を得る
    if (heroSkill == HeroSkill.administrator) {
      baseExp = (baseExp * 1.5).toInt();
    }

    return baseExp;
  }
}

/// 兵力移動システム
class TroopMovementSystem {
  /// 兵力移動コマンド
  static const int movementCostPerTroop = 1; // 1兵につき1両の移動費

  /// 兵力移動の実行
  static MovementResult moveTroops({
    required Province sourceProvince,
    required Province targetProvince,
    required int troopCount,
    required List<String> adjacentIds,
  }) {
    // 隣接チェック
    if (!sourceProvince.adjacentProvinceIds.contains(targetProvince.id)) {
      return MovementResult(
        success: false,
        message: '${targetProvince.name}は${sourceProvince.name}に隣接していません',
      );
    }

    // 兵力不足チェック
    if (sourceProvince.currentTroops < troopCount) {
      return MovementResult(
        success: false,
        message: '${sourceProvince.name}には$troopCount 人の兵力がありません',
      );
    }

    // 移動費計算
    final cost = troopCount * movementCostPerTroop;

    return MovementResult(
      success: true,
      message: '${sourceProvince.name}から${targetProvince.name}へ$troopCount 人を移動',
      cost: cost,
    );
  }
}

/// 移動結果
class MovementResult {
  const MovementResult({
    required this.success,
    required this.message,
    this.cost = 0,
  });

  final bool success;
  final String message;
  final int cost;
}

/// 英雄の行動タイプ
enum HeroAction {
  administration, // 内政
  military, // 軍事
  diplomacy, // 外交
  exploration, // 探索
  training, // 訓練
  rest, // 休息
}

/// 英雄の行動結果
class HeroActionResult {
  const HeroActionResult({
    required this.success,
    required this.message,
    required this.experienceGained,
    this.goldGained = 0,
    this.effectDescription,
  });

  final bool success;
  final String message;
  final int experienceGained;
  final int goldGained;
  final String? effectDescription;
}

/// 改良された内政システム
class EnhancedDevelopmentSystem {
  /// 開発レベルの上限
  static const int maxDevelopmentLevel = 200;

  /// 開発コストの計算（現在値に応じて増加）
  /// 開発コスト計算（人口依存型）
  /// [currentLevel]: 現在の開発レベル
  /// [type]: 開発種別
  /// [population]: 州の人口（万人単位）
  static int calculateDevelopmentCost(int currentLevel, DevelopmentType type, int population) {
    final baseCost = _getBaseCost(type);
    final levelMultiplier = 1 + (currentLevel / 50); // 50レベルごとに2倍
    // 人口依存係数: 100万人ごとに+10%コスト増（例: 500万人→+50%）
    final popMultiplier = 1 + (population / 1000 * 1.0 * 0.1); // populationは万人単位
    return (baseCost * levelMultiplier * popMultiplier).round();
  }

  static int _getBaseCost(DevelopmentType type) {
    switch (type) {
      case DevelopmentType.agriculture:
        return 150;
      case DevelopmentType.commerce:
        return 200;
      case DevelopmentType.military:
        return 250;
      case DevelopmentType.security:
        return 180;
    }
  }

  /// 開発効果の計算
  static int calculateDevelopmentEffect(
    int currentLevel,
    DevelopmentType type,
    Hero? assignedHero,
  ) {
    int baseEffect = _getBaseEffect(type);

    // 英雄のボーナス
    if (assignedHero != null) {
      final heroBonus = _calculateHeroBonus(assignedHero, type);
      baseEffect = (baseEffect * (1 + heroBonus)).toInt();
    }

    // 高レベルでは効果が減少
    if (currentLevel > 100) {
      final penalty = (currentLevel - 100) * 0.01;
      baseEffect = (baseEffect * (1 - penalty)).toInt();
    }

    return baseEffect.clamp(1, 20);
  }

  static int _getBaseEffect(DevelopmentType type) {
    switch (type) {
      case DevelopmentType.agriculture:
        return 8;
      case DevelopmentType.commerce:
        return 6;
      case DevelopmentType.military:
        return 5;
      case DevelopmentType.security:
        return 7;
    }
  }

  static double _calculateHeroBonus(Hero hero, DevelopmentType type) {
    final level = HeroLevelSystem.calculateLevel(hero.experience);
    final levelBonus = (level - 1) * 0.05; // レベル1で+0%、レベル10で+45%

    double skillBonus = 0.0;
    switch (type) {
      case DevelopmentType.agriculture:
      case DevelopmentType.commerce:
        if (hero.skill == HeroSkill.administrator) {
          skillBonus = 0.3; // +30%
        }
        break;
      case DevelopmentType.military:
        if (hero.skill == HeroSkill.warrior) {
          skillBonus = 0.25; // +25%
        }
        break;
      case DevelopmentType.security:
        if (hero.skill == HeroSkill.administrator || hero.skill == HeroSkill.warrior) {
          skillBonus = 0.2; // +20%
        }
        break;
    }

    return levelBonus + skillBonus;
  }
}
