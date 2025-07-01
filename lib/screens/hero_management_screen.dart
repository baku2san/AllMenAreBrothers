/// 水滸伝戦略ゲーム - 英雄管理画面
library;

import 'package:flutter/material.dart' hide Hero;
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../models/water_margin_strategy_game.dart';
import '../core/app_config.dart';
import '../utils/app_utils.dart';

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

class _HeroManagementScreenState extends State<HeroManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recruitedHeroes.length,
          itemBuilder: (context, index) {
            final hero = recruitedHeroes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ColorUtils.getFactionColor(hero.faction),
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
            );
          },
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
                          backgroundColor: ColorUtils.getFactionColor(hero.faction),
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
  Widget _buildEquipmentTab() {
    return const Center(
      child: Text(
        '装備システムは今後実装予定です',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
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
      builder: (context) => AlertDialog(
        title: Text('${hero.name} (${hero.nickname})'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('職業: ${_getSkillDisplayName(hero.skill)}'),
              Text('レベル: ${_getHeroLevel(hero)}'),
              Text('経験値: ${hero.experience}'),
              Text('忠誠度: ${hero.stats.loyalty}'),
              const SizedBox(height: 12),
              const Text(
                'ステータス',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('武力: ${hero.stats.force}'),
              Text('知力: ${hero.stats.intelligence}'),
              Text('魅力: ${hero.stats.charisma}'),
              Text('統率: ${hero.stats.leadership}'),
              Text('戦闘力: ${hero.stats.combatPower}'),
              const SizedBox(height: 12),
              Text('現在地: ${_getLocationName(hero.currentProvinceId)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
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

  /// 英雄レベル計算（簡易版）
  int _getHeroLevel(Hero hero) {
    return (hero.experience / 100).floor() + 1;
  }

  /// 次のレベルまでの経験値
  int _getExpToNextLevel(Hero hero) {
    final currentLevel = _getHeroLevel(hero);
    final nextLevelExp = currentLevel * 100;
    return nextLevelExp - hero.experience.toInt();
  }

  /// 経験値プログレス計算
  double _getExpProgress(Hero hero) {
    final currentLevel = _getHeroLevel(hero);
    final currentLevelExp = (currentLevel - 1) * 100;
    final nextLevelExp = currentLevel * 100;
    final progress = (hero.experience - currentLevelExp) / (nextLevelExp - currentLevelExp);
    return progress.clamp(0.0, 1.0);
  }

  /// 配置場所名を取得
  String _getLocationName(String? provinceId) {
    if (provinceId == null) return '未配置';
    final province = widget.controller.gameState.provinces[provinceId];
    return province?.name ?? '不明';
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
