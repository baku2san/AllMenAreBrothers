import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';
import '../models/economic_command.dart';
import '../services/economic_command_service.dart';
import '../models/province.dart';

/// 州詳細画面（経済コマンド実行UI付き）
class ProvinceDetailScreen extends StatefulWidget {
  final Province province;
  final WaterMarginGameState gameState;
  final void Function(WaterMarginGameState) onGameStateUpdated;

  const ProvinceDetailScreen({
    super.key,
    required this.province,
    required this.gameState,
    required this.onGameStateUpdated,
  });

  @override
  State<ProvinceDetailScreen> createState() => _ProvinceDetailScreenState();
}

class _ProvinceDetailScreenState extends State<ProvinceDetailScreen> {
  final EconomicCommandService _service = EconomicCommandService();

  void _executeCommand(EconomicCommandType type, {Map<String, dynamic> params = const {}}) {
    final command = EconomicCommand(
      type: type,
      provinceId: widget.province.name,
      params: params,
    );
    final newState = _service.execute(widget.gameState, command);
    widget.onGameStateUpdated(newState);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.province;
    return Scaffold(
      appBar: AppBar(title: Text('${p.name} 詳細')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('人口: ${p.population}'),
            Text('農業度: ${p.agriculture}'),
            Text('商業度: ${p.commerce}'),
            Text('治安: ${p.security}'),
            Text('民心: ${p.publicSupport}'),
            Text('軍事力: ${p.military}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _executeCommand(EconomicCommandType.tax),
                  child: const Text('徴税'),
                ),
                ElevatedButton(
                  onPressed: () => _executeCommand(EconomicCommandType.invest, params: {'amount': 20}),
                  child: const Text('投資'),
                ),
                ElevatedButton(
                  onPressed: () => _executeCommand(EconomicCommandType.openTrade),
                  child: const Text('交易路開設'),
                ),
                ElevatedButton(
                  onPressed: () => _executeCommand(EconomicCommandType.buildMarket),
                  child: const Text('市場建設'),
                ),
                ElevatedButton(
                  onPressed: () => _executeCommand(EconomicCommandType.distributeResource),
                  child: const Text('資源分配'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
