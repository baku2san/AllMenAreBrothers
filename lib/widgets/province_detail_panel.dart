library;

import 'package:water_margin_game/models/province.dart';
import 'package:flutter/material.dart' hide Hero;
import '../models/water_margin_strategy_game.dart';
import '../data/water_margin_map.dart';
import '../controllers/water_margin_game_controller.dart';
import '../core/app_config.dart';

/// 州詳細パネル（情報表示専用）
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final faction = WaterMarginMap.initialProvinceFactions[province.name];
    // final isPlayerProvince = faction == Faction.liangshan;

    return Container(
      padding: EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 州名
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (faction?.factionColor ?? Colors.grey).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_city, size: 28, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        province.name,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (faction?.factionColor ?? Colors.grey).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (faction?.factionColor ?? Colors.grey).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          faction?.displayName ?? '不明',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: faction?.factionColor ?? Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 州のステータス
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '州の状況',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatusBar('人口', province.population),
                  _buildStatusBar('農業', province.agriculture.toInt()),
                  _buildStatusBar('商業', province.commerce.toInt()),
                  _buildStatusBar('軍事', province.military.toInt()),
                  _buildStatusBar('治安', (province.security * 100).toInt()),
                  _buildStatusBar('民心', (province.publicSupport * 100).toInt()),
                  // 旧: 兵糧・食糧・収支情報（未定義getterのため一時的に非表示）
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 配置英雄情報（未定義getterのため一時的に非表示）
            // 旧: 支配状況（未定義getterのため一時的に非表示）
          ],
        ),
      ),
    );
  }

  /// ステータスバーを構築
  Widget _buildStatusBar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
            ),
          ),
          SizedBox(width: 8),
          Text(value.toString()),
        ],
      ),
    );
  }

  /// ステータスに応じた色を取得

  /// 州にいる英雄を取得
  // List<Hero> _getHeroesInProvince() {
  //   return gameState.heroes.where((hero) => hero.currentProvinceId == province.id).toList();
  // }

  /// 攻撃状況のメッセージを取得
  // String _getAttackStatusMessage() {
  //   final playerProvinces = controller.getPlayerProvinces();
  //   final adjacentPlayerProvinces = playerProvinces.where((p) => p.adjacentProvinceIds.contains(province.id)).toList();
  //
  //   if (adjacentPlayerProvinces.isEmpty) {
  //     return '攻撃するには隣接する味方の州が必要です';
  //   }
  //
  //   final availableProvinces = adjacentPlayerProvinces.where((p) => p.currentTroops > 0).toList();
  //
  //   if (availableProvinces.isEmpty) {
  //     return '隣接する味方の州に兵力がありません';
  //   }
}
