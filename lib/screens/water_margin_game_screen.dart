/// 水滸伝戦略ゲーム - Providerパターン対応メイン画面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../models/water_margin_strategy_game.dart';
import '../widgets/game_map_widget.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/province_detail_panel.dart';
import '../core/app_config.dart';

/// 水滸伝戦略ゲームのメイン画面
class WaterMarginGameScreen extends StatelessWidget {
  const WaterMarginGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WaterMarginGameController()..initializeGame(),
      child: const _WaterMarginGameView(),
    );
  }
}

class _WaterMarginGameView extends StatelessWidget {
  const _WaterMarginGameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppColors.darkGreen.withOpacity(0.5),
        actions: [
          Consumer<WaterMarginGameController>(
            builder: (context, controller, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentGold, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on, 
                      color: AppColors.accentGold,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.gameState.playerGold}両',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Consumer<WaterMarginGameController>(
            builder: (context, controller, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.info,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ターン${controller.gameState.currentTurn}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<WaterMarginGameController>(
        builder: (context, controller, child) {
          return Row(
            children: [
              // メインマップ領域
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // マップ
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.brown),
                        ),
                        child: GameMapWidget(
                          gameState: controller.gameState,
                          onProvinceSelected: controller.selectProvince,
                        ),
                      ),
                    ),
                    
                    // 操作ボタン
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: const Border(top: BorderSide(color: Colors.grey)),
                      ),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: controller.gameState.gameStatus == GameStatus.playing
                                ? controller.endTurn
                                : null,
                            icon: const Icon(Icons.skip_next),
                            label: const Text('ターン終了'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: controller.clearSelection,
                            icon: const Icon(Icons.clear),
                            label: const Text('選択解除'),
                          ),
                          const Spacer(),
                          Text(
                            '総兵力: ${controller.getTotalTroops()}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '総収入: ${controller.getTotalIncome()}両/ターン',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 右サイドパネル
              Container(
                width: 300,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey)),
                ),
                child: Column(
                  children: [
                    // ゲーム情報パネル
                    Expanded(
                      flex: 1,
                      child: GameInfoPanel(
                        gameState: controller.gameState,
                        onEndTurn: controller.endTurn,
                      ),
                    ),
                    
                    // 州詳細パネル
                    Expanded(
                      flex: 2,
                      child: controller.selectedProvince != null
                          ? ProvinceDetailPanel(
                              province: controller.selectedProvince!,
                              gameState: controller.gameState,
                            )
                          : const Center(
                              child: Text(
                                '州を選択してください',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                    
                    // イベントログ
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                color: Colors.brown,
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.history, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'イベントログ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                reverse: true,
                                itemCount: controller.eventLog.length,
                                itemBuilder: (context, index) {
                                  final event = controller.eventLog[controller.eventLog.length - 1 - index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                                    ),
                                    child: Text(
                                      event,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
