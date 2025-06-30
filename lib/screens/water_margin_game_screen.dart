/// 水滸伝戦略ゲーム - Providerパターン対応メイン画面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../widgets/game_map_widget.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/province_detail_panel.dart';
import '../widgets/battle_result_dialog.dart';
import '../widgets/game_command_bar_modern.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Container(
          padding: ModernSpacing.horizontalMD,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: ModernSpacing.paddingXS,
                decoration: ModernDecorations.goldAccent(colorScheme),
                child: Icon(
                  Icons.castle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppConstants.appName,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        centerTitle: true,
        actions: [
          Consumer<WaterMarginGameController>(
            builder: (context, controller, child) {
              return Container(
                padding: ModernSpacing.paddingMD,
                margin: const EdgeInsets.only(right: 8),
                decoration: ModernDecorations.goldAccent(colorScheme),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.gameState.playerGold}両',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer<WaterMarginGameController>(
            builder: (context, controller, child) {
              return Container(
                padding: ModernSpacing.paddingMD,
                margin: const EdgeInsets.only(right: 16),
                decoration: ModernDecorations.primaryContainer(colorScheme),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ターン${controller.gameState.currentTurn}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
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
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          // 戦闘結果ダイアログの自動表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.lastBattleResult != null) {
              _showBattleResultDialog(context, controller);
            }
          });

          return Container(
            decoration: ModernDecorations.surfaceBackground(colorScheme),
            child: Row(
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
                                margin: ModernSpacing.paddingMD,
                                decoration: ModernDecorations.elevatedCard(colorScheme),
                                child: ClipRRect(
                                  borderRadius: ModernRadius.mdRadius,
                                  child: GameMapWidget(
                                    gameState: controller.gameState,
                                    onProvinceSelected: controller.selectProvince,
                                  ),
                                ),
                              ),
                            ),

                            // マップ凡例（より洗練されたデザイン）
                            if (controller.selectedProvince != null)
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                  ModernSpacing.md,
                                  0,
                                  ModernSpacing.md,
                                  ModernSpacing.md,
                                ),
                                decoration: ModernDecorations.card(colorScheme),
                                child: Padding(
                                  padding: ModernSpacing.paddingMD,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildLegendItem(
                                          '選択中', AppColors.accentGold, Icons.location_on_rounded, colorScheme),
                                      _buildLegendItem('隣接州', colorScheme.tertiary, Icons.link_rounded, colorScheme),
                                      _buildLegendItem('攻撃可能', colorScheme.error, Icons.gps_fixed_rounded, colorScheme),
                                      _buildLegendItem('味方州', colorScheme.primary, Icons.flag_rounded, colorScheme),
                                    ],
                                  ),
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

                // サイドバー（モダンデザイン）
                Container(
                  width: AppConstants.sidebarWidth,
                  margin: ModernSpacing.paddingMD,
                  decoration: ModernDecorations.elevatedCard(colorScheme),
                  child: ClipRRect(
                    borderRadius: ModernRadius.mdRadius,
                    child: Column(
                      children: [
                        // ゲーム情報パネル（改良版）
                        Container(
                          height: 200,
                          decoration: ModernDecorations.primaryContainer(colorScheme),
                          child: GameInfoPanel(
                            gameState: controller.gameState,
                            onEndTurn: controller.endTurn,
                          ),
                        ),

                        // 州詳細パネル（改良版）
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              border: Border(
                                bottom: BorderSide(
                                  color: colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                            child: controller.selectedProvince != null
                                ? ProvinceDetailPanel(
                                    province: controller.selectedProvince!,
                                    gameState: controller.gameState,
                                    controller: controller,
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: ModernSpacing.paddingXL,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.touch_app_rounded,
                                            size: 48,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '州を選択してください',
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),

                        // イベントログ（改良版）
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Container(
                                padding: ModernSpacing.paddingMD,
                                decoration: ModernDecorations.secondaryContainer(colorScheme),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: ModernSpacing.paddingXS,
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondary,
                                        borderRadius: ModernRadius.smRadius,
                                      ),
                                      child: Icon(
                                        Icons.history_rounded,
                                        color: colorScheme.onSecondary,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'イベントログ',
                                      style: AppTextStyles.titleSmall.copyWith(
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  reverse: true,
                                  padding: ModernSpacing.paddingXS,
                                  itemCount: controller.eventLog.length,
                                  itemBuilder: (context, index) {
                                    final event = controller.eventLog[controller.eventLog.length - 1 - index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 2),
                                      padding: ModernSpacing.paddingMD,
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? colorScheme.surfaceVariant.withValues(alpha: 0.3)
                                            : colorScheme.surface,
                                        borderRadius: ModernRadius.smRadius,
                                      ),
                                      child: Text(
                                        event,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 凡例アイテムを構築（モダンデザイン）
  Widget _buildLegendItem(String label, Color color, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: ModernSpacing.paddingMD,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: ModernRadius.mdRadius,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: ModernShadows.coloredShadow(color, opacity: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: ModernRadius.smRadius,
              boxShadow: ModernShadows.coloredShadow(color, opacity: 0.3),
            ),
            child: Icon(
              icon,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
}
