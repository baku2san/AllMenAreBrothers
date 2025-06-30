/// 水滸伝戦略ゲーム - 包括的外交システム
/// 同盟、貿易、外交関係の管理
library;

import '../models/water_margin_strategy_game.dart';

/// 外交関係の種類
enum DiplomaticRelation {
  hostile(-100, '敵対'), // 敵対関係
  unfriendly(-50, '非友好'), // 非友好
  neutral(0, '中立'), // 中立
  friendly(50, '友好'), // 友好
  allied(100, '同盟'); // 同盟

  const DiplomaticRelation(this.value, this.displayName);
  final int value;
  final String displayName;
}

/// 外交協定の種類
enum TreatyType {
  nonAggression('不可侵条約', 500, 10), // 不可侵条約
  tradeAgreement('貿易協定', 800, 15), // 貿易協定
  militaryAlliance('軍事同盟', 1500, 25), // 軍事同盟
  vassalage('従属条約', 2000, 30); // 従属条約

  const TreatyType(this.displayName, this.cost, this.duration);
  final String displayName;
  final int cost;
  final int duration; // ターン数
}

/// 外交行動の種類
enum DiplomaticAction {
  requestAlliance('同盟要請', 1000, 50), // 同盟要請
  declarePeace('平和宣言', 300, 20), // 平和宣言
  requestTrade('貿易要請', 500, 30), // 貿易要請
  demandTribute('貢ぎ物要求', 200, -30), // 貢ぎ物要求
  sendGift('贈り物', 400, 25), // 贈り物
  threaten('威嚇', 100, -40); // 威嚇

  const DiplomaticAction(this.displayName, this.cost, this.relationChange);
  final String displayName;
  final int cost;
  final int relationChange;
}

/// 外交協定
class Treaty {
  const Treaty({
    required this.id,
    required this.type,
    required this.faction1,
    required this.faction2,
    required this.startTurn,
    required this.duration,
    this.isActive = true,
    this.additionalTerms = const [],
  });

  final String id;
  final TreatyType type;
  final Faction faction1;
  final Faction faction2;
  final int startTurn;
  final int duration;
  final bool isActive;
  final List<String> additionalTerms;

  /// 協定が有効かチェック
  bool isValidAt(int currentTurn) {
    return isActive && (currentTurn - startTurn) < duration;
  }

  /// 残り期間
  int remainingTurns(int currentTurn) {
    final remaining = duration - (currentTurn - startTurn);
    return remaining > 0 ? remaining : 0;
  }

  /// コピーウィズ
  Treaty copyWith({
    String? id,
    TreatyType? type,
    Faction? faction1,
    Faction? faction2,
    int? startTurn,
    int? duration,
    bool? isActive,
    List<String>? additionalTerms,
  }) {
    return Treaty(
      id: id ?? this.id,
      type: type ?? this.type,
      faction1: faction1 ?? this.faction1,
      faction2: faction2 ?? this.faction2,
      startTurn: startTurn ?? this.startTurn,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      additionalTerms: additionalTerms ?? this.additionalTerms,
    );
  }

  /// JSON変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'faction1': faction1.name,
      'faction2': faction2.name,
      'startTurn': startTurn,
      'duration': duration,
      'isActive': isActive,
      'additionalTerms': additionalTerms,
    };
  }

  /// JSONから作成
  factory Treaty.fromJson(Map<String, dynamic> json) {
    return Treaty(
      id: json['id'] ?? '',
      type: TreatyType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TreatyType.nonAggression,
      ),
      faction1: Faction.values.firstWhere(
        (f) => f.name == json['faction1'],
        orElse: () => Faction.neutral,
      ),
      faction2: Faction.values.firstWhere(
        (f) => f.name == json['faction2'],
        orElse: () => Faction.neutral,
      ),
      startTurn: json['startTurn'] ?? 1,
      duration: json['duration'] ?? 10,
      isActive: json['isActive'] ?? true,
      additionalTerms: List<String>.from(json['additionalTerms'] ?? []),
    );
  }
}

/// 貿易ルート
class TradeRoute {
  const TradeRoute({
    required this.id,
    required this.sourceProvinceId,
    required this.targetProvinceId,
    required this.goldPerTurn,
    required this.startTurn,
    this.isActive = true,
  });

