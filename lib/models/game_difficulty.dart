/// 水滸伝戦略ゲーム - 難易度・バランス調整システム
/// 初心者から上級者まで楽しめる難易度設定とゲームバランス調整
library;

import '../models/water_margin_strategy_game.dart';
import '../core/app_config.dart';

/// ゲーム難易度レベル
enum GameDifficulty {
  beginner('初心者', '資金豊富、敵AI弱い、開発コスト安い'),
  normal('標準', 'バランスの取れた設定'),
  hard('上級者', '資金少なめ、敵AI強い、イベント困難'),
  expert('達人', '限界に挑戦する設定');

  const GameDifficulty(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// ゲーム設定（難易度に応じた調整）
class GameDifficultySettings {
  const GameDifficultySettings({
    required this.difficulty,
    required this.initialGold,
    required this.developmentCostMultiplier,
    required this.recruitmentCostMultiplier,
    required this.incomeMultiplier,
    required this.aiAggressiveness,
    required this.eventFrequency,
    required this.heroExperienceMultiplier,
    required this.diplomaticSuccessRateBonus,
  });

  final GameDifficulty difficulty;
  final int initialGold;
  final double developmentCostMultiplier;
  final double recruitmentCostMultiplier;
  final double incomeMultiplier;
  final double aiAggressiveness;
  final double eventFrequency;
  final double heroExperienceMultiplier;
  final double diplomaticSuccessRateBonus;

  /// 難易度に応じた設定を取得
  static GameDifficultySettings forDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return const GameDifficultySettings(
          difficulty: GameDifficulty.beginner,
          initialGold: 2000, // 初期資金2倍
          developmentCostMultiplier: 0.7, // 開発コスト30%減
          recruitmentCostMultiplier: 0.8, // 徴兵コスト20%減
          incomeMultiplier: 1.5, // 収入50%増
          aiAggressiveness: 0.6, // AI攻撃性40%減
          eventFrequency: 0.7, // イベント発生30%減
          heroExperienceMultiplier: 1.5, // 経験値獲得50%増
          diplomaticSuccessRateBonus: 0.2, // 外交成功率+20%
        );

      case GameDifficulty.normal:
        return const GameDifficultySettings(
          difficulty: GameDifficulty.normal,
          initialGold: 1000, // 標準
          developmentCostMultiplier: 1.0, // 標準
          recruitmentCostMultiplier: 1.0, // 標準
          incomeMultiplier: 1.0, // 標準
          aiAggressiveness: 1.0, // 標準
          eventFrequency: 1.0, // 標準
          heroExperienceMultiplier: 1.0, // 標準
          diplomaticSuccessRateBonus: 0.0, // 標準
        );

      case GameDifficulty.hard:
        return const GameDifficultySettings(
          difficulty: GameDifficulty.hard,
          initialGold: 600, // 初期資金40%減
          developmentCostMultiplier: 1.3, // 開発コスト30%増
          recruitmentCostMultiplier: 1.2, // 徴兵コスト20%増
          incomeMultiplier: 0.8, // 収入20%減
          aiAggressiveness: 1.4, // AI攻撃性40%増
          eventFrequency: 1.3, // イベント発生30%増
          heroExperienceMultiplier: 0.8, // 経験値獲得20%減
          diplomaticSuccessRateBonus: -0.1, // 外交成功率-10%
        );

      case GameDifficulty.expert:
        return const GameDifficultySettings(
          difficulty: GameDifficulty.expert,
          initialGold: 400, // 初期資金60%減
          developmentCostMultiplier: 1.5, // 開発コスト50%増
          recruitmentCostMultiplier: 1.4, // 徴兵コスト40%増
          incomeMultiplier: 0.6, // 収入40%減
          aiAggressiveness: 1.8, // AI攻撃性80%増
          eventFrequency: 1.5, // イベント発生50%増
          heroExperienceMultiplier: 0.7, // 経験値獲得30%減
          diplomaticSuccessRateBonus: -0.2, // 外交成功率-20%
        );
    }
  }

  /// 開発コストを計算
  int getDevelopmentCost() {
    return (AppConstants.developmentCost * developmentCostMultiplier).round();
  }

