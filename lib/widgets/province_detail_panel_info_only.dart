library;

import 'package:water_margin_game/models/province.dart';
import 'package:flutter/material.dart' hide Hero;
import '../models/water_margin_strategy_game.dart';
import '../controllers/water_margin_game_controller.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../data/water_margin_map.dart';

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
    final isPlayerProvince = faction == Faction.liangshan;

    return Container(
      padding: EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 州名とアイコン
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (faction?.factionColor ?? Colors.grey).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // child: Text(
                  //   province.provinceIcon,
                  //   style: AppTextStyles.headlineMedium,
                  // ),
                  child: Icon(Icons.location_city, size: 28, color: Colors.grey),
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

            // 特殊効果表示
            // 特殊効果表示は未定義のため削除

            // 州のステータス
            Container(
              padding: ModernSpacing.paddingMD,
              decoration: ModernDecorations.card(colorScheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_rounded,
                        color: colorScheme.primary,
                        size: 20,
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
                  _buildStatusBar('人口', province.population, 1000, Icons.people_rounded, colorScheme),
                  _buildStatusBar('農業', province.agriculture.toInt(), 100, Icons.agriculture_rounded, colorScheme),
                  _buildStatusBar('商業', province.commerce.toInt(), 100, Icons.store_rounded, colorScheme),
                  _buildStatusBar('軍事', province.military.toInt(), 100, Icons.military_tech_rounded, colorScheme),
                  _buildStatusBar('治安', province.security.toInt(), 100, Icons.security_rounded, colorScheme),
                  _buildStatusBar('民心', province.publicSupport.toInt(), 100, Icons.favorite_rounded, colorScheme),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 軍事情報
            Container(
              padding: ModernSpacing.paddingMD,
              decoration: ModernDecorations.card(colorScheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '軍事情報',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        color: colorScheme.onSurface,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '兵力: ${province.military.toInt()}人',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: colorScheme.onSurface,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      // 最大兵力は省略
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 兵力ゲージは省略
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 配置英雄情報
            if (_getHeroesInProvince().isNotEmpty) ...[
              Container(
                padding: ModernSpacing.paddingMD,
                decoration: ModernDecorations.card(colorScheme),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          color: colorScheme.tertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '配置英雄',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._getHeroesInProvince().map((hero) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: hero.faction.factionColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: hero.faction.factionColor,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hero.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '武力:${hero.stats.force} 知力:${hero.stats.intelligence}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 支配状況
            Container(
              padding: ModernSpacing.paddingMD,
              decoration: ModernDecorations.card(colorScheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPlayerProvince ? Icons.check_circle_rounded : Icons.flag_rounded,
                        color: isPlayerProvince ? Colors.green : (faction?.factionColor ?? Colors.grey),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '支配情報',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isPlayerProvince) ...[
                    Container(
                      padding: ModernSpacing.paddingMD,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: ModernRadius.smRadius,
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '梁山泊の支配下',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: ModernSpacing.paddingMD,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: ModernRadius.smRadius,
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                color: (faction?.factionColor ?? Colors.grey),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${faction?.displayName ?? '不明'}の支配下',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getAttackStatusMessage(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ステータスバーを構築
  Widget _buildStatusBar(String label, int value, int maxValue, IconData icon, ColorScheme colorScheme) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final displayValue = value > maxValue ? maxValue : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: colorScheme.onSurface,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '$displayValue/$maxValue',
                style: AppTextStyles.labelMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(percentage),
            ),
          ),
        ],
      ),
    );
  }

  /// ステータスに応じた色を取得
  Color _getStatusColor(double percentage) {
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.6) return Colors.lightGreen;
    if (percentage >= 0.4) return Colors.orange;
    if (percentage >= 0.2) return Colors.deepOrange;
    return Colors.red;
  }

  /// 州にいる英雄を取得
  List<Hero> _getHeroesInProvince() {
    return gameState.heroes.where((hero) => hero.currentProvinceId == province.name).toList();
  }

  /// 攻撃状況のメッセージを取得
  String _getAttackStatusMessage() {
    // 新モデルでは neighbors で隣接判定、military で兵力判定
    final playerProvinces = controller.getPlayerProvinces();
    final adjacentPlayerProvinces = playerProvinces.where((p) => p.neighbors.contains(province.name)).toList();

    if (adjacentPlayerProvinces.isEmpty) {
      return '攻撃するには隣接する味方の州が必要です';
    }

    final availableProvinces = adjacentPlayerProvinces.where((p) => p.military > 0).toList();

    if (availableProvinces.isEmpty) {
      return '隣接する味方の州に兵力がありません';
    }

    return '攻撃可能です（コマンドバーから実行）';
  }
}