  final String id;
  final String sourceProvinceId;
  final String targetProvinceId;
  final int goldPerTurn;
  final int startTurn;
  final bool isActive;

  /// コピーウィズ
  TradeRoute copyWith({
    String? id,
    String? sourceProvinceId,
    String? targetProvinceId,
    int? goldPerTurn,
    int? startTurn,
    bool? isActive,
  }) {
    return TradeRoute(
      id: id ?? this.id,
      sourceProvinceId: sourceProvinceId ?? this.sourceProvinceId,
      targetProvinceId: targetProvinceId ?? this.targetProvinceId,
      goldPerTurn: goldPerTurn ?? this.goldPerTurn,
      startTurn: startTurn ?? this.startTurn,
      isActive: isActive ?? this.isActive,
    );
  }

  /// JSON変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceProvinceId': sourceProvinceId,
      'targetProvinceId': targetProvinceId,
      'goldPerTurn': goldPerTurn,
      'startTurn': startTurn,
      'isActive': isActive,
    };
  }

  /// JSONから作成
  factory TradeRoute.fromJson(Map<String, dynamic> json) {
    return TradeRoute(
      id: json['id'] ?? '',
      sourceProvinceId: json['sourceProvinceId'] ?? '',
      targetProvinceId: json['targetProvinceId'] ?? '',
      goldPerTurn: json['goldPerTurn'] ?? 0,
      startTurn: json['startTurn'] ?? 1,
      isActive: json['isActive'] ?? true,
    );
  }
}

/// 外交システム管理クラス
class DiplomacySystem {
  const DiplomacySystem({
    this.relations = const {},
    this.treaties = const [],
    this.tradeRoutes = const [],
  });

  final Map<String, int> relations; // "faction1-faction2" => 関係値
  final List<Treaty> treaties;
  final List<TradeRoute> tradeRoutes;

  /// 二つの勢力間の関係値を取得
  int getRelation(Faction faction1, Faction faction2) {
    if (faction1 == faction2) return 100;

    final key1 = '${faction1.name}-${faction2.name}';
    final key2 = '${faction2.name}-${faction1.name}';

    return relations[key1] ?? relations[key2] ?? 0;
  }

  /// 外交関係を設定
  DiplomacySystem setRelation(Faction faction1, Faction faction2, int value) {
    final key = '${faction1.name}-${faction2.name}';
    final newRelations = Map<String, int>.from(relations);
    newRelations[key] = value.clamp(-100, 100);

    return copyWith(relations: newRelations);
  }

  /// 外交関係のレベルを取得
  DiplomaticRelation getRelationLevel(Faction faction1, Faction faction2) {
    final value = getRelation(faction1, faction2);

    if (value >= 80) return DiplomaticRelation.allied;
    if (value >= 30) return DiplomaticRelation.friendly;
    if (value >= -30) return DiplomaticRelation.neutral;
    if (value >= -70) return DiplomaticRelation.unfriendly;
    return DiplomaticRelation.hostile;
  }

  /// 有効な協定を取得
  List<Treaty> getActiveTreaties(int currentTurn) {
    return treaties.where((treaty) => treaty.isValidAt(currentTurn)).toList();
  }

  /// 勢力間の協定を検索
  Treaty? getTreaty(Faction faction1, Faction faction2, TreatyType type, int currentTurn) {
    try {
      return treaties.firstWhere(
        (treaty) =>
            treaty.isValidAt(currentTurn) &&
            treaty.type == type &&
            ((treaty.faction1 == faction1 && treaty.faction2 == faction2) ||
                (treaty.faction1 == faction2 && treaty.faction2 == faction1)),
      );
    } catch (e) {
      return null;
    }
  }

  /// 協定が存在するかチェック
  bool hasTreaty(Faction faction1, Faction faction2, TreatyType type, int currentTurn) {
    return getTreaty(faction1, faction2, type, currentTurn) != null;
  }

  /// 協定を追加
  DiplomacySystem addTreaty(Treaty treaty) {
    return copyWith(treaties: [...treaties, treaty]);
  }

