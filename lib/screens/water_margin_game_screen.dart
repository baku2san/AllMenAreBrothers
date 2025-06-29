/// 水滸伝戦略ゲーム - Providerパターン対応メイン画面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../models/water_margin_strategy_game.dart';
import '../services/game_save_service.dart';
import '../widgets/game_map_widget.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/province_detail_panel.dart';
import '../widgets/battle_result_dialog.dart';
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  controller.gameState.gameStatus == GameStatus.playing ? controller.endTurn : null,
                              icon: const Icon(Icons.skip_next),
                              label: const Text('ターン終了'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: controller.selectedProvince != null &&
                                      controller.selectedProvince!.controller == Faction.liangshan
                                  ? () => controller.developProvince(
                                      controller.selectedProvince!.id, DevelopmentType.agriculture)
                                  : null,
                              icon: const Icon(Icons.build),
                              label: const Text('農業開発'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showSaveDialog(context, controller),
                              icon: const Icon(Icons.save),
                              label: const Text('セーブ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showLoadDialog(context, controller),
                              icon: const Icon(Icons.folder_open),
                              label: const Text('ロード'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => controller.initializeGame(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('新規ゲーム'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

  /// セーブダイアログを表示
  void _showSaveDialog(BuildContext context, WaterMarginGameController controller) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ゲームデータ保存'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('セーブファイル名を入力してください：'),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: '例: セーブデータ1',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final saveName = nameController.text.trim();
              if (saveName.isNotEmpty) {
                final success = await controller.saveGame(saveName: saveName);
                if (context.mounted) {
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'セーブが完了しました' : 'セーブに失敗しました'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// ロードダイアログを表示
  void _showLoadDialog(BuildContext context, WaterMarginGameController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ゲームデータ読込'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: FutureBuilder<List<SaveFileInfo>>(
            future: controller.getSaveList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('エラーが発生しました'));
              }

              final saveFiles = snapshot.data ?? [];

              if (saveFiles.isEmpty) {
                return const Center(child: Text('セーブファイルがありません'));
              }

              return ListView.builder(
                itemCount: saveFiles.length,
                itemBuilder: (context, index) {
                  final saveFile = saveFiles[index];
                  return ListTile(
                    title: Text(saveFile.saveName),
                    subtitle: Text(saveFile.formattedTime),
                    trailing: Text('ターン${saveFile.turn}'),
                    onTap: () async {
                      final success = await controller.loadGame(saveFile.saveName);
                      if (context.mounted) {
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'ロードが完了しました' : 'ロードに失敗しました'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await controller.loadAutoSave();
              if (context.mounted) {
                Navigator.of(context).pop();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('オートセーブデータをロードしました'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('オートセーブデータがありません'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            child: const Text('オートセーブ'),
          ),
        ],
      ),
    );
  }
}
