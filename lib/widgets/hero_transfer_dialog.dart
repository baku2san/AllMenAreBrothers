library;

import 'package:water_margin_game/models/province.dart';

/// 水滸伝戦略ゲーム - 英雄移動ダイアログ
/// Material Design 3準拠の英雄移動UI

import 'package:flutter/material.dart' hide Hero;

import '../models/water_margin_strategy_game.dart';
import '../controllers/water_margin_game_controller.dart';
import '../core/app_config.dart';

/// 英雄移動ダイアログ
class HeroTransferDialog extends StatefulWidget {
  const HeroTransferDialog({
    super.key,
    required this.hero,
    required this.controller,
    required this.currentProvinceId,
  });

  final Hero hero;
  final WaterMarginGameController controller;
  final String? currentProvinceId;

  @override
  State<HeroTransferDialog> createState() => _HeroTransferDialogState();
}

class _HeroTransferDialogState extends State<HeroTransferDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late TabController _tabController;

  String? _selectedProvinceId;
  bool _isTransferring = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _tabController = TabController(length: 2, vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 100),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Dialog(
              clipBehavior: Clip.antiAlias,
              child: Container(
                width: 600,
                height: 700,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildHeroInfo(context),
                    const SizedBox(height: 24),
                    _buildTabBar(context),
                    Expanded(
                      child: _buildTabContent(context),
                    ),
                    const SizedBox(height: 16),
                    _buildActionButtons(context),
                  ],
                ),
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
        Icon(
          Icons.swap_horiz,
          size: 28,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '英雄移動',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.hero.name}の配置先を選択してください',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primary,
            child: Text(
              widget.hero.name.isNotEmpty ? widget.hero.name[0] : '？',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hero.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getSkillDisplayName(widget.hero.skill),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Lv.${_getHeroLevel(widget.hero)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// タブバーの構築
  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(
          icon: Icon(Icons.location_city),
          text: '州配置',
        ),
        Tab(
          icon: Icon(Icons.groups),
          text: '部隊配置',
        ),
      ],
    );
  }

  /// タブコンテンツの構築
  Widget _buildTabContent(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildProvinceTab(context),
        _buildArmyTab(context),
      ],
    );
  }

  /// 州配置タブの構築
  Widget _buildProvinceTab(BuildContext context) {
    final availableProvinces = _getAvailableProvinces();
    final filteredProvinces = _filterProvinces(availableProvinces);

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildSearchField(context),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredProvinces.length,
            itemBuilder: (context, index) {
              final province = filteredProvinces[index];
              return _buildProvinceCard(context, province);
            },
          ),
        ),
      ],
    );
  }

  /// 部隊配置タブの構築
  Widget _buildArmyTab(BuildContext context) {
    // 今後の実装: 部隊間の英雄移動
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '部隊間移動機能は開発中です',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 検索フィールドの構築
  Widget _buildSearchField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: '州名で検索...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  /// 州カードの構築
  Widget _buildProvinceCard(BuildContext context, Province province) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedProvinceId == province.name;
    final isCurrent = province.name == widget.currentProvinceId;
    final provinceState = widget.controller.gameState.provinces[province.name];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 2,
      color: isSelected
          ? colorScheme.primaryContainer
          : isCurrent
              ? colorScheme.surfaceContainerHighest
              : null,
      child: InkWell(
        onTap: isCurrent
            ? null
            : () {
                setState(() {
                  _selectedProvinceId = isSelected ? null : province.name;
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          province.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? colorScheme.onPrimaryContainer : null,
                          ),
                        ),
                        Text(
                          _getFactionName(
                            provinceState != null ? widget.controller.gameState.factions[provinceState.name] : null,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                                : colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '現在地',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else if (isSelected) ...[
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // 兵力・人口・治安などの詳細は新モデルに合わせて省略
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ステータスチップの構築
  // Widget _buildStatChip(
  //   BuildContext context,
  //   String label,
  //   String value,
  //   IconData icon,
  //   bool isSelected,
  // ) {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   return Container();
  // }

  /// アクションボタンの構築
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: _selectedProvinceId != null && !_isTransferring ? _handleTransfer : null,
            child: _isTransferring
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('移動実行'),
          ),
        ),
      ],
    );
  }

  /// 移動処理
  Future<void> _handleTransfer() async {
    if (_selectedProvinceId == null) return;

    setState(() {
      _isTransferring = true;
    });

    try {
      // 移動処理の実行
      await widget.controller.transferHero(
        widget.hero.id,
        _selectedProvinceId!,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // 成功を示すtrue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.hero.name}を移動させました'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('移動に失敗しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isTransferring = false;
        });
      }
    }
  }

  /// 利用可能な州を取得
  List<Province> _getAvailableProvinces() {
    return widget.controller.gameState.provinces.values.where((province) {
      // 自分の支配下の州のみ表示
      return widget.controller.gameState.factions[province.name] == Faction.liangshan;
    }).toList();
  }

  /// 州をフィルタリング
  List<Province> _filterProvinces(List<Province> provinces) {
    if (_searchQuery.isEmpty) return provinces;

    return provinces.where((province) => province.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  /// 勢力名を取得
  String _getFactionName(Faction? faction) {
    switch (faction) {
      case Faction.liangshan:
        return '梁山泊';
      case Faction.imperial:
        return '朝廷';
      case Faction.warlord:
        return '豪族';
      case Faction.neutral:
        return '中立';
      case Faction.bandit:
        return '盗賊';
      case null:
        return '不明';
    }
  }

  /// 英雄のレベルを取得
  int _getHeroLevel(Hero hero) {
    return (hero.experience / 100).floor() + 1;
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
