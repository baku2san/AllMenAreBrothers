/// 戦闘結果表示ダイアログ
library;

import 'package:flutter/material.dart';
import '../models/advanced_battle_system.dart';
import '../models/water_margin_strategy_game.dart';
import '../core/app_config.dart';

/// 戦闘結果を表示するダイアログ
class BattleResultDialog extends StatelessWidget {
  const BattleResultDialog({
    super.key,
    required this.result,
    required this.attackerProvinceName,
    required this.defenderProvinceName,
  });

  final AdvancedBattleResult result;
  final String attackerProvinceName;
  final String defenderProvinceName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '戦闘結果',
        style: AppTextStyles.header.copyWith(
          color: result.attackerWins ? AppColors.success : AppColors.error,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 勝敗結果
            _buildVictorySection(),
            const SizedBox(height: 16),

            // 戦闘詳細
            _buildBattleDetails(),
            const SizedBox(height: 16),

            // 損失情報
            _buildCasualtiesSection(),
            const SizedBox(height: 16),

            // 英雄の活躍
            if (result.heroResults.isNotEmpty) ...[
              _buildHeroResultsSection(),
              const SizedBox(height: 16),
            ],

            // 特殊イベント
            if (result.specialEvents.isNotEmpty) ...[
              _buildSpecialEventsSection(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildVictorySection() {
    final isPlayerWin = result.winner == Faction.liangshan;
    final resultText = isPlayerWin ? '勝利！' : '敗北...';
    final resultColor = isPlayerWin ? AppColors.success : AppColors.error;
    final territoryText = result.territoryConquered ? ' - $defenderProvinceNameを占領！' : ' - 占領には失敗';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resultColor),
      ),
      child: Row(
        children: [
          Icon(
            isPlayerWin ? Icons.military_tech : Icons.close,
            color: resultColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$resultText$territoryText',
              style: AppTextStyles.subHeader.copyWith(color: resultColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '戦闘詳細',
              style: AppTextStyles.subHeader,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.info),
                const SizedBox(width: 4),
                Text('戦場: ${_getBattleTypeText()}', style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.landscape, size: 16, color: AppColors.info),
                const SizedBox(width: 4),
                Text('参戦: $attackerProvinceName vs $defenderProvinceName', style: AppTextStyles.body),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasualtiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '戦闘損失',
              style: AppTextStyles.subHeader,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('攻撃側', style: AppTextStyles.caption),
                    Text(
                      '${result.attackerLosses}人',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('防御側', style: AppTextStyles.caption),
                    Text(
                      '${result.defenderLosses}人',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '英雄の活躍',
              style: AppTextStyles.subHeader,
            ),
            const SizedBox(height: 8),
            ...result.heroResults.map((heroResult) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        _getPerformanceIcon(heroResult.performance),
                        size: 16,
                        color: _getPerformanceColor(heroResult.performance),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${heroResult.hero.nickname}: ${_getPerformanceText(heroResult.performance)}',
                          style: AppTextStyles.body,
                        ),
                      ),
                      Text(
                        '経験値+${heroResult.experienceGained}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialEventsSection() {
    return Card(
      color: AppColors.accentGold.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppColors.accentGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  '特殊イベント',
                  style: AppTextStyles.subHeader.copyWith(
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...result.specialEvents.map((event) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• $event',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.darkGold,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _getBattleTypeText() {
    switch (result.battleType) {
      case BattleType.fieldBattle:
        return '野戦';
      case BattleType.siegeBattle:
        return '攻城戦';
      case BattleType.navalBattle:
        return '水戦';
      case BattleType.duel:
        return '一騎討ち';
      case BattleType.ambush:
        return '奇襲';
    }
  }

  IconData _getPerformanceIcon(HeroPerformance performance) {
    switch (performance) {
      case HeroPerformance.outstanding:
        return Icons.star;
      case HeroPerformance.good:
        return Icons.thumb_up;
      case HeroPerformance.poor:
        return Icons.thumb_down;
      case HeroPerformance.defeated:
        return Icons.close;
    }
  }

  Color _getPerformanceColor(HeroPerformance performance) {
    switch (performance) {
      case HeroPerformance.outstanding:
        return AppColors.accentGold;
      case HeroPerformance.good:
        return AppColors.success;
      case HeroPerformance.poor:
        return AppColors.warning;
      case HeroPerformance.defeated:
        return AppColors.error;
    }
  }

  String _getPerformanceText(HeroPerformance performance) {
    switch (performance) {
      case HeroPerformance.outstanding:
        return '大活躍！';
      case HeroPerformance.good:
        return '善戦';
      case HeroPerformance.poor:
        return '不調';
      case HeroPerformance.defeated:
        return '敗北';
    }
  }
}
