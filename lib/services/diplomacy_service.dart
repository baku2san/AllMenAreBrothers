/// 外交システムサービス
/// 外交行動の処理・条約管理・AI外交ロジック
library;

import '../models/diplomacy_system.dart';
import '../models/water_margin_strategy_game.dart';

/// 外交サービス
class DiplomacyService {
  /// 外交行動を実行
  static DiplomaticResult performDiplomaticAction({
    required DiplomaticSystem diplomacy,
    required Faction targetFaction,
    required DiplomaticAction action,
    Map<String, dynamic>? parameters,
  }) {
    return diplomacy.performAction(targetFaction, action);
  }

  /// AI外交行動を決定
  static DiplomaticAction? decideAIDiplomaticAction(
    DiplomaticSystem diplomacy,
    Faction aiFaction,
  ) {
    // 現在の関係に基づいてAI行動を決定
    final availableFactions = [Faction.imperial, Faction.warlord, Faction.bandit, Faction.neutral];
    
    for (final faction in availableFactions) {
      if (faction == aiFaction) continue;
      
      final relation = diplomacy.getRelationWith(faction);
      if (relation == null) continue;

      // 戦争状態なら和平を検討
      if (relation.relation == DiplomaticRelation.war && relation.trustLevel > 20) {
        return DiplomaticAction.declarePeace;
      }

      // 中立で信頼度が高いなら同盟を検討
      if (relation.relation == DiplomaticRelation.neutral && relation.trustLevel > 60) {
        return DiplomaticAction.requestAlliance;
      }

      // 敵対状態で信頼度が低いなら宣戦布告を検討
      if (relation.relation == DiplomaticRelation.hostile && relation.trustLevel < 30) {
        return DiplomaticAction.declareWar;
      }
    }

    // デフォルトは貿易要請
    return DiplomaticAction.requestTrade;
  }

  /// プレイヤーに利用可能な外交オプションを取得
  static List<DiplomaticAction> getAvailableActions(
    DiplomaticSystem diplomacy,
    Faction targetFaction,
  ) {
    final relation = diplomacy.getRelationWith(targetFaction);
    if (relation == null) return [];

    final actions = <DiplomaticAction>[];

    switch (relation.relation) {
      case DiplomaticRelation.ally:
        actions.addAll([
          DiplomaticAction.requestTrade,
          DiplomaticAction.offerTribute,
        ]);
        break;
      case DiplomaticRelation.neutral:
        actions.addAll([
          DiplomaticAction.requestAlliance,
          DiplomaticAction.requestTrade,
          DiplomaticAction.demandTribute,
          DiplomaticAction.offerTribute,
          DiplomaticAction.declareWar,
        ]);
        break;
      case DiplomaticRelation.hostile:
        actions.addAll([
          DiplomaticAction.declarePeace,
          DiplomaticAction.demandTribute,
          DiplomaticAction.declareWar,
        ]);
        break;
      case DiplomaticRelation.war:
        actions.add(DiplomaticAction.declarePeace);
        break;
    }

    return actions;
  }

  /// 外交行動の説明文を取得
  static String getActionDescription(DiplomaticAction action) {
    switch (action) {
      case DiplomaticAction.requestAlliance:
        return '同盟を要請します（信頼度70以上必要）';
      case DiplomaticAction.declarePeace:
        return '和平を宣言します';
      case DiplomaticAction.declareWar:
        return '宣戦布告します';
      case DiplomaticAction.requestTrade:
        return '貿易協定を要請します';
      case DiplomaticAction.demandTribute:
        return '貢ぎ物を要求します';
      case DiplomaticAction.offerTribute:
        return '貢ぎ物を提供します';
    }
  }
}
