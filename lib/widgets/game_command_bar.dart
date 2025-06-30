/// ゲーム操作コマンドバー
/// 画面下部に配置される統一されたコマンドインターフェース
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../models/water_margin_strategy_game.dart';
import '../services/game_save_service.dart';
import '../core/app_config.dart';
import '../screens/diplomacy_screen.dart';
import '../screens/hero_management_screen.dart';

/// ゲームコマンドバー
class GameCommandBar extends StatelessWidget {
  const GameCommandBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final selectedProvince = controller.selectedProvince;

        return Container(
          height: 120, // 2行のボタンを配置
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: const Border(top: BorderSide(color: Colors.grey)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 第1行: 基本コマンド
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCommandButton(
                        context: context,
                        label: 'ターン終了',
                        icon: Icons.skip_next,
                        color: Colors.green,
                        onPressed: controller.gameState.gameStatus == GameStatus.playing ? controller.endTurn : null,
                      ),
                      const SizedBox(width: 8),
                      _buildCommandButton(
                        context: context,
                        label: '外交',
                        icon: Icons.handshake,
                        color: Colors.purple,
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
                        icon: Icons.group,
                        color: Colors.indigo,
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
                        icon: Icons.save,
                        color: Colors.orange,
                        onPressed: () => _showSaveDialog(context, controller),
                      ),
                      const SizedBox(width: 8),
                      _buildCommandButton(
                        context: context,
                        label: 'ロード',
                        icon: Icons.folder_open,
                        color: Colors.teal,
                        onPressed: () => _showLoadDialog(context, controller),
                      ),
                      const SizedBox(width: 8),
                      _buildCommandButton(
                        context: context,
                        label: '新規ゲーム',
                        icon: Icons.refresh,
                        color: Colors.red,
                        onPressed: () => controller.initializeGame(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // 第2行: 州関連コマンド
              Expanded(
                child: selectedProvince != null
                    ? _buildProvinceCommands(context, controller, selectedProvince)
                    : const Center(
                        child: Text(
                          '州を選択してください',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 州関連コマンドを構築
  Widget _buildProvinceCommands(
    BuildContext context,
    WaterMarginGameController controller,
    Province province,
  ) {
    if (province.controller == Faction.liangshan) {
      // 味方の州のコマンド
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              '${province.name}: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            _buildCommandButton(
              context: context,
              label: '農業開発',
              subtitle: '${AppConstants.developmentCost}両',
              icon: Icons.agriculture,
              color: Colors.green,
              onPressed: controller.gameState.playerGold >= AppConstants.developmentCost
                  ? () => controller.developProvince(province.id, DevelopmentType.agriculture)
                  : null,
            ),
            const SizedBox(width: 8),
            _buildCommandButton(
              context: context,
              label: '商業開発',
              subtitle: '${AppConstants.developmentCost}両',
              icon: Icons.business,
              color: Colors.blue,
              onPressed: controller.gameState.playerGold >= AppConstants.developmentCost
                  ? () => controller.developProvince(province.id, DevelopmentType.commerce)
                  : null,
            ),
            const SizedBox(width: 8),
            _buildCommandButton(
              context: context,
              label: '軍事強化',
              subtitle: '${AppConstants.developmentCost}両',
              icon: Icons.security,
              color: Colors.red,
              onPressed: controller.gameState.playerGold >= AppConstants.developmentCost
                  ? () => controller.developProvince(province.id, DevelopmentType.military)
                  : null,
            ),
            const SizedBox(width: 8),
            _buildCommandButton(
              context: context,
              label: '治安維持',
              subtitle: '${AppConstants.developmentCost}両',
              icon: Icons.local_police,
              color: Colors.orange,
              onPressed: controller.gameState.playerGold >= AppConstants.developmentCost
                  ? () => controller.developProvince(province.id, DevelopmentType.security)
                  : null,
            ),
            const SizedBox(width: 8),
            _buildCommandButton(
              context: context,
              label: '徴兵',
              subtitle: '100両',
              icon: Icons.people_alt,
              color: Colors.purple,
              onPressed: controller.gameState.playerGold >= 100
                  ? () => _showRecruitmentDialog(context, controller, province)
                  : null,
            ),
          ],
        ),
      );
    } else {
      // 敵の州のコマンド
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              '${province.name}: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            _buildCommandButton(
              context: context,
              label: '攻撃',
              icon: Icons.gps_fixed,
              color: Colors.red,
              onPressed: _canAttackProvince(controller, province)
                  ? () => _showAttackDialog(context, controller, province)
                  : null,
              tooltip: _canAttackProvince(controller, province) ? null : '隣接する味方の州がありません',
            ),
            const SizedBox(width: 8),
            _buildCommandButton(
              context: context,
              label: '交渉',
              icon: Icons.handshake,
              color: Colors.blue,
              onPressed: () => _showNegotiationDialog(context, controller, province),
            ),
          ],
        ),
      );
    }
  }

  /// コマンドボタンを構築
  Widget _buildCommandButton({
    required BuildContext context,
    required String label,
    String? subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip ?? '',
      child: SizedBox(
        width: 100,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? color : Colors.grey.shade300,
            foregroundColor: isEnabled ? Colors.white : Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 8),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 攻撃可能かどうかをチェック
  bool _canAttackProvince(WaterMarginGameController controller, Province province) {
    final playerProvinces = controller.getPlayerProvinces();
    final adjacentPlayerProvinces = playerProvinces.where((p) => p.adjacentProvinceIds.contains(province.id)).toList();

    if (adjacentPlayerProvinces.isEmpty) return false;

    final availableProvinces = adjacentPlayerProvinces.where((p) => p.currentTroops > 0).toList();

    return availableProvinces.isNotEmpty;
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

  /// 徴兵ダイアログを表示
  void _showRecruitmentDialog(
    BuildContext context,
    WaterMarginGameController controller,
    Province province,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name} - 徴兵'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('1000人の兵士を徴兵しますか？'),
            SizedBox(height: 8),
            Text('費用: 100両'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: controller.gameState.playerGold >= 100
                ? () {
                    Navigator.of(context).pop();
                    controller.recruitTroops(province.id, 1000);
                  }
                : null,
            child: const Text('徴兵'),
          ),
        ],
      ),
    );
  }

  /// 攻撃ダイアログを表示
  void _showAttackDialog(
    BuildContext context,
    WaterMarginGameController controller,
    Province targetProvince,
  ) {
    final playerProvinces = controller.getPlayerProvinces();
    final adjacentPlayerProvinces =
        playerProvinces.where((p) => p.adjacentProvinceIds.contains(targetProvince.id)).toList();

    if (adjacentPlayerProvinces.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('攻撃'),
          content: Text('${targetProvince.name}に隣接する味方の州がありません'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final availableProvinces = adjacentPlayerProvinces.where((p) => p.currentTroops > 0).toList();

    if (availableProvinces.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('攻撃'),
          content: Text('${targetProvince.name}への攻撃に使用できる兵力がありません'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // 最も兵力の多い州から自動で攻撃
    final sourceProvince = availableProvinces.reduce(
      (a, b) => a.currentTroops > b.currentTroops ? a : b,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${targetProvince.name}を攻撃'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('攻撃元: ${sourceProvince.name}'),
            Text('攻撃兵力: ${sourceProvince.currentTroops}'),
            const SizedBox(height: 8),
            Text('防御側: ${targetProvince.name}'),
            Text('防御兵力: ${targetProvince.currentTroops}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.attackProvince(targetProvince.id);
            },
            child: const Text('攻撃'),
          ),
        ],
      ),
    );
  }

  /// 交渉ダイアログを表示
  void _showNegotiationDialog(
    BuildContext context,
    WaterMarginGameController controller,
    Province province,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name}との交渉'),
        content: const Text('外交交渉機能は開発中です。\n外交画面をご利用ください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DiplomacyScreen(controller: controller),
                ),
              );
            },
            child: const Text('外交画面へ'),
          ),
        ],
      ),
    );
  }
}
