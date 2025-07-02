/// 水滸伝戦略ゲーム - 英雄詳細カードウィジェット
/// Material Design 3準拠の英雄情報表示カード
library;

import 'package:flutter/material.dart' hide Hero;

import '../models/water_margin_strategy_game.dart';
import '../core/app_config.dart';

/// 英雄詳細カードウィジェット
class HeroDetailCard extends StatefulWidget {
  const HeroDetailCard({
    super.key,
    required this.hero,
    required this.isRecruited,
    required this.provinceId,
    this.onTransfer,
    this.onLevelUp,
    this.onRecruit,
    this.showActions = true,
  });

  final Hero hero;
  final bool isRecruited;
  final String? provinceId;
  final VoidCallback? onTransfer;
  final VoidCallback? onLevelUp;
  final VoidCallback? onRecruit;
  final bool showActions;

  @override
  State<HeroDetailCard> createState() => _HeroDetailCardState();
}

class _HeroDetailCardState extends State<HeroDetailCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: widget.isRecruited ? 4 : 2,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              onHover: (hovering) {
                if (hovering) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, colorScheme),
                  _buildBasicInfo(context),
                  if (_isExpanded) ...[
                    _buildDetailedStats(context),
                    _buildSpecialAbilities(context),
                  ],
                  if (widget.showActions) _buildActionButtons(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ヘッダー部分の構築
  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isRecruited
              ? [colorScheme.primary, colorScheme.primaryContainer]
              : [colorScheme.surface, colorScheme.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 英雄アバター
              CircleAvatar(
                radius: 24,
                backgroundColor: widget.isRecruited ? colorScheme.onPrimary : colorScheme.primary,
                child: Text(
                  widget.hero.name.isNotEmpty ? widget.hero.name[0] : '？',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isRecruited ? colorScheme.primary : colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hero.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: widget.isRecruited ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _getSkillDisplayName(widget.hero.skill),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: widget.isRecruited
                                ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                : colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              // レベル表示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isRecruited
                      ? colorScheme.onPrimary.withOpacity(0.2)
                      : colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lv.${_getHeroLevel(widget.hero)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.isRecruited ? colorScheme.onPrimary : colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ステータス表示
          if (widget.isRecruited && widget.provinceId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '配置: ${_getLocationName(widget.provinceId)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 基本情報の構築
  Widget _buildBasicInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatColumn(
              context,
              '武力',
              widget.hero.stats.force,
              Icons.sports_martial_arts,
            ),
          ),
          Expanded(
            child: _buildStatColumn(
              context,
              '知力',
              widget.hero.stats.intelligence,
              Icons.psychology,
            ),
          ),
          Expanded(
            child: _buildStatColumn(
              context,
              '統率',
              widget.hero.stats.leadership,
              Icons.account_balance,
            ),
          ),
          Expanded(
            child: _buildStatColumn(
              context,
              '魅力',
              widget.hero.stats.charisma,
              Icons.favorite,
            ),
          ),
        ],
      ),
    );
  }

  /// ステータス列の構築
  Widget _buildStatColumn(
    BuildContext context,
    String label,
    int value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: _getStatColor(value, colorScheme),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getStatColor(value, colorScheme),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  /// 詳細ステータスの構築
  Widget _buildDetailedStats(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '詳細能力',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProgressStat(
                  context,
                  '経験値',
                  widget.hero.experience,
                  _getExperienceForNextLevel(_getHeroLevel(widget.hero)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressStat(
                  context,
                  '忠誠度',
                  widget.hero.stats.loyalty,
                  100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressStat(
            context,
            '総合力',
            _getTotalStats(),
            400, // 最大値
          ),
        ],
      ),
    );
  }

  /// プログレスバー付きステータス
  Widget _buildProgressStat(
    BuildContext context,
    String label,
    int current,
    int max,
  ) {
    final progress = current / max;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '$current/$max',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(progress, colorScheme),
          ),
        ),
      ],
    );
  }

  /// 特殊能力の構築
  Widget _buildSpecialAbilities(BuildContext context) {
    final abilities = _getSpecialAbilities();
    if (abilities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '特殊能力',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: abilities
                .map((ability) => Chip(
                      label: Text(
                        ability,
                        style: const TextStyle(fontSize: 12),
                      ),
                      side: BorderSide.none,
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// アクションボタンの構築
  Widget _buildActionButtons(BuildContext context) {
    if (!widget.showActions) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (!widget.isRecruited && widget.onRecruit != null) ...[
            Expanded(
              child: FilledButton.icon(
                onPressed: widget.onRecruit,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('登用'),
              ),
            ),
          ] else if (widget.isRecruited) ...[
            if (widget.onTransfer != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onTransfer,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('移動'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (widget.onLevelUp != null && _canLevelUp()) ...[
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.onLevelUp,
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: const Text('成長'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// ステータスに応じた色を取得
  Color _getStatColor(int value, ColorScheme colorScheme) {
    if (value >= 90) return colorScheme.error;
    if (value >= 80) return colorScheme.primary;
    if (value >= 70) return colorScheme.secondary;
    if (value >= 60) return colorScheme.tertiary;
    return colorScheme.onSurface.withOpacity(0.6);
  }

  /// プログレスバーの色を取得
  Color _getProgressColor(double progress, ColorScheme colorScheme) {
    if (progress >= 0.8) return colorScheme.primary;
    if (progress >= 0.6) return colorScheme.secondary;
    if (progress >= 0.4) return colorScheme.tertiary;
    return colorScheme.outline;
  }

  /// 次のレベルまでの経験値を取得
  int _getExperienceForNextLevel(int level) {
    return level * 100; // 基本的な計算式
  }

  /// 総合ステータスを取得
  int _getTotalStats() {
    return widget.hero.stats.force +
        widget.hero.stats.intelligence +
        widget.hero.stats.leadership +
        widget.hero.stats.charisma;
  }

  /// レベルアップ可能かチェック
  bool _canLevelUp() {
    final currentLevel = _getHeroLevel(widget.hero);
    final requiredExp = _getExperienceForNextLevel(currentLevel);
    return widget.hero.experience >= requiredExp;
  }

  /// 英雄のレベルを取得
  int _getHeroLevel(Hero hero) {
    return (hero.experience / 100).floor() + 1;
  }

  /// 特殊能力一覧を取得
  List<String> _getSpecialAbilities() {
    final abilities = <String>[];
    final level = _getHeroLevel(widget.hero);

    // レベルに応じた能力
    if (level >= 10) abilities.add('経験豊富');
    if (level >= 20) abilities.add('名将');

    // ステータスに応じた能力
    if (widget.hero.stats.force >= 90) abilities.add('無双武将');
    if (widget.hero.stats.intelligence >= 90) abilities.add('天才軍師');
    if (widget.hero.stats.leadership >= 90) abilities.add('名統率者');
    if (widget.hero.stats.charisma >= 90) abilities.add('魅力的指導者');

    // スキルに応じた能力
    switch (widget.hero.skill) {
      case HeroSkill.warrior:
        if (widget.hero.stats.force >= 80) abilities.add('戦闘指揮');
        break;
      case HeroSkill.strategist:
        if (widget.hero.stats.intelligence >= 80) abilities.add('戦術立案');
        break;
      case HeroSkill.administrator:
        if (widget.hero.stats.leadership >= 80) abilities.add('内政統括');
        break;
      case HeroSkill.diplomat:
        if (widget.hero.stats.charisma >= 80) abilities.add('外交交渉');
        break;
      case HeroSkill.scout:
        abilities.add('偵察活動');
        break;
    }

    return abilities;
  }

  /// 配置場所名を取得
  String _getLocationName(String? provinceId) {
    if (provinceId == null) return '未配置';
    // 実際の実装では controller から州名を取得
    return '州名'; // プレースホルダー
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
