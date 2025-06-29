/// 水滸伝の英雄データ
/// 108人の好漢とその他の歴史上の人物を定義
library;

import '../models/water_margin_strategy_game.dart';

/// 水滸伝の英雄データ
class WaterMarginHeroes {
  /// 初期英雄リスト（梁山泊の仲間）
  static List<Hero> get initialHeroes => [
        // 梁山泊の主要英雄
        _songJiang,
        _wuYong,
        _linChong,
        _luZhishen,
        _wuSong,
        _liKui,
        _huaSanNiang,
        _yanQing,
        
        // まだ仲間になっていない英雄
        _guanSheng,
        _huYanZhuo,
        _qinMing,
        _xuNing,
      ];

  // === 梁山泊の核心メンバー ===

  /// 宋江 - 及時雨、梁山泊の頭領
  static const Hero _songJiang = Hero(
    id: 'song_jiang',
    name: '宋江',
    nickname: '及時雨',
    stats: HeroStats(
      force: 50,
      intelligence: 90,
      charisma: 95,
      leadership: 98,
      loyalty: 100,
    ),
    skill: HeroSkill.diplomat,
    faction: Faction.liangshan,
    isRecruited: true,
    currentProvinceId: 'liangshan',
  );

  /// 呉用 - 智多星、梁山泊の軍師
  static const Hero _wuYong = Hero(
    id: 'wu_yong',
    name: '呉用',
    nickname: '智多星',
    stats: HeroStats(
      force: 30,
      intelligence: 98,
      charisma: 80,
      leadership: 85,
      loyalty: 95,
    ),
    skill: HeroSkill.strategist,
    faction: Faction.liangshan,
    isRecruited: true,
    currentProvinceId: 'liangshan',
  );

  /// 林冲 - 豹子頭、八十万禁軍教頭
  static const Hero _linChong = Hero(
    id: 'lin_chong',
    name: '林冲',
    nickname: '豹子頭',
    stats: HeroStats(
      force: 95,
      intelligence: 70,
      charisma: 75,
      leadership: 88,
      loyalty: 90,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.liangshan,
    isRecruited: true,
    currentProvinceId: 'liangshan',
  );

  /// 魯智深 - 花和尚
  static const Hero _luZhishen = Hero(
    id: 'lu_zhishen',
    name: '魯智深',
    nickname: '花和尚',
    stats: HeroStats(
      force: 92,
      intelligence: 65,
      charisma: 80,
      leadership: 75,
      loyalty: 88,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.liangshan,
    isRecruited: true,
    currentProvinceId: 'liangshan',
  );

  /// 武松 - 行者
  static const Hero _wuSong = Hero(
    id: 'wu_song',
    name: '武松',
    nickname: '行者',
    stats: HeroStats(
      force: 96,
      intelligence: 70,
      charisma: 70,
      leadership: 80,
      loyalty: 85,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.liangshan,
    isRecruited: true,
    currentProvinceId: 'liangshan',
  );

  /// 李逵 - 黒旋風
  static const Hero _liKui = Hero(
    id: 'li_kui',
    name: '李逵',
    nickname: '黒旋風',
    stats: HeroStats(
      force: 90,
      intelligence: 40,
      charisma: 50,
      leadership: 60,
      loyalty: 100,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.liangshan,
    isRecruited: true,
    currentProvinceId: 'liangshan',
  );

  /// 花栄 - 小李廣
  static const Hero _huaSanNiang = Hero(
    id: 'hua_san_niang',
    name: '花栄',
    nickname: '小李廣',
    stats: HeroStats(
      force: 88,
      intelligence: 75,
      charisma: 80,
      leadership: 82,
      loyalty: 92,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.liangshan,
    isRecruited: true,
    currentProvinceId: 'liangshan',
  );

  /// 燕青 - 浪子
  static const Hero _yanQing = Hero(
    id: 'yan_qing',
    name: '燕青',
    nickname: '浪子',
    stats: HeroStats(
      force: 80,
      intelligence: 85,
      charisma: 90,
      leadership: 75,
      loyalty: 88,
    ),
    skill: HeroSkill.scout,
    faction: Faction.liangshan,
    isRecruited: true,
    currentProvinceId: 'liangshan',
  );

  // === 未仲間の英雄（後に仲間になる可能性） ===

  /// 関勝 - 大刀
  static const Hero _guanSheng = Hero(
    id: 'guan_sheng',
    name: '関勝',
    nickname: '大刀',
    stats: HeroStats(
      force: 94,
      intelligence: 75,
      charisma: 85,
      leadership: 90,
      loyalty: 80,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.imperial,
    isRecruited: false,
    currentProvinceId: 'kaifeng',
  );

  /// 呼延灼 - 双鞭
  static const Hero _huYanZhuo = Hero(
    id: 'hu_yan_zhuo',
    name: '呼延灼',
    nickname: '双鞭',
    stats: HeroStats(
      force: 92,
      intelligence: 70,
      charisma: 75,
      leadership: 88,
      loyalty: 75,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.imperial,
    isRecruited: false,
    currentProvinceId: 'luoyang',
  );

  /// 秦明 - 霹靂火
  static const Hero _qinMing = Hero(
    id: 'qin_ming',
    name: '秦明',
    nickname: '霹靂火',
    stats: HeroStats(
      force: 90,
      intelligence: 65,
      charisma: 70,
      leadership: 85,
      loyalty: 78,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.warlord,
    isRecruited: false,
    currentProvinceId: 'qingzhou',
  );

  /// 徐寧 - 金槍手
  static const Hero _xuNing = Hero(
    id: 'xu_ning',
    name: '徐寧',
    nickname: '金槍手',
    stats: HeroStats(
      force: 88,
      intelligence: 72,
      charisma: 75,
      leadership: 82,
      loyalty: 70,
    ),
    skill: HeroSkill.warrior,
    faction: Faction.imperial,
    isRecruited: false,
    currentProvinceId: 'kaifeng',
  );

  /// 英雄IDから英雄を取得
  static Hero? getHeroById(String id) {
    try {
      return initialHeroes.firstWhere((hero) => hero.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 勢力別の英雄数を取得
  static Map<Faction, int> getHeroCountByFaction() {
    final Map<Faction, int> counts = {};
    for (final faction in Faction.values) {
      counts[faction] = initialHeroes.where((h) => h.faction == faction).length;
    }
    return counts;
  }

  /// 仲間にできる英雄を取得（プレイヤーの隣接州にいる英雄）
  static List<Hero> getRecruitableHeroes(List<String> playerAdjacentProvinceIds) {
    return initialHeroes
        .where((hero) =>
            !hero.isRecruited &&
            hero.currentProvinceId != null &&
            playerAdjacentProvinceIds.contains(hero.currentProvinceId))
        .toList();
  }

  /// 技能別の英雄数を取得
  static Map<HeroSkill, int> getHeroCountBySkill() {
    final Map<HeroSkill, int> counts = {};
    for (final skill in HeroSkill.values) {
      counts[skill] = initialHeroes.where((h) => h.skill == skill).length;
    }
    return counts;
  }
}
