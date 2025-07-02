/// 州詳細パネルウィジェット（情報表示専用）
/// 選択された州の詳細情報を表示（操作機能は下部コマンドバーに統一）
library;

import 'package:flutter/material.dart' hide Hero;
import '../models/water_margin_strategy_game.dart';
import '../controllers/water_margin_game_controller.dart';
import '../core/app_theme.dart';
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
    final isPlayerProvince = province.controller == Faction.liangshan;

    return Container(
      padding: ModernSpacing.paddingMD,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 州名とアイコン
            Row(
              children: [
                Container(
                  padding: ModernSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: province.controller.factionColor.withValues(alpha: 0.2),
                    borderRadius: ModernRadius.smRadius,
                  ),
                  child: Text(
                    province.provinceIcon,
                    style: AppTextStyles.headlineMedium,
                  ),
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
                          color: province.controller.factionColor.withValues(alpha: 0.2),
                          borderRadius: ModernRadius.smRadius,
                          border: Border.all(
                            color: province.controller.factionColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          province.controller.displayName,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: province.controller.factionColor,
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
            if (province.specialFeature != null) ...[
              Container(
                width: double.infinity,
                padding: ModernSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.1),
                  borderRadius: ModernRadius.mdRadius,
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.accentGold,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        province.specialFeature!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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
                  _buildStatusBar('人口', province.state.population, 1000, Icons.people_rounded, colorScheme),
                  _buildStatusBar('農業', province.state.agriculture, 100, Icons.agriculture_rounded, colorScheme),
                  _buildStatusBar('商業', province.state.commerce, 100, Icons.store_rounded, colorScheme),
                  _buildStatusBar('軍事', province.state.military, 100, Icons.military_tech_rounded, colorScheme),
                  _buildStatusBar('治安', province.state.security, 100, Icons.security_rounded, colorScheme),
                  _buildStatusBar('民心', province.state.loyalty, 100, Icons.favorite_rounded, colorScheme),
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
                        '現在兵力: ${province.currentTroops}人',
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
                      Text(
                        '最大兵力: ${province.state.maxTroops}人',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: province.currentTroops / province.state.maxTroops,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      province.currentTroops >= province.state.maxTroops * 0.8
                          ? Colors.green
                          : province.currentTroops >= province.state.maxTroops * 0.5
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 兵糧情報
            Container(
              padding: ModernSpacing.paddingMD,
              decoration: ModernDecorations.card(colorScheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_rounded,
                        color: colorScheme.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '兵糧情報',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_rounded,
                        color: colorScheme.onSurface,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '備蓄兵糧: ${province.state.food}',
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
                        Icons.agriculture_rounded,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '月間生産: ${province.state.foodProduction}',
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
                        Icons.local_dining_rounded,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '月間消費: ${province.state.getFoodConsumption(province.currentTroops)}',
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
                        province.monthlyFoodBalance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: province.monthlyFoodBalance >= 0 ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '月間収支: ${province.monthlyFoodBalance >= 0 ? '+' : ''}${province.monthlyFoodBalance}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: province.monthlyFoodBalance >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (province.state.isLowOnFood(province.currentTroops)) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: ModernSpacing.paddingMD,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: ModernRadius.smRadius,
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '兵糧不足！',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        color: isPlayerProvince ? Colors.green : province.controller.factionColor,
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
                                color: province.controller.factionColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${province.controller.displayName}の支配下',
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
    return gameState.heroes.where((hero) => hero.currentProvinceId == province.id).toList();
  }

  /// 攻撃状況のメッセージを取得
  String _getAttackStatusMessage() {
    final playerProvinces = controller.getPlayerProvinces();
    final adjacentPlayerProvinces = playerProvinces.where((p) => p.adjacentProvinceIds.contains(province.id)).toList();

    if (adjacentPlayerProvinces.isEmpty) {
      return '攻撃するには隣接する味方の州が必要です';
    }

    final availableProvinces = adjacentPlayerProvinces.where((p) => p.currentTroops > 0).toList();

    if (availableProvinces.isEmpty) {
      return '隣接する味方の州に兵力がありません';
    }

    return '攻撃可能です（コマンドバーから実行）';
  }
}
