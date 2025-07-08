/// ゲーム情報パネルウィジェット
/// プレイヤーの状況とターン操作を表示
library;

import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';
import '../core/app_config.dart';
import '../widgets/event_history_dialog.dart';

/// ゲーム情報パネル
class GameInfoPanel extends StatelessWidget {
  const GameInfoPanel({
    super.key,
    required this.gameState,
    required this.eventHistory,
  });

  final WaterMarginGameState gameState;
  final List<String> eventHistory;

  @override
  Widget build(BuildContext context) {
    debugPrint('📊 GameInfoPanel.build開始');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final result = Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ゲームタイトル
            Row(
              children: [
                Icon(
                  Icons.castle_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '梁山泊情勢',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // イベント履歴ボタン
                      GestureDetector(
                        onTap: () => _showEventHistory(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 14,
                              color: colorScheme.primary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'イベント履歴を見る',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colorScheme.primary.withValues(alpha: 0.7),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ターン情報
            _buildInfoCard(context, [
              _buildInfoRow('ターン', '${gameState.currentTurn}', Icons.calendar_today_rounded, colorScheme),
              _buildInfoRow('軍資金', '${gameState.playerGold} 両', Icons.monetization_on_rounded, colorScheme),
              _buildInfoRow('支配州', '${gameState.playerProvinceCount} 州', Icons.location_city_rounded, colorScheme),
              _buildInfoRow('総兵力', '${gameState.playerTotalTroops} 人', Icons.groups_rounded, colorScheme),
              _buildInfoRow('仲間', '${gameState.recruitedHeroCount} 人', Icons.person_rounded, colorScheme),
            ]),

            const SizedBox(height: 16),

            // ゲーム状況の簡易表示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getGameStatusMessage(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    debugPrint('📊 GameInfoPanel.build完了');
    return result;
  }

  /// 情報カードを構築
  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  /// 情報行を構築
  Widget _buildInfoRow(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 18,
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
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
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

    // ゼロ除算を防ぐ
    if (totalProvinces == 0) {
      return '州の情報が読み込まれていません。';
    }

    final progress = ((provinceCount / totalProvinces) * 100).round().clamp(0, 100);

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

  /// イベント履歴ダイアログを表示
  void _showEventHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EventHistoryDialog(
        eventHistory: eventHistory,
      ),
    );
  }
}
