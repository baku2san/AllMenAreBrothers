/// ゲーム情報パネルウィジェット
/// プレイヤーの状況とターン操作を表示
library;

import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';

/// ゲーム情報パネル
class GameInfoPanel extends StatelessWidget {
  const GameInfoPanel({
    super.key,
    required this.gameState,
    required this.onEndTurn,
  });

  final WaterMarginGameState gameState;
  final VoidCallback onEndTurn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ゲームタイトル
            const Text(
              '梁山泊情勢',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // ターン情報
            _buildInfoRow('ターン', '${gameState.currentTurn}'),
            _buildInfoRow('軍資金', '${gameState.playerGold} 貫'),
            _buildInfoRow('支配州', '${gameState.playerProvinceCount} 州'),
            _buildInfoRow('総兵力', '${gameState.playerTotalTroops} 人'),
            _buildInfoRow('仲間', '${gameState.recruitedHeroCount} 人'),
          
          const SizedBox(height: 16),
          
          // ターン終了ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEndTurn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'ターン終了',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // ゲーム状況の簡易表示
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getGameStatusMessage(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  /// 情報行を構築
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// ゲーム状況メッセージを取得
  String _getGameStatusMessage() {
    final provinceCount = gameState.playerProvinceCount;
    final totalProvinces = gameState.provinces.length;
    final progress = (provinceCount / totalProvinces * 100).round();
    
    if (progress < 20) {
      return '梁山泊はまだ小さな勢力です。周辺州の攻略を目指しましょう。';
    } else if (progress < 50) {
      return '梁山泊の勢力が拡大しています。朝廷が警戒し始めるでしょう。';
    } else if (progress < 80) {
      return '梁山泊は大きな勢力となりました。天下統一まであと一歩です。';
    } else {
      return '梁山泊が天下の大半を支配しています。統一は目前です！';
    }
  }
}
