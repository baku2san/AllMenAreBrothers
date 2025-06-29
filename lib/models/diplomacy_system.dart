/// 外交システム
/// 勢力間の外交関係と交渉を管理
library;

import '../models/water_margin_strategy_game.dart';

/// 外交関係の種類
enum DiplomaticRelation {
  ally, // 同盟
  neutral, // 中立
  hostile, // 敵対
  war, // 戦争状態
}

/// 外交状態
class DiplomaticState {
  const DiplomaticState({
    required this.relation,
    required this.trustLevel,
    this.lastInteraction,
    this.treatyExpiration,
  });

  final DiplomaticRelation relation;
  final int trustLevel; // 0-100の信頼度
  final DateTime? lastInteraction; // 最後の外交接触
  final DateTime? treatyExpiration; // 条約の期限

  DiplomaticState copyWith({
    DiplomaticRelation? relation,
    int? trustLevel,
    DateTime? lastInteraction,
    DateTime? treatyExpiration,
  }) {
    return DiplomaticState(
      relation: relation ?? this.relation,
      trustLevel: trustLevel ?? this.trustLevel,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      treatyExpiration: treatyExpiration ?? this.treatyExpiration,
    );
  }
}

/// 外交行動の種類
enum DiplomaticAction {
  requestAlliance, // 同盟要請
  declarePeace, // 平和宣言
  declareWar, // 宣戦布告
  requestTrade, // 貿易要請
  demandTribute, // 貢ぎ物要求
  offerTribute, // 貢ぎ物提供
}

/// 外交行動の結果
class DiplomaticResult {
  const DiplomaticResult({
    required this.success,
    required this.message,
    this.newRelation,
    this.trustChange,
  });

  final bool success;
  final String message;
  final DiplomaticRelation? newRelation;
  final int? trustChange;
}

/// 外交システム管理クラス
class DiplomaticSystem {
  DiplomaticSystem({Map<Faction, DiplomaticState>? relationships})
      : _relationships = relationships ?? _initializeDefaultRelationships();

  final Map<Faction, DiplomaticState> _relationships;

  /// プレイヤー（梁山泊）との外交関係を取得
  DiplomaticState? getRelationWith(Faction faction) {
    return _relationships[faction];
  }

  /// 外交関係を更新
  void updateRelation(Faction faction, DiplomaticState newState) {
    _relationships[faction] = newState;
  }

  /// 外交行動を実行
  DiplomaticResult performAction(
    Faction targetFaction,
    DiplomaticAction action,
  ) {
    final currentState = _relationships[targetFaction];
    if (currentState == null) {
      return const DiplomaticResult(
        success: false,
        message: '外交関係が存在しません',
      );
    }

    switch (action) {
      case DiplomaticAction.requestAlliance:
        return _handleAllianceRequest(targetFaction, currentState);
      case DiplomaticAction.declarePeace:
        return _handlePeaceDeclaration(targetFaction, currentState);
      case DiplomaticAction.declareWar:
        return _handleWarDeclaration(targetFaction, currentState);
      case DiplomaticAction.requestTrade:
        return _handleTradeRequest(targetFaction, currentState);
      case DiplomaticAction.demandTribute:
        return _handleTributeDemand(targetFaction, currentState);
      case DiplomaticAction.offerTribute:
        return _handleTributeOffer(targetFaction, currentState);
    }
  }

  /// デフォルトの外交関係を初期化
  static Map<Faction, DiplomaticState> _initializeDefaultRelationships() {
    return {
      Faction.imperial: const DiplomaticState(
        relation: DiplomaticRelation.hostile,
        trustLevel: 10,
      ),
      Faction.warlord: const DiplomaticState(
        relation: DiplomaticRelation.neutral,
        trustLevel: 30,
      ),
      Faction.bandit: const DiplomaticState(
        relation: DiplomaticRelation.neutral,
        trustLevel: 50,
      ),
      Faction.neutral: const DiplomaticState(
        relation: DiplomaticRelation.neutral,
        trustLevel: 60,
      ),
    };
  }

