/// 水滸伝戦略ゲーム - 難易度選択ダイアログ
/// 遊びやすさ向上のための難易度選択UI
library;

import 'package:flutter/material.dart';
import '../models/game_difficulty.dart';
import '../core/app_theme.dart';

/// 難易度選択ダイアログ
class DifficultySelectionDialog extends StatefulWidget {
  const DifficultySelectionDialog({
    super.key,
    this.initialDifficulty = GameDifficulty.normal,
    required this.onDifficultySelected,
  });

  final GameDifficulty initialDifficulty;
  final void Function(GameDifficulty difficulty) onDifficultySelected;

  @override
  State<DifficultySelectionDialog> createState() => _DifficultySelectionDialogState();
}

class _DifficultySelectionDialogState extends State<DifficultySelectionDialog> {
  late GameDifficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: ModernRadius.mdRadius,
      ),
      child: Container(
        width: 600,
        padding: ModernSpacing.paddingXXL,
        decoration: BoxDecoration(
          borderRadius: ModernRadius.mdRadius,
          gradient: ModernColors.primaryGradient,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '難易度選択',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 説明文
            Text(
              'ゲームの難易度を選択してください。\n後から変更することはできません。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 難易度一覧
            ...GameDifficulty.values.map((difficulty) {
              final settings = GameDifficultySettings.forDifficulty(difficulty);
              final isSelected = _selectedDifficulty == difficulty;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDifficulty = difficulty;
                      });
                    },
                    borderRadius: ModernRadius.mdRadius,
                    child: Container(
                      padding: ModernSpacing.paddingXL,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.1)
                            : colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: isSelected ? colorScheme.primary : colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: ModernRadius.mdRadius,
                        boxShadow: isSelected ? ModernShadows.elevation2 : ModernShadows.elevation1,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 難易度名とアイコン
                          Row(
                            children: [
                              Icon(
                                _getDifficultyIcon(difficulty),
                                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                difficulty.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isSelected) ...[
                                const Spacer(),
                                Icon(
                                  Icons.check_circle,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 説明文
                          Text(
                            difficulty.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 設定詳細
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildSettingChip(context, '初期資金', '${settings.initialGold}両'),
                              _buildSettingChip(context, '収入', '${(settings.incomeMultiplier * 100).round()}%'),
                              _buildSettingChip(
                                  context, '開発コスト', '${(settings.developmentCostMultiplier * 100).round()}%'),
                              _buildSettingChip(context, 'AI積極性', '${(settings.aiAggressiveness * 100).round()}%'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            // ボタン群
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onDifficultySelected(_selectedDifficulty);
                      Navigator.of(context).pop();
                    },
                    child: const Text('この難易度で開始'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 難易度に応じたアイコンを取得
  IconData _getDifficultyIcon(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return Icons.sentiment_very_satisfied;
      case GameDifficulty.normal:
        return Icons.sentiment_satisfied;
      case GameDifficulty.hard:
        return Icons.sentiment_neutral;
      case GameDifficulty.expert:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  /// 設定詳細チップを構築
  Widget _buildSettingChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 難易度選択ダイアログを表示
Future<GameDifficulty?> showDifficultySelectionDialog(
  BuildContext context, {
  GameDifficulty initialDifficulty = GameDifficulty.normal,
}) {
  return showDialog<GameDifficulty>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DifficultySelectionDialog(
      initialDifficulty: initialDifficulty,
      onDifficultySelected: (difficulty) => Navigator.of(context).pop(difficulty),
    ),
  );
}
