// ...existing code...

/// 経済活動コマンド種別
enum EconomicCommandType {
  tax, // 徴税
  invest, // 投資
  openTrade, // 交易路開設
  buildMarket, // 市場建設
  distributeResource, // 資源分配
}

// Removed unnecessary comment
class EconomicCommand {
  final EconomicCommandType type; // コマンド種別
  final String provinceId; // 対象州ID
  final Map<String, dynamic> params; // コマンド固有パラメータ（税率・投資額など）
  final String? actorId; // 実行者（英雄IDなど、必要なら）

  EconomicCommand({
    required this.type,
    required this.provinceId,
    this.params = const {},
    this.actorId,
  });
}
