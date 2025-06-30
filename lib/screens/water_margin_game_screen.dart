/// 水滸伝戦略ゲーム - Providerパターン対応メイン画面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../widgets/game_map_widget.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/province_detail_panel.dart';
import '../widgets/battle_result_dialog.dart';
import '../widgets/game_command_bar.dart';
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
        shadowColor: AppColors.darkGreen.withValues(alpha: 0.5),
        actions: [
          Consumer<WaterMarginGameController>(
            builder: (context, controller, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
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
                  color: AppColors.info.withValues(alpha: 0.2),
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
          // 戦闘結果ダイアログの自動表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.lastBattleResult != null) {
              _showBattleResultDialog(context, controller);
            }
          });

          return Row(
            children: [
              // メインマップ領域
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // マップ
                    Expanded(
                      child: Column(
                        children: [
                          // マップ表示
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

                          // マップ凡例
                          if (controller.selectedProvince != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: const Border(top: BorderSide(color: Colors.grey)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildLegendItem('選択中', Colors.yellow, Icons.location_on),
                                  _buildLegendItem('隣接州', Colors.blue, Icons.link),
                                  _buildLegendItem('攻撃可能', Colors.red, Icons.gps_fixed),
                                  _buildLegendItem('味方州', AppColors.primaryGreen, Icons.flag),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 統一コマンドバー
                    const GameCommandBar(),
                  ],
                ),
              ),

              // サイドバー
              SizedBox(
                width: AppConstants.sidebarWidth,
                child: Column(
                  children: [
                    // ゲーム情報パネル
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                      ),
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
                              controller: controller,
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

  /// 凡例アイテムを構築
  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            border: Border.all(color: color.withValues(alpha: 0.9)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 戦闘結果ダイアログを表示
  void _showBattleResultDialog(BuildContext context, WaterMarginGameController controller) {
    final battleResult = controller.lastBattleResult;
    if (battleResult == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BattleResultDialog(
        result: battleResult.result,
        attackerProvinceName: battleResult.sourceProvinceName,
        defenderProvinceName: battleResult.targetProvinceName,
      ),
    ).then((_) {
      // ダイアログが閉じられたら戦闘結果をクリア
      controller.clearBattleResult();
    });
  }
}
