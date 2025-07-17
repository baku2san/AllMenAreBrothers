/// 水滸伝の州・マップデータ
/// 宋朝時代の主要な州府をモデル化
library;

import 'package:flutter/material.dart';

import '../models/water_margin_strategy_game.dart';

/// 水滸伝マップデータ
class WaterMarginMap {
  /// 初期マップの州リスト（Mapとして返す）
  static Map<String, Province> get initialProvinces => {
        for (final province in _provinceList) province.id: province,
      };

  /// 州のリスト
  static List<Province> get _provinceList => [
        _liangshan, // 梁山泊（プレイヤー本拠地）
        _kaifeng, // 開封府（朝廷首都）
        _jizhou, // 濟州府
        _qingzhou, // 青州府
        _dengzhou, // 登州府
        _daming, // 大名府
        _taiyuan, // 太原府
        _yanan, // 延安府
        _luoyang, // 洛陽城
        _changan, // 長安城
        _chengdu, // 成都府
        _hangzhou, // 杭州府
        _yingtian, // 応天府
        _datong, // 大同府
        _yangzhou, // 揚州府
      ];

  // === プレイヤー勢力 ===

  /// 梁山泊 - プレイヤーの本拠地
  static const Province _liangshan = Province(
    id: 'liangshan',
    name: '梁山泊',
    position: Offset(0.61, 0.30), // 地図画像基準
    controller: Faction.liangshan,
    state: ProvinceState(
      population: 50, // 比較的少ない人口
      agriculture: 60, // 湿地帯で農業は中程度
      commerce: 40, // 商業は低い
      security: 90, // 要塞なので治安良好
      military: 85, // 軍事力高い
      loyalty: 100, // 民心最高
    ),
    currentTroops: 5000,
    adjacentProvinceIds: ['jizhou', 'qingzhou', 'kaifeng'],
    specialFeature: '水泊要塞 - 攻撃時に防御+20',
    capital: true,
    garrison: 2000,
  );

  // === 朝廷勢力 ===

  /// 開封府 - 宋朝廷の首都
  static const Province _kaifeng = Province(
    id: 'kaifeng',
    name: '開封府',
    position: Offset(0.53, 0.38),
    controller: Faction.imperial,
    state: ProvinceState(
      population: 500, // 大都市
      agriculture: 80,
      commerce: 95, // 商業の中心
      security: 85,
      military: 90, // 禁軍の本拠地
      loyalty: 60, // 民心は普通
    ),
    currentTroops: 15000,
    adjacentProvinceIds: ['liangshan', 'luoyang', 'yingtian'],
    capital: true,
    specialFeature: '皇都 - 全ての収入+50%',
  );

  /// 洛陽城 - 西京
  static const Province _luoyang = Province(
    id: 'luoyang',
    name: '洛陽城',
    position: Offset(0.41, 0.32),
    controller: Faction.imperial,
    state: ProvinceState(
      population: 300,
      agriculture: 75,
      commerce: 85,
      security: 80,
      military: 85,
      loyalty: 65,
    ),
    currentTroops: 8000,
    adjacentProvinceIds: ['kaifeng', 'changan', 'taiyuan'],
    specialFeature: '古都 - 文化+20',
  );

  /// 長安城 - 西の要衝
  static const Province _changan = Province(
    id: 'changan',
    name: '長安城',
    position: Offset(0.27, 0.29),
    controller: Faction.imperial,
    state: ProvinceState(
      population: 250,
      agriculture: 70,
      commerce: 80,
      security: 75,
      military: 80,
      loyalty: 70,
    ),
    currentTroops: 7000,
    adjacentProvinceIds: ['luoyang', 'chengdu', 'yanan'],
  );

  // === 中立・豪族勢力 ===

  /// 濟州府 - 梁山泊に近い州
  static const Province _jizhou = Province(
    id: 'jizhou',
    name: '濟州府',
    position: Offset(0.68, 0.25),
    controller: Faction.neutral,
    state: ProvinceState(
      population: 200,
      agriculture: 85,
      commerce: 60,
      security: 70,
      military: 50,
      loyalty: 75,
    ),
    currentTroops: 3000,
    adjacentProvinceIds: ['liangshan', 'qingzhou', 'yingtian'],
  );

  /// 青州府 - 東の州
  static const Province _qingzhou = Province(
    id: 'qingzhou',
    name: '青州府',
    position: Offset(0.82, 0.17),
    controller: Faction.warlord,
    state: ProvinceState(
      population: 180,
      agriculture: 80,
      commerce: 70,
      security: 65,
      military: 70,
      loyalty: 60,
    ),
    currentTroops: 5000,
    adjacentProvinceIds: ['liangshan', 'jizhou', 'dengzhou'],
  );

  /// 登州府 - 海沿いの州
  static const Province _dengzhou = Province(
    id: 'dengzhou',
    name: '登州府',
    position: Offset(0.95, 0.10),
    controller: Faction.neutral,
    state: ProvinceState(
      population: 150,
      agriculture: 60,
      commerce: 90, // 港町なので商業発達
      security: 75,
      military: 60,
      loyalty: 80,
    ),
    currentTroops: 2000,
    adjacentProvinceIds: ['qingzhou', 'yangzhou'],
    specialFeature: '港町 - 商業収入+30%',
  );

