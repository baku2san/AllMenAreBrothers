/// 外交システムサービス
/// 外交行動の処理・条約管理・AI外交ロジック
library;

import '../models/diplomacy_system.dart';
import '../models/water_margin_strategy_game.dart';

/// 外交行動の結果
class DiplomaticResult {
  const DiplomaticResult({
    required this.success,
    required this.message,
    this.relationChange = 0,
    this.goldCost = 0,
  });

  final bool success;
  final String message;
  final int relationChange;
  final int goldCost;
}

/// 外交サービス
class DiplomacyService {
  /// 外交行動を実行
  static DiplomaticResult performDiplomaticAction({
    required DiplomacySystem diplomacy,
    required Faction fromFaction,
    required Faction targetFaction,
    required DiplomaticAction action,
    Map<String, dynamic>? parameters,
  }) {
    final successRate = diplomacy.calculateSuccessRate(fromFaction, targetFaction, action);
    final isSuccess = (parameters?['random'] ?? 0.5) < successRate;

    return DiplomaticResult(
      success: isSuccess,
      message: isSuccess ? '${action.displayName}が成功しました' : '${action.displayName}が失敗しました',
      relationChange: isSuccess ? action.relationChange : (action.relationChange * 0.2).round(),
      goldCost: action.cost,
    );
  }

  /// AI外交行動を決定
  static DiplomaticAction? decideAIDiplomaticAction(
    DiplomacySystem diplomacy,
    Faction aiFaction,
  ) {
    // 現在の関係に基づいてAI行動を決定
    final availableFactions = [Faction.imperial, Faction.warlord, Faction.bandit, Faction.neutral];

    for (final faction in availableFactions) {
      if (faction == aiFaction) continue;

      final relationLevel = diplomacy.getRelationLevel(aiFaction, faction);
      final relationValue = diplomacy.getRelation(aiFaction, faction);

      // 敵対状態で関係値がやや高いなら和平を検討
      if (relationLevel == DiplomaticRelation.hostile && relationValue > -50) {
        return DiplomaticAction.declarePeace;
      }

      // 中立で関係値が高いなら同盟を検討
      if (relationLevel == DiplomaticRelation.neutral && relationValue > 30) {
        return DiplomaticAction.requestAlliance;
      }

      // 友好状態なら貿易を検討
      if (relationLevel == DiplomaticRelation.friendly) {
        return DiplomaticAction.requestTrade;
      }
    }

    // デフォルトは貿易要請
    return DiplomaticAction.requestTrade;
  }

  /// プレイヤーに利用可能な外交オプションを取得
  static List<DiplomaticAction> getAvailableActions(
    DiplomacySystem diplomacy,
    Faction fromFaction,
    Faction targetFaction,
  ) {
    final relationLevel = diplomacy.getRelationLevel(fromFaction, targetFaction);
    final actions = <DiplomaticAction>[];

    switch (relationLevel) {
      case DiplomaticRelation.allied:
        actions.addAll([
          DiplomaticAction.requestTrade,
          DiplomaticAction.sendGift,
        ]);
        break;
      case DiplomaticRelation.friendly:
        actions.addAll([
          DiplomaticAction.requestAlliance,
          DiplomaticAction.requestTrade,
          DiplomaticAction.sendGift,
        ]);
        break;
      case DiplomaticRelation.neutral:
        actions.addAll([
          DiplomaticAction.requestAlliance,
          DiplomaticAction.requestTrade,
          DiplomaticAction.sendGift,
          DiplomaticAction.demandTribute,
        ]);
        break;
      case DiplomaticRelation.unfriendly:
        actions.addAll([
          DiplomaticAction.declarePeace,
          DiplomaticAction.sendGift,
          DiplomaticAction.threaten,
        ]);
        break;
      case DiplomaticRelation.hostile:
        actions.addAll([
          DiplomaticAction.declarePeace,
          DiplomaticAction.threaten,
        ]);
        break;
    }

    return actions;
  }

  /// 外交行動のコストを計算
  static int calculateActionCost(DiplomaticAction action) {
    return action.cost;
  }

  /// 外交行動の効果を説明
  static String getActionDescription(DiplomaticAction action) {
    switch (action) {
      case DiplomaticAction.requestAlliance:
        return '${action.displayName}: 軍事同盟を結び、戦争時に互いに支援します。関係値+${action.relationChange}';
      case DiplomaticAction.declarePeace:
        return '${action.displayName}: 敵対関係を終了し、平和を宣言します。関係値+${action.relationChange}';
      case DiplomaticAction.requestTrade:
        return '${action.displayName}: 貿易協定を結び、経済的利益を得ます。関係値+${action.relationChange}';
      case DiplomaticAction.demandTribute:
        return '${action.displayName}: 相手に貢ぎ物を要求します。関係値${action.relationChange}';
      case DiplomaticAction.sendGift:
        return '${action.displayName}: 友好の証として贈り物を送ります。関係値+${action.relationChange}';
      case DiplomaticAction.threaten:
        return '${action.displayName}: 相手を威嚇し、従属を求めます。関係値${action.relationChange}';
    }
  }
}
