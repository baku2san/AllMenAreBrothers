/// モダンゲーム操作コマンドバー
/// Material Design 3準拠の統一されたコマンドインターフェース
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../models/water_margin_strategy_game.dart';
import '../services/game_save_service.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../screens/diplomacy_screen.dart';
import '../screens/hero_management_screen.dart';

/// モダンゲームコマンドバー
class GameCommandBar extends StatelessWidget {
  const GameCommandBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final selectedProvince = controller.selectedProvince;

        return Container(
          margin: ModernSpacing.paddingMD,
          decoration: ModernDecorations.elevatedCard(colorScheme),
          child: Padding(
            padding: ModernSpacing.paddingMD,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 基本コマンド行
                SizedBox(
                  height: 56,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCommandButton(
                          context: context,
                          label: 'ターン終了',
                          icon: Icons.skip_next_rounded,
                          isPrimary: true,
                          onPressed: controller.gameState.gameStatus == GameStatus.playing ? controller.endTurn : null,
                        ),
                        const SizedBox(width: 8),
                        _buildCommandButton(
                          context: context,
                          label: '外交',
                          icon: Icons.handshake_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DiplomacyScreen(controller: controller),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildCommandButton(
                          context: context,
                          label: '英雄管理',
                          icon: Icons.group_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HeroManagementScreen(controller: controller),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildCommandButton(
                          context: context,
                          label: 'セーブ',
                          icon: Icons.save_rounded,
                          onPressed: () => _showSaveDialog(context, controller),
                        ),
                        const SizedBox(width: 8),
                        _buildCommandButton(
                          context: context,
                          label: 'ロード',
                          icon: Icons.folder_open_rounded,
                          onPressed: () => _showLoadDialog(context, controller),
                        ),
                        const SizedBox(width: 8),
                        _buildCommandButton(
                          context: context,
                          label: '新規ゲーム',
                          icon: Icons.refresh_rounded,
                          isDestructive: true,
                          onPressed: () => _showNewGameDialog(context, controller),
                        ),
                      ],
                    ),
                  ),
                ),

                // 州コマンド行（選択時のみ表示）
                if (selectedProvince != null) ...[
                  const SizedBox(height: 8),
                  Divider(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    height: 1,
                  ),
                  const SizedBox(height: 8),
                  _buildProvinceCommands(context, controller, selectedProvince),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// モダンコマンドボタンを構築
  Widget _buildCommandButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    bool isPrimary = false,
    bool isDestructive = false,
    String? cost,
    String? tooltip,
    VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buttonContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: onPressed == null
              ? colorScheme.onSurface.withValues(alpha: 0.38)
              : (isPrimary
                  ? colorScheme.onPrimary
                  : isDestructive
                      ? colorScheme.onError
                      : colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: onPressed == null
                ? colorScheme.onSurface.withValues(alpha: 0.38)
                : (isPrimary
                    ? colorScheme.onPrimary
                    : isDestructive
                        ? colorScheme.onError
                        : colorScheme.onSurface),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (cost != null) ...[
          const SizedBox(height: 2),
          Text(
            cost,
            style: AppTextStyles.labelSmall.copyWith(
              color: onPressed == null
                  ? colorScheme.onSurface.withValues(alpha: 0.38)
                  : (isPrimary
                      ? colorScheme.onPrimary.withValues(alpha: 0.8)
                      : isDestructive
                          ? colorScheme.onError.withValues(alpha: 0.8)
                          : colorScheme.onSurface.withValues(alpha: 0.7)),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: ModernRadius.mdRadius,
        child: Container(
          width: 80,
          height: 52,
          padding: ModernSpacing.paddingXS,
          decoration: BoxDecoration(
            color: onPressed == null
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : (isPrimary
                    ? colorScheme.primary
                    : isDestructive
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerHighest),
            borderRadius: ModernRadius.mdRadius,
            border: Border.all(
              color: onPressed == null
                  ? colorScheme.outline.withValues(alpha: 0.3)
                  : (isPrimary
                      ? colorScheme.primary
                      : isDestructive
                          ? colorScheme.error
                          : colorScheme.outline),
              width: isPrimary ? 2 : 1,
            ),
            boxShadow: onPressed != null
                ? (isPrimary
                    ? ModernShadows.coloredShadow(colorScheme.primary, opacity: 0.3)
                    : isDestructive
                        ? ModernShadows.coloredShadow(colorScheme.error, opacity: 0.2)
                        : ModernShadows.elevation1)
                : null,
          ),
          child: buttonContent,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  /// 州コマンドを構築
  Widget _buildProvinceCommands(
    BuildContext context,
    WaterMarginGameController controller,
    Province selectedProvince,
  ) {
    final gameState = controller.gameState;

    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 農業開発
            _buildCommandButton(
              context: context,
              label: '農業開発',
              icon: Icons.agriculture_rounded,
              cost: '${AppConstants.developmentCost}両',
              tooltip: '農業を向上させます',
              onPressed: gameState.playerGold >= AppConstants.developmentCost &&
                      selectedProvince.controller == Faction.liangshan
                  ? () => controller.developProvince(selectedProvince.id, DevelopmentType.agriculture)
                  : null,
            ),
            const SizedBox(width: 8),

            // 商業開発
            _buildCommandButton(
              context: context,
              label: '商業開発',
              icon: Icons.business_rounded,
              cost: '${AppConstants.developmentCost}両',
              tooltip: '商業を向上させます',
              onPressed: gameState.playerGold >= AppConstants.developmentCost &&
                      selectedProvince.controller == Faction.liangshan
                  ? () => controller.developProvince(selectedProvince.id, DevelopmentType.commerce)
                  : null,
            ),
            const SizedBox(width: 8),

            // 兵士募集
            _buildCommandButton(
              context: context,
              label: '兵士募集',
              icon: Icons.shield_rounded,
              cost: '${AppConstants.recruitmentCostPerTroop * 100}両',
              tooltip: '100人の兵士を募集します',
              onPressed: gameState.playerGold >= AppConstants.recruitmentCostPerTroop * 100 &&
                      selectedProvince.controller == Faction.liangshan
                  ? () => controller.recruitTroops(selectedProvince.id, 100)
                  : null,
            ),
            const SizedBox(width: 8),

            // 兵糧補給
            _buildCommandButton(
              context: context,
              label: '兵糧補給',
              icon: Icons.restaurant_rounded,
              cost: '${AppConstants.foodSupplyCost}両',
              tooltip: '兵糧を補給します（500単位）',
              onPressed: gameState.playerGold >= AppConstants.foodSupplyCost &&
                      selectedProvince.controller == Faction.liangshan
                  ? () => controller.supplyFood(selectedProvince.id, 500)
                  : null,
            ),
            const SizedBox(width: 8),

            // 攻撃
            if (_canAttackFrom(controller, selectedProvince))
              _buildCommandButton(
                context: context,
                label: '攻撃',
                icon: Icons.gps_fixed_rounded,
                isDestructive: true,
                tooltip: '隣接する敵州を攻撃します',
                onPressed: () => _showAttackDialog(context, controller, selectedProvince),
              ),
          ],
        ),
      ),
    );
  }

  /// 攻撃可能かチェック
  bool _canAttackFrom(WaterMarginGameController controller, Province province) {
    if (province.controller != Faction.liangshan) return false;

    // 隣接州に敵がいるかチェック
    for (final neighborId in province.adjacentProvinceIds) {
      final neighbor = controller.gameState.provinces[neighborId];
      if (neighbor != null && neighbor.controller != Faction.liangshan) {
        return true;
      }
    }
    return false;
  }

  /// セーブダイアログを表示
  void _showSaveDialog(BuildContext context, WaterMarginGameController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ゲームセーブ'),
        content: const Text('現在のゲーム状態を保存しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await GameSaveService.saveGame(controller.gameState);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ゲームを保存しました')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('保存に失敗しました: $e')),
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
        title: const Text('ゲームロード'),
        content: const Text('保存されたゲームを読み込みますか？\n現在の進行状況は失われます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                // 既存のセーブファイルが存在するかチェック
                // ここではGameSaveServiceの実装に依存するため、
                // 実際の実装に合わせて調整が必要
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ロード機能は実装中です')),
                );
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('読み込みに失敗しました: $e')),
                  );
                }
              }
            },
            child: const Text('読み込み'),
          ),
        ],
      ),
    );
  }

  /// 新規ゲームダイアログを表示
  void _showNewGameDialog(BuildContext context, WaterMarginGameController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新規ゲーム'),
        content: const Text('新しいゲームを開始しますか？\n現在の進行状況は失われます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              controller.initializeGame();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('新しいゲームを開始しました')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('開始'),
          ),
        ],
      ),
    );
  }

  /// 攻撃ダイアログを表示
  void _showAttackDialog(
    BuildContext context,
    WaterMarginGameController controller,
    Province attackerProvince,
  ) {
    // 隣接する敵州を取得
    final targets = <Province>[];
    for (final neighborId in attackerProvince.adjacentProvinceIds) {
      final neighbor = controller.gameState.provinces[neighborId];
      if (neighbor != null && neighbor.controller != Faction.liangshan) {
        targets.add(neighbor);
      }
    }

    if (targets.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('攻撃目標選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: targets
              .map((target) => ListTile(
                    leading: Icon(
                      Icons.gps_fixed_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(target.name),
                    subtitle: Text('勢力: ${_getFactionName(target.controller)}'),
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.attackProvince(target.id);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  /// 勢力名を取得
  String _getFactionName(Faction faction) {
    switch (faction) {
      case Faction.liangshan:
        return '梁山泊';
      case Faction.imperial:
        return '朝廷';
      case Faction.warlord:
        return '豪族';
      case Faction.bandit:
        return '盗賊';
      case Faction.neutral:
        return '中立';
    }
  }
}
