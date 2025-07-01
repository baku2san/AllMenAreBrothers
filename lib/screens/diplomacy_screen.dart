/// 水滸伝戦略ゲーム - 外交画面
/// 外交関係の表示と外交行動を行う専用画面
library;

import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';
import '../models/diplomacy_system.dart';
import '../controllers/water_margin_game_controller.dart';
import '../core/app_config.dart';

/// 外交画面
class DiplomacyScreen extends StatelessWidget {
  const DiplomacyScreen({
    super.key,
    required this.controller,
  });

  final WaterMarginGameController controller;

  @override
  Widget build(BuildContext context) {
    final gameState = controller.gameState;
    final diplomacy = gameState.diplomacy;

    if (diplomacy == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('外交'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('外交システムが利用できません'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('外交'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在の資金表示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accentGold),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '現在の資金: ${gameState.playerGold}両',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 外交関係一覧
            const Text(
              '外交関係',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...Faction.values
                .where((faction) => faction != Faction.liangshan)
                .map((faction) => _buildFactionCard(context, faction, diplomacy)),

            const SizedBox(height: 24),

            // 有効な協定
            const Text(
              '有効な協定',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...controller.getActiveTreaties().map((treaty) => _buildTreatyCard(treaty, gameState.currentTurn)),

            if (controller.getActiveTreaties().isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '現在有効な協定はありません',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 勢力カードを構築
  Widget _buildFactionCard(BuildContext context, Faction faction, DiplomacySystem diplomacy) {
    final relation = diplomacy.getRelation(Faction.liangshan, faction);
    final relationLevel = diplomacy.getRelationLevel(Faction.liangshan, faction);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  faction.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: faction.factionColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRelationColor(relationLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    relationLevel.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 関係値バー
            Row(
              children: [
                const Text('関係値: ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (relation + 100) / 200, // -100～100を0～1に変換
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getRelationColor(relationLevel),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$relation',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 外交行動ボタン
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DiplomaticAction.values.map((action) => _buildActionButton(context, faction, action)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 協定カードを構築
  Widget _buildTreatyCard(Treaty treaty, int currentTurn) {
    final remainingTurns = treaty.remainingTurns(currentTurn);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getTreatyIcon(treaty.type),
          color: AppColors.primaryGreen,
        ),
        title: Text(treaty.type.displayName),
        subtitle: Text('相手: ${treaty.faction2.displayName}'),
        trailing: Text(
          '残り$remainingTurnsターン',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 外交行動ボタンを構築
  Widget _buildActionButton(BuildContext context, Faction faction, DiplomaticAction action) {
    final canAfford = controller.gameState.playerGold >= action.cost;

    return ElevatedButton(
      onPressed: canAfford ? () => _showActionConfirmDialog(context, faction, action) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canAfford ? AppColors.primaryGreen : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            action.displayName,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '${action.cost}両',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// 外交行動確認ダイアログを表示
  void _showActionConfirmDialog(BuildContext context, Faction faction, DiplomaticAction action) {
    final diplomacy = controller.gameState.diplomacy!;
    final successRate = diplomacy.calculateSuccessRate(Faction.liangshan, faction, action);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.displayName} - ${faction.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('費用: ${action.cost}両'),
            Text('成功率: ${(successRate * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text(
              _getActionDescription(action),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
              controller.performDiplomaticAction(faction, action);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('実行'),
          ),
        ],
      ),
    );
  }

  /// 関係レベルに応じた色を取得
  Color _getRelationColor(DiplomaticRelation relation) {
    switch (relation) {
      case DiplomaticRelation.allied:
        return Colors.green;
      case DiplomaticRelation.friendly:
        return Colors.lightGreen;
      case DiplomaticRelation.neutral:
        return Colors.grey;
      case DiplomaticRelation.unfriendly:
        return Colors.orange;
      case DiplomaticRelation.hostile:
        return Colors.red;
    }
  }

  /// 協定タイプに応じたアイコンを取得
  IconData _getTreatyIcon(TreatyType type) {
    switch (type) {
      case TreatyType.nonAggression:
        return Icons.handshake;
      case TreatyType.tradeAgreement:
        return Icons.attach_money;
      case TreatyType.militaryAlliance:
        return Icons.shield;
      case TreatyType.vassalage:
        return Icons.star;
    }
  }

  /// 外交行動の説明を取得
  String _getActionDescription(DiplomaticAction action) {
    switch (action) {
      case DiplomaticAction.requestAlliance:
        return '軍事同盟を提案します。関係が良好でないと失敗しやすいです。';
      case DiplomaticAction.declarePeace:
        return '平和を宣言し、不可侵条約を結びます。';
      case DiplomaticAction.requestTrade:
        return '貿易協定を提案し、継続的な収入を得ます。';
      case DiplomaticAction.demandTribute:
        return '貢ぎ物を要求します。関係が悪いと失敗しやすいです。';
      case DiplomaticAction.sendGift:
        return '贈り物を送り、関係を改善します。';
      case DiplomaticAction.threaten:
        return '威嚇して関係を悪化させますが、短期的な効果があります。';
    }
  }
}
