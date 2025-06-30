/// 水滸伝戦略ゲーム - モダンデザイン対応メイン画面
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Consumer<WaterMarginGameController>(
        builder: (context, controller, child) {
          // 戦闘結果ダイアログの自動表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.lastBattleResult != null) {
              _showBattleResultDialog(context, controller);
            }
          });

          return Column(
            children: [
              // モダンなヘッダー
              _buildModernHeader(context, controller, colorScheme),

              // メインコンテンツエリア
              Expanded(
                child: Row(
                  children: [
                    // メインマップ領域
                    Expanded(
                      flex: 4,
                      child: _buildMapArea(context, controller, colorScheme),
                    ),

                    // サイドバー
                    Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        border: Border(
                          left: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildSidebar(context, controller, colorScheme),
                    ),
                  ],
                ),
              ),

              // モダンなコマンドバー
              const GameCommandBar(),
            ],
          );
        },
      ),
    );
  }

  /// モダンなヘッダーを構築
  Widget _buildModernHeader(
    BuildContext context,
    WaterMarginGameController controller,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              // アプリタイトル
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.castle_rounded,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ゲーム情報カード群
              Row(
                children: [
                  _buildInfoCard(
                    icon: Icons.monetization_on_rounded,
                    label: '資金',
                    value: '${controller.gameState.playerGold}両',
                    color: AppColors.accentGold,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoCard(
                    icon: Icons.access_time_rounded,
                    label: 'ターン',
                    value: '${controller.gameState.currentTurn}',
                    color: colorScheme.secondary,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoCard(
                    icon: Icons.flag_rounded,
                    label: '支配州',
                    value: '${controller.getPlayerProvinces().length}',
                    color: colorScheme.tertiary,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 情報カードを構築
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              Text(
                value,
                style: AppTextStyles.labelLarge.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// マップエリアを構築
  Widget _buildMapArea(
    BuildContext context,
    WaterMarginGameController controller,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // マップヘッダー
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.map_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '北宋天下図',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (controller.selectedProvince != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.selectedProvince!.name} 選択中',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // マップ表示
            Expanded(
              child: GameMapWidget(
                gameState: controller.gameState,
                onProvinceSelected: controller.selectProvince,
              ),
            ),

            // マップ凡例
            if (controller.selectedProvince != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem('選択中', Colors.amber, Icons.location_on_rounded),
                    _buildLegendItem('隣接州', Colors.blue, Icons.link_rounded),
                    _buildLegendItem('攻撃可能', Colors.red, Icons.gps_fixed_rounded),
                    _buildLegendItem('味方州', AppColors.primaryGreen, Icons.flag_rounded),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// サイドバーを構築
  Widget _buildSidebar(
    BuildContext context,
    WaterMarginGameController controller,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // ゲーム情報パネル
        Container(
          height: 240,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GameInfoPanel(
              gameState: controller.gameState,
              onEndTurn: controller.endTurn,
            ),
          ),
        ),

        // 州詳細パネル
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: controller.selectedProvince != null
                  ? ProvinceDetailPanel(
                      province: controller.selectedProvince!,
                      gameState: controller.gameState,
                      controller: controller,
                    )
                  : _buildEmptyState(colorScheme),
            ),
          ),
        ),

        // イベントログ
        Container(
          height: 200,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildEventLog(controller, colorScheme),
          ),
        ),
      ],
    );
  }

  /// 空の状態を構築
  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 48,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '州を選択してください',
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'マップ上の州をタップすると\n詳細情報が表示されます',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.outline.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// イベントログを構築
  Widget _buildEventLog(
    WaterMarginGameController controller,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // ヘッダー
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'イベントログ',
                style: AppTextStyles.titleSmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // ログリスト
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(8),
            itemCount: controller.eventLog.length,
            itemBuilder: (context, index) {
              final event = controller.eventLog[controller.eventLog.length - 1 - index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? colorScheme.surfaceContainerLow : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 凡例アイテムを構築
  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 12,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
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
