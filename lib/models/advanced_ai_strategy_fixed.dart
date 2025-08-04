/// 修正版改良されたAI戦略システム
/// 地形を考慮した戦術、長期戦略、同盟関係
library;

import '../models/water_margin_strategy_game.dart';
import '../models/province.dart';
import '../models/ai_system.dart';
// import '../models/advanced_battle_system.dart';
import '../data/water_margin_map.dart';

/// AI戦略レベル
enum AIStrategyLevel {
  basic, // 基本AI
  advanced, // 高度AI
  expert, // 上級AI
}

/// 長期戦略タイプ
enum LongTermStrategy {
  expansion, // 拡張主義
  consolidation, // 統合重視
  economic, // 経済発展
  diplomatic, // 外交重視
}

/// 脅威レベル
enum ThreatLevel { low, medium, high }

/// 戦略目標タイプ
enum GoalType {
  territorial, // 領土
  economic, // 経済
  military, // 軍事
  security, // 治安
  development, // 開発
  diplomatic, // 外交
}

/// 改良されたAI戦略システム
class AdvancedAIStrategy {
  AdvancedAIStrategy({
    required this.level,
    required this.longTermStrategy,
    required this.factionId,
    this.adaptiveThreshold = 3,
  });

  final AIStrategyLevel level;
  final LongTermStrategy longTermStrategy;
  final String factionId;
  final int adaptiveThreshold; // 戦略変更の閾値

  /// 戦略的思考の実行
  AIThinkingResult performStrategicThinking(WaterMarginGameState gameState) {
    switch (level) {
      case AIStrategyLevel.basic:
        return _basicThinking(gameState);
      case AIStrategyLevel.advanced:
        return _advancedThinking(gameState);
      case AIStrategyLevel.expert:
        return _expertThinking(gameState);
    }
  }

  /// 基本AI思考
  AIThinkingResult _basicThinking(WaterMarginGameState gameState) {
    // 既存のAISystemを使用
    final aiSystem = AISystemFactory.createAI(factionId);
    return aiSystem.think(gameState);
  }

  /// 高度AI思考
  AIThinkingResult _advancedThinking(WaterMarginGameState gameState) {
    // 1. 状況分析
    final situationAnalysis = _analyzeSituation(gameState);

    // 2. 長期戦略に基づく目標設定
    final strategicGoals = _setStrategicGoals(gameState, situationAnalysis);

    // 3. 戦術的行動計画
    final tacticalActions = _planTacticalActions(gameState, strategicGoals);

    // 4. 最適行動の決定
    final bestAction = tacticalActions.isNotEmpty
        ? tacticalActions.first
        : const AIAction(type: AIActionType.wait, priority: 0, sourceProvinceId: '');

    return AIThinkingResult(
      chosenAction: bestAction,
      reasoning: _generateReasoning(bestAction, situationAnalysis),
      allActions: tacticalActions,
    );
  }

  /// 上級AI思考（簡易版）
  AIThinkingResult _expertThinking(WaterMarginGameState gameState) {
    // 基本的には高度AI思考と同じ処理
    return _advancedThinking(gameState);
  }

  /// 状況分析
  SituationAnalysis _analyzeSituation(WaterMarginGameState gameState) {
    final ownedProvinces = gameState.provinces.values
        .where((p) => WaterMarginMap.initialProvinceFactions[p.name]?.name == factionId)
        .toList();

    final totalTroops = ownedProvinces.fold(0, (sum, p) => sum + p.military.toInt());
    final totalEconomy = ownedProvinces.fold(0, (sum, p) => sum + p.commerce.toInt());
    final averageSecurity = ownedProvinces.isEmpty
        ? 0
        : ownedProvinces.fold(0, (sum, p) => sum + (p.security * 100).toInt()) ~/ ownedProvinces.length;

    // 脅威レベル計算
    final threatLevel = _calculateThreatLevel(gameState, ownedProvinces);

    // 拡張機会
    final expansionOpportunities = _findExpansionOpportunities(gameState, ownedProvinces);

    return SituationAnalysis(
      ownedProvinces: ownedProvinces,
      totalMilitaryPower: totalTroops,
      economicStrength: totalEconomy,
      securityLevel: averageSecurity,
      threatLevel: threatLevel,
      expansionOpportunities: expansionOpportunities,
    );
  }

  /// 脅威レベルを計算
  ThreatLevel _calculateThreatLevel(WaterMarginGameState gameState, List<Province> ownedProvinces) {
    int totalEnemyPower = 0;
    int borderingEnemies = 0;

    for (final province in ownedProvinces) {
      for (final neighborName in province.neighbors) {
        final neighbor = gameState.provinces[neighborName];
        if (neighbor != null && WaterMarginMap.initialProvinceFactions[neighbor.name]?.name != factionId) {
          totalEnemyPower += neighbor.military.toInt();
          borderingEnemies++;
        }
      }
    }

    if (totalEnemyPower < 1000 && borderingEnemies < 3) return ThreatLevel.low;
    if (totalEnemyPower < 3000 && borderingEnemies < 6) return ThreatLevel.medium;
    return ThreatLevel.high;
  }

