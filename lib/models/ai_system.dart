/// 改良されたAI思考システム
/// フェーズ2: より賢いAI行動、状況に応じた戦略
library;

import '../models/water_margin_strategy_game.dart' hide Hero;
import '../models/water_margin_strategy_game.dart';

/// AIの性格タイプ
enum AIPersonality {
  aggressive, // 攻撃的
  defensive, // 守備的
  balanced, // バランス型
  opportunistic, // 機会主義
  economic, // 経済重視
}

/// AI行動の種類
enum AIActionType {
  attack, // 攻撃
  develop, // 開発
  recruit, // 徴兵
  diplomacy, // 外交
  fortify, // 要塞化
  wait, // 待機
}

/// AI行動計画
class AIAction {
  const AIAction({
    required this.type,
    required this.priority,
    required this.sourceProvinceId,
    this.targetProvinceId,
    this.developmentType,
  });

  final AIActionType type;
  final int priority; // 1-100の優先度
  final String sourceProvinceId;
  final String? targetProvinceId;
  final DevelopmentType? developmentType;
}

/// AI思考結果
class AIThinkingResult {
  const AIThinkingResult({
    required this.chosenAction,
    required this.reasoning,
    required this.allActions,
  });

  final AIAction chosenAction;
  final String reasoning;
  final List<AIAction> allActions;
}

/// 改良されたAIシステム
class AISystem {
  const AISystem({
    required this.personality,
    required this.factionId,
  });

  final AIPersonality personality;
  final String factionId;

  /// AI思考メインロジック
  AIThinkingResult think(GameState gameState) {
    final faction = gameState.factions[factionId];
    if (faction == null) {
      return const AIThinkingResult(
        chosenAction: AIAction(
          type: AIActionType.wait,
          priority: 0,
          sourceProvinceId: '',
        ),
        reasoning: '勢力が存在しません',
        allActions: [],
      );
    }

    final targetFaction = Faction.values.firstWhere(
      (f) => f.name == factionId,
      orElse: () => Faction.neutral,
    );
    
    final controlledProvinces = gameState.provinces.values
        .where((p) => p.controller == targetFaction)
        .toList();

    if (controlledProvinces.isEmpty) {
      return const AIThinkingResult(
        chosenAction: AIAction(
          type: AIActionType.wait,
          priority: 0,
          sourceProvinceId: '',
        ),
        reasoning: '支配する州がありません',
        allActions: [],
      );
    }

    // 利用可能な行動を生成
    final actions = _generateActions(gameState, controlledProvinces, targetFaction);
    
    // 性格に基づいて行動を選択
    final bestAction = _selectBestAction(actions, gameState);
    
    return AIThinkingResult(
      chosenAction: bestAction,
      reasoning: _generateReasoning(bestAction, gameState),
      allActions: actions,
    );
  }

  /// 利用可能な行動を生成
  List<AIAction> _generateActions(GameState gameState, List<Province> provinces, Faction targetFaction) {
    final actions = <AIAction>[];

    for (final province in provinces) {
      // 攻撃行動
      actions.addAll(_generateAttackActions(province, gameState, targetFaction));
      
      // 開発行動
      actions.addAll(_generateDevelopmentActions(province));
      
      // 徴兵行動
      actions.addAll(_generateRecruitmentActions(province));
      
      // 要塞化行動
      actions.addAll(_generateFortificationActions(province));
    }

    return actions;
  }

  /// 攻撃行動を生成
  List<AIAction> _generateAttackActions(Province province, GameState gameState, Faction targetFaction) {
    final actions = <AIAction>[];
    
    // 隣接する敵の州を攻撃対象として考慮
    for (final neighborId in province.neighbors) {
      final neighbor = gameState.provinces[neighborId];
      if (neighbor != null && neighbor.controller != targetFaction) {
        // 攻撃可能性を評価
        final priority = _evaluateAttackPriority(province, neighbor, gameState);
        if (priority > 0) {
          actions.add(AIAction(
            type: AIActionType.attack,
            priority: priority,
            sourceProvinceId: province.id,
            targetProvinceId: neighborId,
          ));
        }
      }
    }
    
    return actions;
  }

  /// 開発行動を生成
  List<AIAction> _generateDevelopmentActions(Province province) {
    final actions = <AIAction>[];
    
    // 各発展タイプについて優先度を計算
    for (final devType in DevelopmentType.values) {
      final priority = _evaluateDevelopmentPriority(province, devType);
      if (priority > 0) {
        actions.add(AIAction(
          type: AIActionType.develop,
          priority: priority,
          sourceProvinceId: province.id,
          developmentType: devType,
        ));
      }
    }
    
    return actions;
  }

  /// 徴兵行動を生成
  List<AIAction> _generateRecruitmentActions(Province province) {
    final actions = <AIAction>[];
    
    // 兵力が不足している場合の優先度を計算
    final priority = _evaluateRecruitmentPriority(province);
    if (priority > 0) {
      actions.add(AIAction(
        type: AIActionType.recruit,
        priority: priority,
        sourceProvinceId: province.id,
      ));
    }
    
    return actions;
  }

  /// 要塞化行動を生成
  List<AIAction> _generateFortificationActions(Province province) {
    final actions = <AIAction>[];
    
    final priority = _evaluateFortificationPriority(province);
    if (priority > 0) {
      actions.add(AIAction(
        type: AIActionType.fortify,
        priority: priority,
        sourceProvinceId: province.id,
      ));
    }
    
    return actions;
  }