  /// 大名府 - 北の州
  static const Province _daming = Province(
    id: 'daming',
    name: '大名府',
    position: Offset(0.51, 0.14),
    controller: Faction.warlord,
    state: ProvinceState(
      population: 220,
      agriculture: 75,
      commerce: 65,
      security: 60,
      military: 75,
      loyalty: 55,
    ),
    currentTroops: 6000,
    adjacentProvinceIds: ['taiyuan', 'kaifeng', 'datong'],
  );

  /// 太原府 - 山西の要衝
  static const Province _taiyuan = Province(
    id: 'taiyuan',
    name: '太原府',
    position: Offset(0.40, 0.12),
    controller: Faction.warlord,
    state: ProvinceState(
      population: 190,
      agriculture: 65,
      commerce: 70,
      security: 70,
      military: 80,
      loyalty: 65,
    ),
    currentTroops: 7000,
    adjacentProvinceIds: ['datong', 'daming', 'luoyang', 'yanan'],
    specialFeature: '山岳要塞 - 防御+15',
  );

  /// 延安府 - 西北の州
  static const Province _yanan = Province(
    id: 'yanan',
    name: '延安府',
    position: Offset(0.28, 0.12),
    controller: Faction.bandit,
    state: ProvinceState(
      population: 120,
      agriculture: 50,
      commerce: 40,
      security: 40, // 盗賊が多い
      military: 60,
      loyalty: 45,
    ),
    currentTroops: 3000,
    adjacentProvinceIds: ['taiyuan', 'changan'],
    specialFeature: '盗賊の巣窟 - 治安悪化',
  );

  /// 成都府 - 西南の豊かな州
  static const Province _chengdu = Province(
    id: 'chengdu',
    name: '成都府',
    position: Offset(0.12, 0.61),
    controller: Faction.neutral,
    state: ProvinceState(
      population: 280,
      agriculture: 95, // 天府之国
      commerce: 80,
      security: 85,
      military: 70,
      loyalty: 80,
    ),
    currentTroops: 4000,
    adjacentProvinceIds: ['changan'],
    specialFeature: '天府之国 - 農業収入+50%',
  );

  /// 杭州府 - 南の豊かな州
  static const Province _hangzhou = Province(
    id: 'hangzhou',
    name: '杭州府',
    position: Offset(0.92, 0.87),
    controller: Faction.neutral,
    state: ProvinceState(
      population: 250,
      agriculture: 85,
      commerce: 90, // 商業都市
      security: 80,
      military: 55,
      loyalty: 85,
    ),
    currentTroops: 3000,
    adjacentProvinceIds: ['yangzhou', 'yingtian'],
    specialFeature: '江南水郷 - 商業+農業収入+25%',
  );

  /// 応天府 - 南京
  static const Province _yingtian = Province(
    id: 'yingtian',
    name: '応天府',
    position: Offset(0.82, 0.72),
    controller: Faction.neutral,
    state: ProvinceState(
      population: 300,
      agriculture: 80,
      commerce: 85,
      security: 75,
      military: 70,
      loyalty: 75,
    ),
    currentTroops: 5000,
    adjacentProvinceIds: ['kaifeng', 'jizhou', 'yangzhou', 'hangzhou'],
  );

  /// 大同府 - 北の辺境
  static const Province _datong = Province(
    id: 'datong',
    name: '大同府',
    position: Offset(0.48, 0.06),
    controller: Faction.warlord,
    state: ProvinceState(
      population: 150,
      agriculture: 60,
      commerce: 50,
      security: 65,
      military: 85, // 辺境守備隊
      loyalty: 60,
    ),
    currentTroops: 6000,
    adjacentProvinceIds: ['taiyuan', 'daming'],
    specialFeature: '辺境要塞 - 騎兵+20%',
  );

  /// 揚州府 - 東南の州
  static const Province _yangzhou = Province(
    id: 'yangzhou',
    name: '揚州府',
    position: Offset(0.92, 0.58),
    controller: Faction.neutral,
    state: ProvinceState(
      population: 220,
      agriculture: 75,
      commerce: 85,
      security: 80,
      military: 60,
      loyalty: 80,
    ),
    currentTroops: 3500,
    adjacentProvinceIds: ['dengzhou', 'yingtian', 'hangzhou'],
  );

  /// 州IDから州を取得
  static Province? getProvinceById(String id) {
    return initialProvinces[id];
  }

  /// 勢力別の州数を取得
  static Map<Faction, int> getProvinceCountByFaction() {
    final Map<Faction, int> counts = {};
    for (final faction in Faction.values) {
      counts[faction] = initialProvinces.values.where((p) => p.controller == faction).length;
    }
    return counts;
  }

  /// プレイヤーの隣接州を取得（拡張可能な州）
  static List<Province> getExpandableProvinces() {
    final playerProvinces = initialProvinces.values.where((p) => p.controller == Faction.liangshan).toList();
    final expandable = <Province>[];

    for (final playerProvince in playerProvinces) {
      for (final adjacentId in playerProvince.adjacentProvinceIds) {
        final adjacent = getProvinceById(adjacentId);
        if (adjacent != null && adjacent.controller != Faction.liangshan && !expandable.contains(adjacent)) {
          expandable.add(adjacent);
        }
      }
    }

    return expandable;
  }

  /// マップのサイズ（0.0-1.0の範囲）
  static const Size mapSize = Size(1.0, 1.0);

  /// マップの表示用タイトル
  static const String mapTitle = '北宋天下図';

  /// マップの説明
  static const String mapDescription = '水滸伝の舞台となる北宋時代の中国。梁山泊を拠点に天下統一を目指せ！';
}
