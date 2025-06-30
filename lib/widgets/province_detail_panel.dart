/// 州詳細パネルウィジェット
/// 選択された州の詳細情報と操作を表示
library;

import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';
import '../controllers/water_margin_game_controller.dart';

/// 州詳細パネル
class ProvinceDetailPanel extends StatelessWidget {
  const ProvinceDetailPanel({
    super.key,
    required this.province,
    required this.gameState,
    required this.controller,
  });

  final Province province;
  final WaterMarginGameState gameState;
  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final isPlayerProvince = province.controller == Faction.liangshan;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 州名とアイコン
            Row(
              children: [
                Text(
                  province.provinceIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        province.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        province.controller.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: province.controller.factionColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 特殊効果
            if (province.specialFeature != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  province.specialFeature!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 州のステータス
            const Text(
              '州の状況',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildStatusBar('人口', province.state.population, 1000, Icons.people),
            _buildStatusBar('農業', province.state.agriculture, 100, Icons.agriculture),
            _buildStatusBar('商業', province.state.commerce, 100, Icons.store),
            _buildStatusBar('治安', province.state.security, 100, Icons.security),
            _buildStatusBar('軍事', province.state.military, 100, Icons.military_tech),
            _buildStatusBar('民心', province.state.loyalty, 100, Icons.favorite),
            
            const SizedBox(height: 16),
            
            // 軍事情報
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '軍事情報',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('現在兵力', '${province.currentTroops} 人'),
                  _buildInfoRow('兵力上限', '${province.state.maxTroops} 人'),
                  _buildInfoRow('食料生産', '${province.state.foodProduction} 石'),
                  _buildInfoRow('税収', '${province.state.taxIncome} 貫'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 行動ボタン
            if (isPlayerProvince) ...[
              const Text(
                '州の操作',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              _buildActionButton(
                '内政開発',
                Icons.build,
                () => _showDevelopmentDialog(context),
              ),
              _buildActionButton(
                '徴兵',
                Icons.people_alt,
                () => _showRecruitmentDialog(context),
              ),
              _buildActionButton(
                '英雄派遣',
                Icons.person_pin,
                () => _showHeroAssignmentDialog(context),
              ),
            ] else ...[
              const Text(
                '外交',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              _buildActionButton(
                '攻撃',
                Icons.gps_fixed,
                () => _showAttackDialog(context),
              ),
              _buildActionButton(
                '交渉',
                Icons.handshake,
                () => _showNegotiationDialog(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ステータスバーを構築
  Widget _buildStatusBar(String label, int value, int maxValue, IconData icon) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(percentage),
            ),
          ),
        ],
      ),
    );
  }

  /// ステータスの色を取得
  Color _getStatusColor(double percentage) {
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.6) return Colors.lightGreen;
    if (percentage >= 0.4) return Colors.yellow;
    if (percentage >= 0.2) return Colors.orange;
    return Colors.red;
  }

  /// 情報行を構築
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 行動ボタンを構築
  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// 内政開発ダイアログを表示
  void _showDevelopmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name} - 内政開発'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('開発項目を選択してください (費用: 500両)'),
            const SizedBox(height: 16),
            Text('現在の資金: ${gameState.playerGold}両'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: gameState.playerGold >= 500 
                ? () {
                    Navigator.of(context).pop();
                    controller.developProvince(province.id, DevelopmentType.agriculture);
                  }
                : null,
              icon: const Icon(Icons.agriculture),
              label: const Text('農業開発 (+10)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: gameState.playerGold >= 500 
                ? () {
                    Navigator.of(context).pop();
                    controller.developProvince(province.id, DevelopmentType.commerce);
                  }
                : null,
              icon: const Icon(Icons.store),
              label: const Text('商業開発 (+10)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: gameState.playerGold >= 500 
                ? () {
                    Navigator.of(context).pop();
                    controller.developProvince(province.id, DevelopmentType.military);
                  }
                : null,
              icon: const Icon(Icons.military_tech),
              label: const Text('軍事強化 (+10)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: gameState.playerGold >= 500 
                ? () {
                    Navigator.of(context).pop();
                    controller.developProvince(province.id, DevelopmentType.security);
                  }
                : null,
              icon: const Icon(Icons.security),
              label: const Text('治安改善 (+10)'),
            ),
          ],
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

  /// 徴兵ダイアログを表示
  void _showRecruitmentDialog(BuildContext context) {
    final maxRecruits = province.state.maxTroops - province.currentTroops;
    
    if (maxRecruits <= 0) {
      _showSimpleDialog(context, '徴兵', '${province.name}では兵力が上限に達しています');
      return;
    }

    int recruitAmount = 10; // デフォルト徴兵数
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${province.name} - 徴兵'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('現在兵力: ${province.currentTroops} / ${province.state.maxTroops}'),
              Text('最大徴兵可能数: $maxRecruits'),
              Text('現在の資金: ${gameState.playerGold}両'),
              const SizedBox(height: 16),
              const Text('徴兵数を選択してください:'),
              Slider(
                value: recruitAmount.toDouble(),
                min: 1,
                max: maxRecruits.toDouble(),
                divisions: maxRecruits > 1 ? maxRecruits - 1 : 1,
                label: '$recruitAmount人',
                onChanged: (value) {
                  setState(() {
                    recruitAmount = value.toInt();
                  });
                },
              ),
              Text('徴兵数: $recruitAmount人'),
              Text('費用: ${recruitAmount * 10}両'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: gameState.playerGold >= recruitAmount * 10
                ? () {
                    Navigator.of(context).pop();
                    controller.recruitTroops(province.id, recruitAmount);
                  }
                : null,
              child: const Text('徴兵実行'),
            ),
          ],
        ),
      ),
    );
  }

  /// 英雄派遣ダイアログを表示
  void _showHeroAssignmentDialog(BuildContext context) {
    final availableHeroes = gameState.heroes.where((hero) => 
      hero.faction == Faction.liangshan && 
      hero.currentProvinceId != province.id
    ).toList();

    if (availableHeroes.isEmpty) {
      _showSimpleDialog(context, '英雄派遣', '派遣可能な英雄がいません');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name} - 英雄派遣'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('派遣する英雄を選択してください:'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableHeroes.length,
                  itemBuilder: (context, index) {
                    final hero = availableHeroes[index];
                    return ListTile(
                      title: Text(hero.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('武力: ${hero.stats.force} 知力: ${hero.stats.intelligence}'),
                          Text('現在地: ${_getProvinceNameById(hero.currentProvinceId)}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.assignHeroToProvince(hero.id, province.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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

  /// 州IDから州名を取得
  String _getProvinceNameById(String? provinceId) {
    if (provinceId == null) return '未配置';
    final province = gameState.provinces[provinceId];
    return province?.name ?? '不明';
  }

  /// 攻撃ダイアログを表示
  void _showAttackDialog(BuildContext context) {
    // プレイヤーが隣接州を持っているかチェック
    final playerProvinces = controller.getPlayerProvinces();
    if (playerProvinces.isEmpty) {
      _showSimpleDialog(context, '攻撃', 'プレイヤーの州がありません');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name} - 攻撃'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${province.name}を攻撃しますか？'),
            const SizedBox(height: 8),
            Text('敵兵力: ${province.currentTroops}'),
            Text('我が軍の総兵力: ${controller.getTotalTroops()}'),
            const SizedBox(height: 16),
            const Text(
              '注意: 戦闘には兵力損失のリスクがあります',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
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
            onPressed: controller.getTotalTroops() > 0
              ? () {
                  Navigator.of(context).pop();
                  controller.attackProvince(province.id);
                }
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('攻撃開始'),
          ),
        ],
      ),
    );
  }

  /// シンプルなダイアログを表示
  void _showSimpleDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 交渉ダイアログを表示
  void _showNegotiationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name} - 外交交渉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${province.name}(${province.controller.displayName})との交渉'),
            const SizedBox(height: 8),
            Text('現在の資金: ${gameState.playerGold}両'),
            const SizedBox(height: 16),
            const Text('交渉の種類を選択してください (費用: 200両):'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: gameState.playerGold >= 200
                ? () {
                    Navigator.of(context).pop();
                    controller.negotiateWithProvince(province.id, 'peace');
                  }
                : null,
              icon: const Icon(Icons.handshake),
              label: const Text('和平交渉'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: gameState.playerGold >= 200
                ? () {
                    Navigator.of(context).pop();
                    controller.negotiateWithProvince(province.id, 'trade');
                  }
                : null,
              icon: const Icon(Icons.attach_money),
              label: const Text('貿易交渉'),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 交渉の成功率は約30%です',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
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
}