  /// 貿易ルートを追加
  DiplomacySystem addTradeRoute(TradeRoute route) {
    return copyWith(tradeRoutes: [...tradeRoutes, route]);
  }

  /// アクティブな貿易ルートを取得
  List<TradeRoute> getActiveTradeRoutes() {
    return tradeRoutes.where((route) => route.isActive).toList();
  }

  /// 州の貿易ルートを取得
  List<TradeRoute> getProvinceTradeRoutes(String provinceId) {
    return tradeRoutes
        .where(
            (route) => route.isActive && (route.sourceProvinceId == provinceId || route.targetProvinceId == provinceId))
        .toList();
  }

  /// ターン毎の貿易収入を計算
  int calculateTradeIncome(String provinceId) {
    return getProvinceTradeRoutes(provinceId)
        .where((route) => route.sourceProvinceId == provinceId)
        .fold(0, (sum, route) => sum + route.goldPerTurn);
  }

  /// 外交行動の成功率を計算
  double calculateSuccessRate(Faction faction1, Faction faction2, DiplomaticAction action) {
    final currentRelation = getRelation(faction1, faction2);
    final baseRate = 0.3; // 基本成功率30%

    // 関係値による修正
    final relationModifier = (currentRelation + 100) / 200; // 0.0～1.0

    // 行動による修正
    double actionModifier = 1.0;
    switch (action) {
      case DiplomaticAction.requestAlliance:
        actionModifier = currentRelation >= 50 ? 1.5 : 0.5;
        break;
      case DiplomaticAction.declarePeace:
        actionModifier = 1.2;
        break;
      case DiplomaticAction.requestTrade:
        actionModifier = currentRelation >= 0 ? 1.3 : 0.7;
        break;
      case DiplomaticAction.sendGift:
        actionModifier = 1.8;
        break;
      case DiplomaticAction.demandTribute:
        actionModifier = currentRelation >= 50 ? 0.8 : 0.3;
        break;
      case DiplomaticAction.threaten:
        actionModifier = 0.6;
        break;
    }

    return (baseRate * relationModifier * actionModifier).clamp(0.05, 0.95);
  }

  /// コピーウィズ
  DiplomacySystem copyWith({
    Map<String, int>? relations,
    List<Treaty>? treaties,
    List<TradeRoute>? tradeRoutes,
  }) {
    return DiplomacySystem(
      relations: relations ?? this.relations,
      treaties: treaties ?? this.treaties,
      tradeRoutes: tradeRoutes ?? this.tradeRoutes,
    );
  }

  /// JSON変換
  Map<String, dynamic> toJson() {
    return {
      'relations': relations,
      'treaties': treaties.map((t) => t.toJson()).toList(),
      'tradeRoutes': tradeRoutes.map((r) => r.toJson()).toList(),
    };
  }

  /// JSONから作成
  factory DiplomacySystem.fromJson(Map<String, dynamic> json) {
    return DiplomacySystem(
      relations: Map<String, int>.from(json['relations'] ?? {}),
      treaties: (json['treaties'] as List? ?? []).map((t) => Treaty.fromJson(t)).toList(),
      tradeRoutes: (json['tradeRoutes'] as List? ?? []).map((r) => TradeRoute.fromJson(r)).toList(),
    );
  }

  /// デフォルトの外交関係で初期化
  factory DiplomacySystem.withDefaults() {
    final Map<String, int> defaultRelations = {
      '${Faction.liangshan.name}-${Faction.imperial.name}': -80,
      '${Faction.liangshan.name}-${Faction.warlord.name}': -20,
      '${Faction.liangshan.name}-${Faction.bandit.name}': 20,
      '${Faction.liangshan.name}-${Faction.neutral.name}': 0,
      '${Faction.imperial.name}-${Faction.warlord.name}': 40,
      '${Faction.imperial.name}-${Faction.bandit.name}': -90,
      '${Faction.imperial.name}-${Faction.neutral.name}': 10,
      '${Faction.warlord.name}-${Faction.bandit.name}': -30,
      '${Faction.warlord.name}-${Faction.neutral.name}': 0,
      '${Faction.bandit.name}-${Faction.neutral.name}': -10,
    };

    return DiplomacySystem(relations: defaultRelations);
  }
}