  /// 徴兵コストを計算
  int getRecruitmentCost(int amount) {
    return (amount * AppConstants.recruitmentCostPerTroop * recruitmentCostMultiplier).round();
  }

  /// 収入を計算
  int calculateIncome(int baseIncome) {
    return (baseIncome * incomeMultiplier).round();
  }

  /// 英雄経験値を計算
  int calculateHeroExperience(int baseExperience) {
    return (baseExperience * heroExperienceMultiplier).round();
  }

  /// 外交成功率を調整
  double adjustDiplomaticSuccessRate(double baseRate) {
    return (baseRate + diplomaticSuccessRateBonus).clamp(0.05, 0.95);
  }
}

/// ゲームバランス調整ヘルパー
class GameBalanceHelper {
  GameBalanceHelper._();

  /// 現在の難易度設定を取得
  static GameDifficultySettings getCurrentSettings(WaterMarginGameState gameState) {
    // gameStateに難易度情報を追加する必要がある
    // とりあえず標準設定を返す
    return GameDifficultySettings.forDifficulty(GameDifficulty.normal);
  }

  /// プレイヤーの進行状況に基づく動的調整
  static GameBalanceAdjustment calculateDynamicAdjustment(WaterMarginGameState gameState) {
    final playerProvinces =
        gameState.provinces.values.where((p) => gameState.factions[p.name] == Faction.liangshan).length;
    final totalProvinces = gameState.provinces.length;
    final progressRatio = playerProvinces / totalProvinces;

    // プレイヤーが劣勢な場合は支援
    if (progressRatio < 0.2 && gameState.currentTurn > 10) {
      return const GameBalanceAdjustment(
        incomeBonus: 0.2,
        experienceBonus: 0.3,
        eventPenaltyReduction: 0.5,
        reasoning: '劣勢支援',
      );
    }

    // プレイヤーが優勢すぎる場合は挑戦を増やす
    if (progressRatio > 0.7) {
      return const GameBalanceAdjustment(
        incomeBonus: -0.1,
        aiAggressivenessBonus: 0.3,
        eventFrequencyIncrease: 0.2,
        reasoning: '挑戦増加',
      );
    }

    // バランスが取れている場合
    return const GameBalanceAdjustment(
      reasoning: 'バランス良好',
    );
  }

  /// 新しいプレイヤー向けのチュートリアル提案
  static List<String> getTutorialTips(WaterMarginGameState gameState) {
    final tips = <String>[];

    if (gameState.currentTurn <= 3) {
      tips.add('💡 最初は農業開発で安定した収入を確保しましょう');
      tips.add('💡 英雄を配置して州の能力を向上させましょう');
    }

    if (gameState.currentTurn <= 5) {
      tips.add('💡 隣接する中立州との外交で平和的拡張を狙いましょう');
      tips.add('💡 兵力を蓄えて攻撃に備えましょう');
    }

    final playerGold = gameState.playerGold;
    if (playerGold < 200) {
      tips.add('💡 資金が不足しています。商業開発で収入を増やしましょう');
    }

    final playerProvinces =
        gameState.provinces.values.where((p) => gameState.factions[p.name] == Faction.liangshan).length;
    if (playerProvinces >= 5 && gameState.diplomacy == null) {
      tips.add('💡 外交システムを活用して同盟を結びましょう');
    }

    return tips;
  }
}

/// 動的バランス調整
class GameBalanceAdjustment {
  const GameBalanceAdjustment({
    this.incomeBonus = 0.0,
    this.experienceBonus = 0.0,
    this.eventPenaltyReduction = 0.0,
    this.aiAggressivenessBonus = 0.0,
    this.eventFrequencyIncrease = 0.0,
    required this.reasoning,
  });

  final double incomeBonus;
  final double experienceBonus;
  final double eventPenaltyReduction;
  final double aiAggressivenessBonus;
  final double eventFrequencyIncrease;
  final String reasoning;

  bool get hasAdjustments =>
      incomeBonus != 0.0 ||
      experienceBonus != 0.0 ||
      eventPenaltyReduction != 0.0 ||
      aiAggressivenessBonus != 0.0 ||
      eventFrequencyIncrease != 0.0;
}