  /// 拡張機会を発見
  List<ExpansionOpportunity> _findExpansionOpportunities(
      WaterMarginGameState gameState, List<Province> ownedProvinces) {
    final opportunities = <ExpansionOpportunity>[];

    for (final province in ownedProvinces) {
      for (final neighborName in province.neighbors) {
        final neighbor = gameState.provinces[neighborName];
        if (neighbor != null && WaterMarginMap.initialProvinceFactions[neighbor.name]?.name != factionId) {
          final powerRatio = province.military / (neighbor.military + 1);
          final economicValue = neighbor.commerce + neighbor.agriculture;

          if (powerRatio > 1.2) {
            // 勝算がある
            opportunities.add(ExpansionOpportunity(
              targetProvince: neighbor,
              sourceProvince: province,
              successProbability: (powerRatio * 0.5).clamp(0.0, 1.0),
              economicValue: economicValue.toInt(),
              strategicValue: _calculateStrategicValue(neighbor),
            ));
          }
        }
      }
    }

    // 価値でソート
    opportunities.sort((a, b) => (b.economicValue + b.strategicValue).compareTo(a.economicValue + a.strategicValue));

    return opportunities;
  }

  /// 戦略的価値を計算
  int _calculateStrategicValue(Province province) {
    int value = 0;

    // 首都なら価値が高い（未定義ならコメントアウト）
    // if (province.capital) value += 100;

    // 特殊機能があれば価値が高い（未定義ならコメントアウト）
    // if (province.specialFeature != null) value += 50;

    // 隣接する州の数（交通の要衝）
    value += province.neighbors.length * 10;

    return value;
  }

  /// 戦略的目標を設定
  List<StrategicGoal> _setStrategicGoals(WaterMarginGameState gameState, SituationAnalysis analysis) {
    final goals = <StrategicGoal>[];

    switch (longTermStrategy) {
      case LongTermStrategy.expansion:
        goals.add(const StrategicGoal(
          type: GoalType.territorial,
          priority: 10,
          description: '領土拡張',
        ));
        if (analysis.economicStrength < 5000) {
          goals.add(const StrategicGoal(
            type: GoalType.economic,
            priority: 7,
            description: '経済基盤強化',
          ));
        }
        break;

      case LongTermStrategy.consolidation:
        goals.add(const StrategicGoal(
          type: GoalType.security,
          priority: 10,
          description: '既存領土の安定化',
        ));
        goals.add(const StrategicGoal(
          type: GoalType.military,
          priority: 8,
          description: '軍事力増強',
        ));
        break;

      case LongTermStrategy.economic:
        goals.add(const StrategicGoal(
          type: GoalType.economic,
          priority: 10,
          description: '経済発展',
        ));
        goals.add(const StrategicGoal(
          type: GoalType.development,
          priority: 8,
          description: '州開発',
        ));
        break;

      case LongTermStrategy.diplomatic:
        goals.add(const StrategicGoal(
          type: GoalType.diplomatic,
          priority: 10,
          description: '同盟強化',
        ));
        goals.add(const StrategicGoal(
          type: GoalType.economic,
          priority: 6,
          description: '交易促進',
        ));
        break;
    }

    return goals;
  }

  /// 戦術的行動を計画
  List<AIAction> _planTacticalActions(WaterMarginGameState gameState, List<StrategicGoal> goals) {
    final actions = <AIAction>[];

    for (final goal in goals) {
      switch (goal.type) {
        case GoalType.territorial:
          actions.addAll(_planTerritorialActions(gameState));
          break;
        case GoalType.economic:
          actions.addAll(_planEconomicActions(gameState));
          break;
        case GoalType.military:
          actions.addAll(_planMilitaryActions(gameState));
          break;
        case GoalType.security:
          actions.addAll(_planSecurityActions(gameState));
          break;
        case GoalType.development:
          actions.addAll(_planDevelopmentActions(gameState));
          break;
        case GoalType.diplomatic:
          actions.addAll(_planDiplomaticActions(gameState));
          break;
      }
    }

    // 優先度でソート
    actions.sort((a, b) => b.priority.compareTo(a.priority));
    return actions;
  }