  /// 同盟要請の処理
  DiplomaticResult _handleAllianceRequest(
    Faction faction,
    DiplomaticState currentState,
  ) {
    if (currentState.relation == DiplomaticRelation.war) {
      return const DiplomaticResult(
        success: false,
        message: '戦争中の勢力とは同盟を結べません',
      );
    }

    if (currentState.trustLevel < 70) {
      return DiplomaticResult(
        success: false,
        message: '信頼度が不足しています（現在: ${currentState.trustLevel}）',
      );
    }

    final newState = currentState.copyWith(
      relation: DiplomaticRelation.ally,
      trustLevel: (currentState.trustLevel + 10).clamp(0, 100),
      lastInteraction: DateTime.now(),
      treatyExpiration: DateTime.now().add(const Duration(days: 365)),
    );

    updateRelation(faction, newState);

    return DiplomaticResult(
      success: true,
      message: '${faction.displayName}との同盟が成立しました',
      newRelation: DiplomaticRelation.ally,
      trustChange: 10,
    );
  }

  /// 平和宣言の処理
  DiplomaticResult _handlePeaceDeclaration(
    Faction faction,
    DiplomaticState currentState,
  ) {
    if (currentState.relation != DiplomaticRelation.war) {
      return const DiplomaticResult(
        success: false,
        message: '戦争状態ではありません',
      );
    }

    final newState = currentState.copyWith(
      relation: DiplomaticRelation.neutral,
      trustLevel: (currentState.trustLevel + 5).clamp(0, 100),
      lastInteraction: DateTime.now(),
    );

    updateRelation(faction, newState);

    return DiplomaticResult(
      success: true,
      message: '${faction.displayName}との停戦が成立しました',
      newRelation: DiplomaticRelation.neutral,
      trustChange: 5,
    );
  }

  /// 宣戦布告の処理
  DiplomaticResult _handleWarDeclaration(
    Faction faction,
    DiplomaticState currentState,
  ) {
    final newState = currentState.copyWith(
      relation: DiplomaticRelation.war,
      trustLevel: (currentState.trustLevel - 20).clamp(0, 100),
      lastInteraction: DateTime.now(),
    );

    updateRelation(faction, newState);

    return DiplomaticResult(
      success: true,
      message: '${faction.displayName}に宣戦布告しました',
      newRelation: DiplomaticRelation.war,
      trustChange: -20,
    );
  }

  /// 貿易要請の処理
  DiplomaticResult _handleTradeRequest(
    Faction faction,
    DiplomaticState currentState,
  ) {
    if (currentState.relation == DiplomaticRelation.war) {
      return const DiplomaticResult(
        success: false,
        message: '戦争中の勢力とは貿易できません',
      );
    }

    final success = currentState.trustLevel >= 40;
    if (success) {
      final newState = currentState.copyWith(
        trustLevel: (currentState.trustLevel + 5).clamp(0, 100),
        lastInteraction: DateTime.now(),
      );
      updateRelation(faction, newState);
    }

    return DiplomaticResult(
      success: success,
      message: success 
          ? '${faction.displayName}との貿易協定が成立しました'
          : '貿易協定は拒否されました',
      trustChange: success ? 5 : 0,
    );
  }

  /// 貢ぎ物要求の処理
  DiplomaticResult _handleTributeDemand(
    Faction faction,
    DiplomaticState currentState,
  ) {
    final success = currentState.trustLevel <= 30 && 
                   currentState.relation != DiplomaticRelation.ally;
    
    if (success) {
      final newState = currentState.copyWith(
        trustLevel: (currentState.trustLevel - 10).clamp(0, 100),
        lastInteraction: DateTime.now(),
      );
      updateRelation(faction, newState);
    }

    return DiplomaticResult(
      success: success,
      message: success
          ? '${faction.displayName}が貢ぎ物を送ってきました'
          : '貢ぎ物の要求は拒否されました',
      trustChange: success ? -10 : 0,
    );
  }

  /// 貢ぎ物提供の処理
  DiplomaticResult _handleTributeOffer(
    Faction faction,
    DiplomaticState currentState,
  ) {
    final newState = currentState.copyWith(
      trustLevel: (currentState.trustLevel + 15).clamp(0, 100),
      lastInteraction: DateTime.now(),
    );

    updateRelation(faction, newState);

    return DiplomaticResult(
      success: true,
      message: '${faction.displayName}への贈り物が好感を持たれました',
      trustChange: 15,
    );
  }

  /// 全ての外交関係を取得
  Map<Faction, DiplomaticState> get allRelationships => 
      Map.unmodifiable(_relationships);

  /// 同盟国の一覧を取得
  List<Faction> get allies => _relationships.entries
      .where((entry) => entry.value.relation == DiplomaticRelation.ally)
      .map((entry) => entry.key)
      .toList();

  /// 敵対勢力の一覧を取得
  List<Faction> get enemies => _relationships.entries
      .where((entry) => entry.value.relation == DiplomaticRelation.war)
      .map((entry) => entry.key)
      .toList();
}
