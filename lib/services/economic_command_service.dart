import '../models/economic_command.dart';
import '../models/water_margin_strategy_game.dart';

/// 経済活動コマンドの実行サービス
/// コマンド種別ごとに州のパラメータを更新
class EconomicCommandService {
  /// コマンドを実行し、ゲーム状態を更新
  WaterMarginGameState execute(
    WaterMarginGameState gameState,
    EconomicCommand command,
  ) {
    final province = gameState.provinces[command.provinceId];
    if (province == null) return gameState;

    ProvinceState newState = province.state;
    switch (command.type) {
      case EconomicCommandType.tax:
        // 徴税: 税収分だけ資金増加（仮: playerGold加算）
        // 税収コマンド（資金加算は今後拡張）
        break;
      case EconomicCommandType.invest:
        // 投資: 発展度増加
        final investAmount = (command.params['amount'] ?? 10);
        newState = newState.copyWith(
          agriculture: (newState.agriculture +
              (investAmount is int ? investAmount : int.tryParse(investAmount.toString()) ?? 0)),
          commerce:
              (newState.commerce + (investAmount is int ? investAmount : int.tryParse(investAmount.toString()) ?? 0)),
        );
        break;
      case EconomicCommandType.openTrade:
        // 交易路開設: 商業度増加
        newState = newState.copyWith(
          commerce: newState.commerce + 5,
        );
        break;
      case EconomicCommandType.buildMarket:
        // 市場建設: 商業度・発展度増加
        newState = newState.copyWith(
          commerce: newState.commerce + 8,
        );
        break;
      case EconomicCommandType.distributeResource:
        // 資源分配: 民心増加
        newState = newState.copyWith(
          loyalty: (newState.loyalty + 5).clamp(0, 100),
        );
        break;
    }

    // 州の新しい状態で更新
    final newProvince = province.copyWith(state: newState);
    final newProvinces = Map<String, Province>.from(gameState.provinces);
    newProvinces[province.id] = newProvince;

    // 新しいゲーム状態を返す（資金増加などは省略）
    return gameState.copyWith(provinces: newProvinces);
  }
}
