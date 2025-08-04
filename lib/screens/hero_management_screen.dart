/// 水滸伝戦略ゲーム - 英雄管理画面
/// Material Design 3準拠のモダンなUI/UXで英雄の詳細管理を行う
library;

import '../models/province.dart';

import '../data/water_margin_map.dart';

import 'package:flutter/material.dart' hide Hero;
import 'package:provider/provider.dart';
import '../controllers/water_margin_game_controller.dart';
import '../models/water_margin_strategy_game.dart';
import '../data/sample_equipment.dart';
import '../core/app_config.dart';
import '../widgets/hero_transfer_dialog.dart';
import '../widgets/hero_level_up_dialog.dart';

/// 英雄管理メイン画面
class HeroManagementScreen extends StatefulWidget {
  const HeroManagementScreen({
    super.key,
    required this.controller,
  });

  final WaterMarginGameController controller;

  @override
  State<HeroManagementScreen> createState() => _HeroManagementScreenState();
}

class _HeroManagementScreenState extends State<HeroManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  // 検索とフィルタリング用の状態
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  HeroSkill? _selectedSkillFilter;
  bool _showAssignedOnly = false;
  bool _showUnassignedOnly = false;
  bool _sortByPower = false;
  bool _isShowingFilterOptions = false;

  // 一括操作用の状態
  bool _isBulkSelectionMode = false;
  final Set<String> _selectedHeroIds = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '英雄管理',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: AppColors.darkGreen.withValues(alpha: 0.5),
        actions: [
          IconButton(
            icon: Icon(_isBulkSelectionMode ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: () {
              setState(() {
                _isBulkSelectionMode = !_isBulkSelectionMode;
                if (!_isBulkSelectionMode) {
                  _selectedHeroIds.clear();
                }
              });
            },
            tooltip: _isBulkSelectionMode ? '一括選択を終了' : '一括選択を開始',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.accentGold,
          tabs: const [
            Tab(
              icon: Icon(Icons.group),
              text: '仲間',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: '育成',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: '装備',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecruitedHeroesTab(),
          _buildHeroDevelopmentTab(),
          _buildEquipmentTab(),
        ],
      ),
    );
  }

  /// 仲間英雄一覧タブ
  Widget _buildRecruitedHeroesTab() {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final recruitedHeroes = controller.gameState.heroes.where((hero) => hero.isRecruited).toList();

        if (recruitedHeroes.isEmpty) {
          return const Center(
            child: Text(
              '仲間になった英雄がいません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        // フィルタリングとソート
        final filteredHeroes = _filterHeroes(recruitedHeroes);
        final sortedHeroes = _sortHeroes(filteredHeroes);

        return Column(
          children: [
            // 検索バー
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '英雄を検索...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // フィルターオプション表示トグル
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isShowingFilterOptions = !_isShowingFilterOptions;
                      });
                    },
                    icon: Icon(
                      _isShowingFilterOptions ? Icons.expand_less : Icons.expand_more,
                    ),
                    label: Text(_isShowingFilterOptions ? 'フィルター表示を閉じる' : 'フィルターオプションを表示'),
                  ),
                  const Spacer(),
                  // ソート切り替え
                  IconButton(
                    icon: Icon(
                      _sortByPower ? Icons.fitness_center : Icons.sort_by_alpha,
                      color: AppColors.primaryGreen,
                    ),
                    tooltip: _sortByPower ? '戦闘力でソート中' : '名前でソート中',
                    onPressed: () {
                      setState(() {
                        _sortByPower = !_sortByPower;
                      });
                    },
                  ),
                ],
              ),
            ),

            // フィルターオプション
            if (_isShowingFilterOptions)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'フィルター',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // スキルフィルター
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('すべて'),
                              selected: _selectedSkillFilter == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedSkillFilter = null;
                                  });
                                }
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                            ),
                            ...HeroSkill.values.map((skill) => FilterChip(
                                  label: Text(_getSkillDisplayName(skill)),
                                  selected: _selectedSkillFilter == skill,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSkillFilter = selected ? skill : null;
                                    });
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                                )),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 配置状況フィルター
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('配置済み'),
                              selected: _showAssignedOnly,
                              onSelected: (selected) {
                                setState(() {
                                  _showAssignedOnly = selected;
                                  if (selected) {
                                    _showUnassignedOnly = false;
                                  }
                                });
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                            ),
                            FilterChip(
                              label: const Text('未配置'),
                              selected: _showUnassignedOnly,
                              onSelected: (selected) {
                                setState(() {
                                  _showUnassignedOnly = selected;
                                  if (selected) {
                                    _showAssignedOnly = false;
                                  }
                                });
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // コマンドバー（一括操作用）
            if (_isBulkSelectionMode && _selectedHeroIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          '${_selectedHeroIds.length}名の英雄を選択中',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _selectedHeroIds.isEmpty
                                  ? null
                                  : () => _showBulkTransferDialog(
                                      sortedHeroes.where((hero) => _selectedHeroIds.contains(hero.id)).toList()),
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('一括移動'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _selectedHeroIds.isEmpty
                                  ? null
                                  : () => _showBulkLevelUpDialog(
                                      sortedHeroes.where((hero) => _selectedHeroIds.contains(hero.id)).toList()),
                              icon: const Icon(Icons.upgrade),
                              label: const Text('一括強化'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGold,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 英雄リスト
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedHeroes.length,
                itemBuilder: (context, index) {
                  final hero = sortedHeroes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Stack(
                      children: [
                        // 通常のリストタイル
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getFactionColor(hero.faction),
                            child: Text(
                              hero.nickname.substring(0, 1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${hero.name} (${hero.nickname})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('職業: ${_getSkillDisplayName(hero.skill)}'),
                              Text('レベル: ${_getHeroLevel(hero)} (経験値: ${hero.experience})'),
                              Text('配置: ${_getLocationName(hero.currentProvinceId)}'),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '戦闘力',
                                style: AppTextStyles.caption,
                              ),
                              Text(
                                '${hero.stats.combatPower}',
                                style: AppTextStyles.subHeader.copyWith(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showHeroDetailDialog(context, hero),
                        ),

                        // 選択チェックボックス（一括操作モード時のみ表示）
                        if (_isBulkSelectionMode)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Checkbox(
                              value: _selectedHeroIds.contains(hero.id),
                              onChanged: (value) {
                                setState(() {
                                  if (value ?? false) {
                                    _selectedHeroIds.add(hero.id);
                                  } else {
                                    _selectedHeroIds.remove(hero.id);
                                  }
                                });
                              },
                              activeColor: AppColors.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// 英雄育成タブ
  Widget _buildHeroDevelopmentTab() {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final recruitedHeroes = controller.gameState.heroes.where((hero) => hero.isRecruited).toList();

        if (recruitedHeroes.isEmpty) {
          return const Center(
            child: Text(
              '育成可能な英雄がいません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recruitedHeroes.length,
          itemBuilder: (context, index) {
            final hero = recruitedHeroes[index];
            final level = _getHeroLevel(hero);
            final expToNext = _getExpToNextLevel(hero);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getFactionColor(hero.faction),
                          child: Text(
                            hero.nickname.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${hero.name} (${hero.nickname})',
                                style: AppTextStyles.subHeader,
                              ),
                              Text(
                                'Lv.$level - ${_getSkillDisplayName(hero.skill)}',
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 経験値ゲージ
                    Text(
                      '経験値: ${hero.experience} (次のレベルまで: $expToNext)',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _getExpProgress(hero),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 12),

                    // ステータス表示
                    _buildStatsDisplay(hero),
                    const SizedBox(height: 12),

                    // 育成ボタン
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.gameState.playerGold >= 100
                                ? () => _trainHero(context, hero, '戦闘訓練', 100)
                                : null,
                            icon: const Icon(Icons.fitness_center),
                            label: const Text('戦闘訓練 (100両)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.gameState.playerGold >= 150
                                ? () => _trainHero(context, hero, '知識学習', 150)
                                : null,
                            icon: const Icon(Icons.school),
                            label: const Text('知識学習 (150両)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.info,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 装備管理タブ
  /// 装備タブ - 英雄の装備管理
  Widget _buildEquipmentTab() {
    return Consumer<WaterMarginGameController>(
      builder: (context, controller, child) {
        final recruitedHeroes = controller.gameState.heroes.where((hero) => hero.isRecruited).toList();

        if (recruitedHeroes.isEmpty) {
          return const Center(
            child: Text(
              '装備可能な英雄がいません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        // 選択中の英雄
        Hero? selectedHero;
        if (recruitedHeroes.isNotEmpty) {
          selectedHero = recruitedHeroes.first;
        }

        return Column(
          children: [
            // 英雄セレクター
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '装備する英雄を選択',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '英雄',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedHero?.id,
                        items: recruitedHeroes
                            .map((hero) => DropdownMenuItem(
                                  value: hero.id,
                                  child: Text('${hero.name} (${hero.nickname})'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          // TODO: 英雄選択処理を実装
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 装備スロット
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: selectedHero != null
                    ? _buildEquipmentSlots(selectedHero)
                    : const Center(
                        child: Text('英雄を選択してください'),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 装備スロット表示
  Widget _buildEquipmentSlots(Hero hero) {
    return ListView(
      children: [
        _buildEquipmentSlot(
          '武器',
          Icons.sports_kabaddi,
          null, // TODO: hero.equipment?.weapon,
          () => _showEquipmentSelection(hero, EquipmentType.weapon),
        ),
        const SizedBox(height: 16),
        _buildEquipmentSlot(
          '防具',
          Icons.shield,
          null, // TODO: hero.equipment?.armor,
          () => _showEquipmentSelection(hero, EquipmentType.armor),
        ),
        const SizedBox(height: 16),
        _buildEquipmentSlot(
          '装身具',
          Icons.auto_awesome,
          null, // TODO: hero.equipment?.accessory,
          () => _showEquipmentSelection(hero, EquipmentType.accessory),
        ),
        const SizedBox(height: 16),
        _buildEquipmentStatsBonus(hero),
      ],
    );
  }

  /// 装備スロット項目
  Widget _buildEquipmentSlot(String label, IconData icon, Equipment? equipment, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.lightGreen.withAlpha(50),
                child: Icon(icon, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      equipment != null ? equipment.name : '装備なし',
                      style: TextStyle(
                        color: equipment != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    if (equipment != null)
                      Text(
                        equipment.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  /// 装備によるステータスボーナス表示
  Widget _buildEquipmentStatsBonus(Hero hero) {
    // TODO: 実際の装備効果を計算
    const bonusStats = HeroStats(
      force: 0,
      intelligence: 0,
      charisma: 0,
      leadership: 0,
      loyalty: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '装備によるステータスボーナス',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBonusStat('武力', bonusStats.force),
                ),
                Expanded(
                  child: _buildBonusStat('知力', bonusStats.intelligence),
                ),
                Expanded(
                  child: _buildBonusStat('魅力', bonusStats.charisma),
                ),
                Expanded(
                  child: _buildBonusStat('統率', bonusStats.leadership),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ボーナスステータス表示
  Widget _buildBonusStat(String label, int value) {
    final displayValue = value > 0 ? '+$value' : '$value';
    final color = value > 0 ? Colors.green : Colors.grey;

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayValue,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// ステータス表示ウィジェット
  Widget _buildStatsDisplay(Hero hero) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem('武力', hero.stats.force, Icons.local_fire_department),
        ),
        Expanded(
          child: _buildStatItem('知力', hero.stats.intelligence, Icons.psychology),
        ),
        Expanded(
          child: _buildStatItem('魅力', hero.stats.charisma, Icons.favorite),
        ),
        Expanded(
          child: _buildStatItem('統率', hero.stats.leadership, Icons.groups),
        ),
      ],
    );
  }

  /// 個別ステータス項目
  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryGreen,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
        Text(
          value.toString(),
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 英雄詳細ダイアログ
  void _showHeroDetailDialog(BuildContext context, Hero hero) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getFactionColor(hero.faction),
                      radius: 24,
                      child: Text(
                        hero.nickname.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${hero.name} (${hero.nickname})',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getSkillDisplayName(hero.skill),
                            style: TextStyle(
                              color: Colors.grey[700],
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
                ),

                const Divider(height: 24),

                // 詳細情報カード
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ステータス情報
                        _buildHeroDetailInfoCard(hero),
                        const SizedBox(height: 16),

                        // アクションボタン
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 移動ボタン
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showHeroTransferDialog(context, hero);
                              },
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('移動'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                                foregroundColor: Colors.white,
                              ),
                            ),

                            // 育成ボタン
                            ElevatedButton.icon(
                              onPressed: widget.controller.gameState.playerGold >= 200
                                  ? () {
                                      Navigator.of(context).pop();
                                      _showHeroLevelUpDialog(context, hero);
                                    }
                                  : null,
                              icon: const Icon(Icons.trending_up),
                              label: const Text('育成'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 英雄詳細情報カード
  Widget _buildHeroDetailInfoCard(Hero hero) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // レベルと経験値
            Row(
              children: [
                const Icon(Icons.stars, size: 20, color: AppColors.accentGold),
                const SizedBox(width: 8),
                Text(
                  'レベル: ${_getHeroLevel(hero)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '経験値: ${hero.experience}/${_getHeroLevel(hero) * 100}',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: _getExpProgress(hero),
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ステータス詳細
            const Text(
              'ステータス',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                _buildStatColumn('武力', hero.stats.force, Icons.local_fire_department, Colors.red[400]!),
                _buildStatColumn('知力', hero.stats.intelligence, Icons.psychology, Colors.blue[400]!),
                _buildStatColumn('魅力', hero.stats.charisma, Icons.favorite, Colors.pink[400]!),
                _buildStatColumn('統率', hero.stats.leadership, Icons.groups, Colors.amber[700]!),
              ],
            ),

            const Divider(height: 24),

            // 追加情報
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('忠誠度', style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Text('${hero.stats.loyalty}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('戦闘力', style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          const Icon(Icons.shield, size: 16, color: AppColors.primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            '${hero.stats.combatPower}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 現在地情報
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '現在地: ${_getLocationName(hero.currentProvinceId)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ステータス列を構築
  Widget _buildStatColumn(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: value > 70 ? color : null,
            ),
          ),
        ],
      ),
    );
  }

  /// 英雄訓練処理
  void _trainHero(BuildContext context, Hero hero, String trainingType, int cost) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$trainingType - ${hero.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${hero.name}に$trainingTypeを行います。'),
            Text('費用: $cost両'),
            Text('獲得経験値: 50'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 仮の経験値追加処理
              widget.controller.trainHero(hero.id, cost, 50);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${hero.name}が$trainingTypeを行いました！'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('実行'),
          ),
        ],
      ),
    );
  }

  /// 英雄移動ダイアログを表示する
  void _showHeroTransferDialog(BuildContext context, Hero hero) {
    showDialog(
      context: context,
      builder: (context) => HeroTransferDialog(
        hero: hero,
        controller: widget.controller,
        currentProvinceId: hero.currentProvinceId,
      ),
    );
  }

  /// 英雄レベルアップダイアログを表示する
  void _showHeroLevelUpDialog(BuildContext context, Hero hero) {
    showDialog(
      context: context,
      builder: (context) => HeroLevelUpDialog(
        hero: hero,
        controller: widget.controller,
      ),
    );
  }

  /// 一括移動ダイアログを表示
  void _showBulkTransferDialog(List<Hero> heroes) {
    if (heroes.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        String? selectedProvinceId;
        final provinces = widget.controller.gameState.provinces.values
            .where((province) => WaterMarginMap.initialProvinceFactions[province.name]?.name == Faction.liangshan.name)
            .toList();

        return AlertDialog(
          title: Text('${heroes.length}名の英雄を移動'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('移動先の州を選択してください:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '州',
                    border: OutlineInputBorder(),
                  ),
                  items: provinces.map((province) {
                    return DropdownMenuItem(
                      value: province.name,
                      child: Text(province.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedProvinceId = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedProvinceId != null) {
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  navigator.pop();

                  // プログレス表示
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('英雄移動中...'),
                        ],
                      ),
                    ),
                  );

                  // 全ての英雄を移動
                  for (final hero in heroes) {
                    await widget.controller.transferHero(hero.id, selectedProvinceId!);
                  }

                  // プログレス閉じる
                  if (mounted) {
                    navigator.pop();

                    // 完了通知
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('${heroes.length}名の英雄を移動しました'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // 選択解除
                    setState(() {
                      _selectedHeroIds.clear();
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('移動'),
            ),
          ],
        );
      },
    );
  }

  /// 一括レベルアップダイアログを表示
  void _showBulkLevelUpDialog(List<Hero> heroes) {
    if (heroes.isEmpty) return;

    // 合計費用を計算
    int totalCost = 0;
    for (final hero in heroes) {
      totalCost += _calculateLevelUpCost(hero);
    }

    final currentMoney = widget.controller.gameState.playerGold;
    final canAfford = currentMoney >= totalCost;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${heroes.length}名の英雄を強化'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('選択中の英雄:'),
            const SizedBox(height: 8),
            Container(
              height: 120,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                itemCount: heroes.length,
                itemBuilder: (context, index) {
                  final hero = heroes[index];
                  return ListTile(
                    title: Text(hero.name),
                    subtitle: Text('Lv.${_getHeroLevel(hero)}'),
                    dense: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('総費用: '),
                Text(
                  '$totalCost',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canAfford ? AppColors.primaryGreen : Colors.red,
                  ),
                ),
                const Text(' 銀両'),
              ],
            ),
            if (!canAfford)
              const Text(
                '資金が不足しています',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: canAfford
                ? () async {
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    navigator.pop();

                    // プログレス表示
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('英雄強化中...'),
                          ],
                        ),
                      ),
                    );

                    // 全ての英雄を強化
                    for (final hero in heroes) {
                      await widget.controller.levelUpHero(hero.id);
                    }

                    // プログレス閉じる
                    if (mounted) {
                      navigator.pop();

                      // 完了通知
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('${heroes.length}名の英雄を強化しました'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // 選択解除
                      setState(() {
                        _selectedHeroIds.clear();
                      });
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('強化'),
          ),
        ],
      ),
    );
  }

  /// レベルアップに必要なコスト計算
  int _calculateLevelUpCost(Hero hero) {
    final level = _getHeroLevel(hero);
    return level * 50; // 仮実装：レベル×50のコスト
  }

  /// 英雄のレベルを取得
  int _getHeroLevel(Hero hero) {
    // 仮実装：経験値100につき1レベル上昇
    return (hero.experience / 100).floor() + 1;
  }

  /// 次のレベルまでに必要な経験値を計算
  int _getExpToNextLevel(Hero hero) {
    final currentExp = hero.experience;
    final nextLevelExp = _getHeroLevel(hero) * 100;
    return nextLevelExp - currentExp;
  }

  /// レベルアップの進捗率を計算（0.0〜1.0）
  double _getExpProgress(Hero hero) {
    final currentLevel = _getHeroLevel(hero);
    final currentLevelExp = (currentLevel - 1) * 100;
    final nextLevelExp = currentLevel * 100;
    final progress = (hero.experience - currentLevelExp) / (nextLevelExp - currentLevelExp);
    return progress.clamp(0.0, 1.0);
  }

  /// 英雄の配置場所名を取得
  String _getLocationName(String? provinceId) {
    if (provinceId == null) return '未配置';

    final province = widget.controller.gameState.provinces.values.firstWhere(
      (p) => p.name == provinceId,
      orElse: () => Province(
        name: '不明',
        population: 0,
        agriculture: 0,
        commerce: 0,
        security: 0,
        publicSupport: 0,
        military: 0,
        resources: const [],
        development: 0,
        neighbors: const [],
      ),
    );
    return province.name;
  }

  /// 英雄スキルの表示名を取得
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

  /// 勢力カラーを取得
  Color _getFactionColor(Faction faction) {
    switch (faction) {
      case Faction.liangshan:
        return AppColors.primaryGreen;
      case Faction.imperial:
        return Colors.red;
      case Faction.warlord:
        return Colors.purple;
      case Faction.bandit:
        return Colors.brown;
      case Faction.neutral:
        return Colors.grey;
    }
  }

  /// フィルタリング条件に基づいて英雄リストをフィルタリングする
  List<Hero> _filterHeroes(List<Hero> heroes) {
    return heroes.where((hero) {
      // 検索クエリによるフィルタリング
      final matchesQuery = _searchQuery.isEmpty ||
          hero.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hero.nickname.toLowerCase().contains(_searchQuery.toLowerCase());

      // スキルによるフィルタリング
      final matchesSkill = _selectedSkillFilter == null || hero.skill == _selectedSkillFilter;

      // 配置状況によるフィルタリング
      final bool matchesAssignment;
      if (_showAssignedOnly) {
        matchesAssignment = hero.currentProvinceId != null;
      } else if (_showUnassignedOnly) {
        matchesAssignment = hero.currentProvinceId == null;
      } else {
        matchesAssignment = true;
      }

      return matchesQuery && matchesSkill && matchesAssignment;
    }).toList();
  }

  /// ソート条件に基づいて英雄リストをソートする
  List<Hero> _sortHeroes(List<Hero> heroes) {
    final sortedList = List<Hero>.from(heroes);

    if (_sortByPower) {
      // 戦闘力でソート
      sortedList.sort((a, b) => b.stats.combatPower.compareTo(a.stats.combatPower));
    } else {
      // デフォルトは名前でソート
      sortedList.sort((a, b) => a.name.compareTo(b.name));
    }

    return sortedList;
  }

  /// 装備選択ダイアログ表示
  void _showEquipmentSelection(Hero hero, EquipmentType type) {
    final availableEquipment = _getAvailableEquipment(type);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getEquipmentTypeName(type)}を選択'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableEquipment.length + 1, // +1 for "no equipment" option
            itemBuilder: (context, index) {
              // 最初の項目は「装備なし」
              if (index == 0) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                  title: const Text('装備を外す'),
                  onTap: () {
                    // TODO: 装備を外すロジック実装
                    Navigator.of(context).pop();
                  },
                );
              }

              final equipment = availableEquipment[index - 1];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(equipment.rarityColor),
                  child: Text(
                    equipment.name.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(equipment.name),
                subtitle: Text(equipment.description),
                trailing: Icon(
                  Icons.add_circle,
                  color: AppColors.primaryGreen,
                ),
                onTap: () {
                  // TODO: 装備を装着するロジック実装
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  /// 装備タイプ名の取得
  String _getEquipmentTypeName(EquipmentType type) {
    switch (type) {
      case EquipmentType.weapon:
        return '武器';
      case EquipmentType.armor:
        return '防具';
      case EquipmentType.accessory:
        return '装身具';
      case EquipmentType.mount:
        return '騎乗動物';
    }
  }

  /// 利用可能な装備の取得
  List<Equipment> _getAvailableEquipment(EquipmentType type) {
    // TODO: 実際のゲーム状態から利用可能な装備を取得
    switch (type) {
      case EquipmentType.weapon:
        return SampleEquipment.weapons;
      case EquipmentType.armor:
        return SampleEquipment.armors;
      case EquipmentType.accessory:
        return SampleEquipment.accessories;
      case EquipmentType.mount:
        return []; // 騎乗動物は今後追加予定
    }
  }
}
