/// 水滸伝戦略ゲーム - 英雄レベルアップダイアログ
/// Material Design 3準拠の英雄成長UI
library;

import 'package:flutter/material.dart' hide Hero;
import 'dart:math' as math;

import '../models/water_margin_strategy_game.dart';
import '../controllers/water_margin_game_controller.dart';

/// 英雄レベルアップダイアログ
class HeroLevelUpDialog extends StatefulWidget {
  const HeroLevelUpDialog({
    super.key,
    required this.hero,
    required this.controller,
  });

  final Hero hero;
  final WaterMarginGameController controller;

  @override
  State<HeroLevelUpDialog> createState() => _HeroLevelUpDialogState();
}

class _HeroLevelUpDialogState extends State<HeroLevelUpDialog> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _statsController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _statsAnimation;

  bool _isProcessing = false;
  bool _showResults = false;
  final Map<String, int> _statGrowth = {};
  int _newLevel = 0;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic),
    );

    _scaleController.forward();
    _calculateLevelUp();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildHeroInfo(context),
                  const SizedBox(height: 24),
                  if (!_showResults) ...[
                    _buildLevelUpPreview(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                  ] else ...[
                    _buildLevelUpResults(context),
                    const SizedBox(height: 24),
                    _buildCloseButton(context),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ヘッダーの構築
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.trending_up,
            size: 24,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _showResults ? '成長完了！' : '英雄成長',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _showResults ? '${widget.hero.name}が成長しました' : '${widget.hero.name}の能力を向上させますか？',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        if (!_showResults)
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }

  /// 英雄情報の構築
  Widget _buildHeroInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.primary,
            child: Text(
              widget.hero.name.isNotEmpty ? widget.hero.name[0] : '？',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hero.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  _getSkillDisplayName(widget.hero.skill),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Lv.${_getHeroLevel(widget.hero)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lv.$_newLevel',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// レベルアップ予告の構築
  Widget _buildLevelUpPreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '成長予測',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatPreview(context, '武力', widget.hero.stats.force, _statGrowth['force'] ?? 0),
          const SizedBox(height: 8),
          _buildStatPreview(context, '知力', widget.hero.stats.intelligence, _statGrowth['intelligence'] ?? 0),
          const SizedBox(height: 8),
          _buildStatPreview(context, '統率', widget.hero.stats.leadership, _statGrowth['leadership'] ?? 0),
          const SizedBox(height: 8),
          _buildStatPreview(context, '魅力', widget.hero.stats.charisma, _statGrowth['charisma'] ?? 0),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  size: 16,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '成長値はランダムで決定されます。英雄の特性により得意分野が成長しやすくなります。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ステータス予告の構築
  Widget _buildStatPreview(
    BuildContext context,
    String name,
    int current,
    int growth,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final newValue = current + growth;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            name,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          current.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward,
          size: 16,
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          newValue.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: growth > 0 ? colorScheme.primary : null,
          ),
        ),
        if (growth > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$growth',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// レベルアップ結果の構築
  Widget _buildLevelUpResults(BuildContext context) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Column(
          children: [
            _buildAnimatedStats(context),
            const SizedBox(height: 24),
            _buildSpecialEffects(context),
          ],
        );
      },
    );
  }

  /// アニメーション付きステータス表示
  Widget _buildAnimatedStats(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '成長結果',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          _buildAnimatedStatBar(context, '武力', widget.hero.stats.force, _statGrowth['force'] ?? 0),
          const SizedBox(height: 12),
          _buildAnimatedStatBar(context, '知力', widget.hero.stats.intelligence, _statGrowth['intelligence'] ?? 0),
          const SizedBox(height: 12),
          _buildAnimatedStatBar(context, '統率', widget.hero.stats.leadership, _statGrowth['leadership'] ?? 0),
          const SizedBox(height: 12),
          _buildAnimatedStatBar(context, '魅力', widget.hero.stats.charisma, _statGrowth['charisma'] ?? 0),
        ],
      ),
    );
  }

  /// アニメーション付きステータスバー
  Widget _buildAnimatedStatBar(
    BuildContext context,
    String name,
    int current,
    int growth,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = _statsAnimation.value;
    final animatedGrowth = (growth * progress).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${current + animatedGrowth}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: (current / 100) * MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: ((current + animatedGrowth) / 100) * MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 特殊効果の構築
  Widget _buildSpecialEffects(BuildContext context) {
    final effects = _getSpecialEffects();
    if (effects.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '特殊効果',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...effects.map((effect) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        effect,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// アクションボタンの構築
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: _isProcessing ? null : _handleLevelUp,
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('成長実行'),
          ),
        ),
      ],
    );
  }

  /// 閉じるボタンの構築
  Widget _buildCloseButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => Navigator.of(context).pop(true),
      icon: const Icon(Icons.check),
      label: const Text('完了'),
    );
  }

  /// レベルアップ処理
  Future<void> _handleLevelUp() async {
    setState(() {
      _isProcessing = true;
    });

    // アニメーション遅延
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // レベルアップ実行
      await widget.controller.levelUpHero(widget.hero.id);

      // 結果表示に切り替え
      setState(() {
        _showResults = true;
        _isProcessing = false;
      });

      // ステータスアニメーション開始
      _statsController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('レベルアップに失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// レベルアップ計算
  void _calculateLevelUp() {
    _newLevel = _getHeroLevel(widget.hero) + 1;

    // スキルに基づく成長傾向
    final random = math.Random();

    switch (widget.hero.skill) {
      case HeroSkill.warrior:
        _statGrowth['force'] = 2 + random.nextInt(4); // 2-5
        _statGrowth['intelligence'] = random.nextInt(3); // 0-2
        _statGrowth['leadership'] = random.nextInt(2); // 0-1
        _statGrowth['charisma'] = 1 + random.nextInt(2); // 1-2
        break;
      case HeroSkill.strategist:
        _statGrowth['force'] = random.nextInt(2); // 0-1
        _statGrowth['intelligence'] = 2 + random.nextInt(4); // 2-5
        _statGrowth['leadership'] = 1 + random.nextInt(3); // 1-3
        _statGrowth['charisma'] = 1 + random.nextInt(2); // 1-2
        break;
      case HeroSkill.administrator:
        _statGrowth['force'] = random.nextInt(2); // 0-1
        _statGrowth['intelligence'] = 1 + random.nextInt(3); // 1-3
        _statGrowth['leadership'] = 2 + random.nextInt(4); // 2-5
        _statGrowth['charisma'] = 1 + random.nextInt(3); // 1-3
        break;
      case HeroSkill.diplomat:
        _statGrowth['force'] = random.nextInt(2); // 0-1
        _statGrowth['intelligence'] = 1 + random.nextInt(2); // 1-2
        _statGrowth['leadership'] = 1 + random.nextInt(3); // 1-3
        _statGrowth['charisma'] = 2 + random.nextInt(4); // 2-5
        break;
      case HeroSkill.scout:
        _statGrowth['force'] = 1 + random.nextInt(3); // 1-3
        _statGrowth['intelligence'] = 1 + random.nextInt(3); // 1-3
        _statGrowth['leadership'] = random.nextInt(2); // 0-1
        _statGrowth['charisma'] = 1 + random.nextInt(3); // 1-3
        break;
    }
  }

  /// 英雄のレベルを取得
  int _getHeroLevel(Hero hero) {
    return (hero.experience / 100).floor() + 1;
  }

  /// 特殊効果を取得
  List<String> _getSpecialEffects() {
    final effects = <String>[];

    if (_newLevel % 10 == 0) {
      effects.add('名声が大幅に上昇しました！');
    }

    if (_newLevel == 20) {
      effects.add('特殊スキル「指導力」を習得しました！');
    }

    final totalGrowth = _statGrowth.values.fold(0, (sum, growth) => sum + growth);
    if (totalGrowth >= 10) {
      effects.add('素晴らしい成長を遂げました！');
    }

    return effects;
  }

  /// 英雄スキル表示名を取得
  String _getSkillDisplayName(HeroSkill skill) {
    switch (skill) {
      case HeroSkill.warrior:
        return '武将';
      case HeroSkill.strategist:
        return '軍師';
      case HeroSkill.administrator:
        return '政治家';
      case HeroSkill.diplomat:
        return '外交官';
      case HeroSkill.scout:
        return '斥候';
    }
  }
}
