/// 水滸伝戦略ゲーム - チュートリアル・ヒント表示システム
/// 遊びやすさ向上のためのガイダンス機能
library;

import 'package:flutter/material.dart';
import '../models/game_difficulty.dart';
import '../models/water_margin_strategy_game.dart';
import '../core/app_theme.dart';

/// チュートリアル・ヒントパネル
class TutorialHintPanel extends StatefulWidget {
  const TutorialHintPanel({
    super.key,
    required this.gameState,
    this.onClose,
  });

  final WaterMarginGameState gameState;
  final VoidCallback? onClose;

  @override
  State<TutorialHintPanel> createState() => _TutorialHintPanelState();
}

class _TutorialHintPanelState extends State<TutorialHintPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('💡 TutorialHintPanel.build開始');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tips = GameBalanceHelper.getTutorialTips(widget.gameState);
    if (tips.isEmpty) {
      debugPrint('💡 TutorialHintPanel.build完了（ヒントなし）');
      return Positioned(
        top: 16,
        right: 16,
        child: Container(
          width: 320,
          constraints: const BoxConstraints(maxHeight: 120),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: ModernRadius.mdRadius,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: ModernShadows.elevation3,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '現在表示できるヒントはありません',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      );
    }
    debugPrint('💡 TutorialHintPanel.build完了');
    return Positioned(
      top: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Container(
          width: 320,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: ModernRadius.mdRadius,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: ModernShadows.elevation3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー
              Container(
                padding: ModernSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ヒント',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _animationController.reverse().then((_) {
                          widget.onClose?.call();
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: colorScheme.onPrimaryContainer,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // コンテンツ
              if (_isExpanded)
                Container(
                  constraints: const BoxConstraints(maxHeight: 300), // 最大高さを制限
                  padding: ModernSpacing.paddingMD,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...tips.map((tip) => _buildTipItem(context, tip)),
                      const SizedBox(height: 8),
                      _buildProgressIndicator(context),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// ヒント項目を構築
  Widget _buildTipItem(BuildContext context, String tip) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip.replaceFirst('💡 ', ''),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 進行度インジケーターを構築
  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playerProvinces = widget.gameState.provinces.values.where((p) => p.controller == Faction.liangshan).length;
    final totalProvinces = widget.gameState.provinces.length;
    final progress = totalProvinces > 0 ? playerProvinces / totalProvinces : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                color: colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '統一進度',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$playerProvinces/$totalProvinces州',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% 完了',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// ヒント通知ウィジェット（一時的な表示用）
class HintNotification extends StatefulWidget {
  const HintNotification({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
  });

  final String message;
  final Duration duration;
  final VoidCallback? onDismiss;

  @override
  State<HintNotification> createState() => _HintNotificationState();
}

class _HintNotificationState extends State<HintNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // 自動的に非表示にする
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, -1.0),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ModernShadows.elevation3,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: colorScheme.inversePrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onInverseSurface,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _controller.reverse().then((_) {
                      widget.onDismiss?.call();
                    });
                  },
                  child: Icon(
                    Icons.close,
                    color: colorScheme.onInverseSurface,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ヒント通知を表示するヘルパー関数
void showHintNotification(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => HintNotification(
      message: message,
      duration: duration,
      onDismiss: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}