  /// 領土拡張行動を計画
  List<AIAction> _planTerritorialActions(WaterMarginGameState gameState) {
    final actions = <AIAction>[];
    final analysis = _analyzeSituation(gameState);

    for (final opportunity in analysis.expansionOpportunities.take(3)) {
      if (opportunity.successProbability > 0.6) {
        actions.add(AIAction(
          type: AIActionType.attack,
          priority: (opportunity.successProbability * 10).round(),
          sourceProvinceId: opportunity.sourceProvince.name,
          targetProvinceId: opportunity.targetProvince.name,
        ));
      }
    }

    return actions;
  }

  /// 経済発展行動を計画
  List<AIAction> _planEconomicActions(WaterMarginGameState gameState) {
    final actions = <AIAction>[];
    final ownedProvinces = gameState.provinces.values
        .where((p) => WaterMarginMap.initialProvinceFactions[p.name]?.name == factionId)
        .toList();

    for (final province in ownedProvinces) {
      if (province.commerce < 80) {
        actions.add(AIAction(
          type: AIActionType.develop,
          priority: 7,
          sourceProvinceId: province.name,
          developmentType: DevelopmentType.commerce,
        ));
      }
      if (province.agriculture < 80) {
        actions.add(AIAction(
          type: AIActionType.develop,
          priority: 6,
          sourceProvinceId: province.name,
          developmentType: DevelopmentType.agriculture,
        ));
      }
    }

    return actions;
  }

  /// 軍事強化行動を計画
  List<AIAction> _planMilitaryActions(WaterMarginGameState gameState) {
    final actions = <AIAction>[];
    final ownedProvinces = gameState.provinces.values
        .where((p) => WaterMarginMap.initialProvinceFactions[p.name]?.name == factionId)
        .toList();

    for (final province in ownedProvinces) {
      // 前線の州は兵力強化
      final isfront = province.neighbors.any((neighborName) {
        final neighbor = gameState.provinces[neighborName];
        return neighbor != null && WaterMarginMap.initialProvinceFactions[neighbor.name]?.name != factionId;
      });

      if (isfront && province.military < 500) {
        actions.add(AIAction(
          type: AIActionType.recruit,
          priority: 8,
          sourceProvinceId: province.name,
        ));
      }
    }

    return actions;
  }

  /// 治安維持行動を計画
  List<AIAction> _planSecurityActions(WaterMarginGameState gameState) {
    final actions = <AIAction>[];
    final ownedProvinces = gameState.provinces.values
        .where((p) => WaterMarginMap.initialProvinceFactions[p.name]?.name == factionId)
        .toList();

    for (final province in ownedProvinces) {
      if (province.security < 60) {
        actions.add(AIAction(
          type: AIActionType.develop,
          priority: 5,
          sourceProvinceId: province.name,
          developmentType: DevelopmentType.security,
        ));
      }
    }

    return actions;
  }

  /// 州開発行動を計画
  List<AIAction> _planDevelopmentActions(WaterMarginGameState gameState) {
    return _planEconomicActions(gameState) + _planSecurityActions(gameState);
  }

  /// 外交行動を計画
  List<AIAction> _planDiplomaticActions(WaterMarginGameState gameState) {
    final actions = <AIAction>[];

    // 現在は基本実装のみ（将来拡張）
    actions.add(const AIAction(
      type: AIActionType.wait,
      priority: 3,
      sourceProvinceId: '',
    ));

    return actions;
  }

  /// 推論を生成
  String _generateReasoning(AIAction action, SituationAnalysis analysis) {
    final buffer = StringBuffer();

    buffer.writeln('戦略分析：');
    buffer.writeln('- 軍事力: ${analysis.totalMilitaryPower}');
    buffer.writeln('- 経済力: ${analysis.economicStrength}');
    buffer.writeln('- 脅威レベル: ${analysis.threatLevel.name}');
    buffer.writeln();
    buffer.writeln('選択した行動: ${action.type.name}');

    return buffer.toString();
  }
}

// 支援クラス定義
class SituationAnalysis {
  const SituationAnalysis({
    required this.ownedProvinces,
    required this.totalMilitaryPower,
    required this.economicStrength,
    required this.securityLevel,
    required this.threatLevel,
    required this.expansionOpportunities,
  });

  final List<Province> ownedProvinces;
  final int totalMilitaryPower;
  final int economicStrength;
  final int securityLevel;
  final ThreatLevel threatLevel;
  final List<ExpansionOpportunity> expansionOpportunities;
}

class ExpansionOpportunity {
  const ExpansionOpportunity({
    required this.targetProvince,
    required this.sourceProvince,
    required this.successProbability,
    required this.economicValue,
    required this.strategicValue,
  });

  final Province targetProvince;
  final Province sourceProvince;
  final double successProbability;
  final int economicValue;
  final int strategicValue;
}

class StrategicGoal {
  const StrategicGoal({
    required this.type,
    required this.priority,
    required this.description,
  });

  final GoalType type;
  final int priority;
  final String description;
}