  /// 攻撃優先度を評価
  int _evaluateAttackPriority(Province attacker, Province target, GameState gameState) {
    var priority = 0;
    
    // 軍事力の差を考慮
    final militaryDiff = attacker.state.military - target.state.military;
    if (militaryDiff > 20) {
      priority += 30;
    } else if (militaryDiff > 0) {
      priority += 10;
    } else {
      return 0; // 攻撃不可
    }
    
    // 性格による修正
    switch (personality) {
      case AIPersonality.aggressive:
        priority += 20;
        break;
      case AIPersonality.defensive:
        priority -= 10;
        break;
      case AIPersonality.opportunistic:
        if (target.state.security < 30) priority += 15;
        break;
      default:
        break;
    }
    
    // 対象州の価値を考慮
    priority += (target.state.agriculture + target.state.commerce) ~/ 10;
    
    return priority.clamp(0, 100);
  }

  /// 開発優先度を評価
  int _evaluateDevelopmentPriority(Province province, DevelopmentType devType) {
    var priority = 0;
    
    switch (devType) {
      case DevelopmentType.agriculture:
        if (province.state.agriculture < 70) priority += 40;
        if (province.state.agriculture < 50) priority += 20;
        break;
      case DevelopmentType.commerce:
        if (province.state.commerce < 70) priority += 35;
        if (personality == AIPersonality.economic) priority += 15;
        break;
      case DevelopmentType.military:
        if (province.state.military < 60) priority += 30;
        if (personality == AIPersonality.defensive) priority += 15;
        break;
      case DevelopmentType.security:
        if (province.state.security < 60) priority += 25;
        break;
    }
    
    return priority.clamp(0, 100);
  }

  /// 徴兵優先度を評価
  int _evaluateRecruitmentPriority(Province province) {
    var priority = 0;
    
    if (province.garrison < province.state.population * 0.1) {
      priority += 40;
    }
    
    if (personality == AIPersonality.aggressive) {
      priority += 15;
    }
    
    return priority.clamp(0, 100);
  }

  /// 要塞化優先度を評価
  int _evaluateFortificationPriority(Province province) {
    var priority = 0;
    
    // 国境の州は要塞化の優先度が高い
    if (_isBorderProvince(province)) {
      priority += 25;
    }
    
    if (personality == AIPersonality.defensive) {
      priority += 20;
    }
    
    return priority.clamp(0, 100);
  }

  /// 国境の州かどうかを判定
  bool _isBorderProvince(Province province) {
    // 隣接する州に敵対勢力がいるかチェック
    // この実装はgameStateが必要なので簡略化
    return true; // 暫定的にtrueを返す
  }

  /// 最適な行動を選択
  AIAction _selectBestAction(List<AIAction> actions, GameState gameState) {
    if (actions.isEmpty) {
      return const AIAction(
        type: AIActionType.wait,
        priority: 0,
        sourceProvinceId: '',
      );
    }

    // 優先度でソート
    actions.sort((a, b) => b.priority.compareTo(a.priority));
    
    // 性格による最終調整
    return _applyPersonalityBonus(actions, gameState);
  }

  /// 性格による行動選択のボーナス
  AIAction _applyPersonalityBonus(List<AIAction> actions, GameState gameState) {
    final topActions = actions.take(3).toList();
    
    switch (personality) {
      case AIPersonality.aggressive:
        // 攻撃行動を優先
        final attackAction = topActions.firstWhere(
          (a) => a.type == AIActionType.attack,
          orElse: () => topActions.first,
        );
        return attackAction;
        
      case AIPersonality.economic:
        // 開発行動を優先
        final devAction = topActions.firstWhere(
          (a) => a.type == AIActionType.develop,
          orElse: () => topActions.first,
        );
        return devAction;
        
      case AIPersonality.defensive:
        // 要塞化や軍事開発を優先
        final defenseAction = topActions.firstWhere(
          (a) => a.type == AIActionType.fortify || 
                 (a.type == AIActionType.develop && a.developmentType == DevelopmentType.military),
          orElse: () => topActions.first,
        );
        return defenseAction;
        
      default:
        return topActions.first;
    }
  }

  /// 判断理由を生成
  String _generateReasoning(AIAction action, GameState gameState) {
    switch (action.type) {
      case AIActionType.attack:
        return '${action.targetProvinceId}への攻撃が有利と判断';
      case AIActionType.develop:
        return '${action.sourceProvinceId}の${action.developmentType}を開発';
      case AIActionType.recruit:
        return '${action.sourceProvinceId}で兵力を増強';
      case AIActionType.fortify:
        return '${action.sourceProvinceId}の防備を強化';
      case AIActionType.wait:
        return '現在は様子見が最適';
      default:
        return '不明な行動';
    }
  }
}

/// AIシステムファクトリー
class AISystemFactory {
  /// 勢力に応じたAI性格を決定
  static AIPersonality getPersonalityForFaction(String factionId) {
    switch (factionId) {
      case 'imperial_court':
        return AIPersonality.defensive;
      case 'local_lords':
        return AIPersonality.balanced;
      case 'bandits':
        return AIPersonality.aggressive;
      default:
        return AIPersonality.balanced;
    }
  }

  /// AIシステムを作成
  static AISystem createAI(String factionId) {
    return AISystem(
      personality: getPersonalityForFaction(factionId),
      factionId: factionId,
    );
  }
}
