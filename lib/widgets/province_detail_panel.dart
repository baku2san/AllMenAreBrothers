/// 州詳細パネルウィジェット
/// 選択された州の詳細情報と操作を表示
library;

import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';

/// 州詳細パネル
class ProvinceDetailPanel extends StatelessWidget {
  const ProvinceDetailPanel({
    super.key,
    required this.province,
    required this.gameState,
  });

  final Province province;
  final WaterMarginGameState gameState;

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
        content: const Text('内政開発機能は今後実装予定です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 徴兵ダイアログを表示
  void _showRecruitmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name} - 徴兵'),
        content: const Text('徴兵機能は今後実装予定です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 英雄派遣ダイアログを表示
  void _showHeroAssignmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name} - 英雄派遣'),
        content: const Text('英雄派遣機能は今後実装予定です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 攻撃ダイアログを表示
  void _showAttackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${province.name} - 攻撃'),
        content: const Text('攻撃機能は今後実装予定です。'),
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
        title: Text('${province.name} - 交渉'),
        content: const Text('交渉機能は今後実装予定です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
