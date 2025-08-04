/// 水滸伝の州・マップデータ
/// 宋朝時代の主要な州府をモデル化
library;

import 'package:flutter/material.dart';

import '../models/province.dart';
import '../models/water_margin_strategy_game.dart';

/// 水滸伝マップデータ
class WaterMarginMap {
  /// 初期マップの州リスト（Mapとして返す）
  static Map<String, Province> get initialProvinces => {
        for (final province in _provinceList) province.name: province,
      };

  /// 州ごとの初期勢力（controller）情報
  static final Map<String, Faction> initialProvinceFactions = {
    '梁山泊': Faction.liangshan,
    '開封府': Faction.imperial,
    '洛陽城': Faction.imperial,
    '長安城': Faction.imperial,
    '濟州府': Faction.neutral,
    '青州府': Faction.warlord,
    '応天府': Faction.neutral,
    '大同府': Faction.warlord,
    '揚州府': Faction.neutral,
    '登州府': Faction.neutral,
    '大名府': Faction.warlord,
    '太原府': Faction.warlord,
    '延安府': Faction.bandit,
    '成都府': Faction.neutral,
  };

  /// 州のリスト
  static List<Province> get _provinceList => [
        _liangshan,
        _kaifeng,
        _luoyang,
        _changan,
        _jizhou,
        Province(
          name: '青州府',
          population: 180000,
          agriculture: 80,
          commerce: 70,
          security: 0.65,
          publicSupport: 0.7,
          military: 6000,
          resources: [],
          development: 50,
          neighbors: ['梁山泊', '濟州府'],
        ),
        _yingtian,
        _datong,
        _yangzhou,
        _dengzhou,
        _daming,
        _taiyuan,
        _yanan,
        _chengdu,
      ];

  // === プレイヤー勢力 ===

  /// 梁山泊 - プレイヤーの本拠地
  static final Province _liangshan = Province(
    name: '梁山泊',
    population: 50000,
    agriculture: 60,
    commerce: 40,
    security: 0.9,
    publicSupport: 1.0,
    military: 8500,
    resources: [],
    development: 50,
    neighbors: ['濟州府', '青州府', '開封府'],
  );

  // === 朝廷勢力 ===

  /// 開封府 - 宋朝廷の首都
  static final Province _kaifeng = Province(
    name: '開封府',
    population: 500000,
    agriculture: 80,
    commerce: 95,
    security: 0.85,
    publicSupport: 0.6,
    military: 9000,
    resources: [],
    development: 80,
    neighbors: ['梁山泊', '洛陽城', '応天府'],
  );

  /// 洛陽城 - 西京
  static final Province _luoyang = Province(
    name: '洛陽城',
    population: 300000,
    agriculture: 75,
    commerce: 85,
    security: 0.8,
    publicSupport: 0.65,
    military: 8500,
    resources: [],
    development: 70,
    neighbors: ['開封府', '長安城', '太原府'],
  );

  /// 長安城 - 西の要衝
  static final Province _changan = Province(
    name: '長安城',
    population: 250000,
    agriculture: 70,
    commerce: 80,
    security: 0.75,
    publicSupport: 0.7,
    military: 8000,
    resources: [],
    development: 65,
    neighbors: ['洛陽城', '成都府', '延安府'],
  );

  // === 中立・豪族勢力 ===

  /// 濟州府 - 梁山泊に近い州
  static final Province _jizhou = Province(
    name: '濟州府',
    population: 200000,
    agriculture: 85,
    commerce: 60,
    security: 0.7,
    publicSupport: 0.75,
    military: 5000,
    resources: [],
    development: 55,
    neighbors: ['梁山泊', '青州府', '応天府'],
  );

  // ...existing code...

  /// 登州府 - 海沿いの州
  static final Province _dengzhou = Province(
    name: '登州府',
    population: 150000,
    agriculture: 60,
    commerce: 90,
    security: 0.75,
    publicSupport: 0.8,
    military: 6000,
    resources: [],
    development: 40,
    neighbors: ['青州府', '揚州府'],
  );

  /// 大名府 - 北の州
  static final Province _daming = Province(
    name: '大名府',
    population: 220000,
    agriculture: 75,
    commerce: 65,
    security: 0.6,
    publicSupport: 0.55,
    military: 7500,
    resources: [],
    development: 45,
    neighbors: ['太原府', '開封府', '大同府'],
  );

  /// 太原府 - 山西の要衝
  static final Province _taiyuan = Province(
    name: '太原府',
    population: 190000,
    agriculture: 65,
    commerce: 70,
    security: 0.7,
    publicSupport: 0.65,
    military: 8000,
    resources: [],
    development: 50,
    neighbors: ['大同府', '大名府', '洛陽城', '延安府'],
  );

  /// 延安府 - 西北の州
  static final Province _yanan = Province(
    name: '延安府',
    population: 120000,
    agriculture: 50,
    commerce: 40,
    security: 0.4,
    publicSupport: 0.45,
    military: 6000,
    resources: [],
    development: 30,
    neighbors: ['太原府', '長安城'],
  );

  /// 成都府 - 西南の豊かな州
  static final Province _chengdu = Province(
    name: '成都府',
    population: 280000,
    agriculture: 95,
    commerce: 80,
    security: 0.85,
    publicSupport: 0.8,
    military: 7000,
    resources: [],
    development: 60,
    neighbors: ['長安城'],
  );

  // ...existing code...

  /// 応天府 - 南京
  static final Province _yingtian = Province(
    name: '応天府',
    population: 300000,
    agriculture: 80,
    commerce: 85,
    security: 0.75,
    publicSupport: 0.75,
    military: 7000,
    resources: [],
    development: 60,
    neighbors: ['開封府', '濟州府', '揚州府', '杭州府'],
  );

  /// 大同府 - 北の辺境
  static final Province _datong = Province(
    name: '大同府',
    population: 150000,
    agriculture: 60,
    commerce: 50,
    security: 0.65,
    publicSupport: 0.6,
    military: 8500,
    resources: [],
    development: 45,
    neighbors: ['太原府', '大名府'],
  );

  /// 揚州府 - 東南の州
  static final Province _yangzhou = Province(
    name: '揚州府',
    population: 220000,
    agriculture: 75,
    commerce: 85,
    security: 0.8,
    publicSupport: 0.8,
    military: 6000,
    resources: [],
    development: 55,
    neighbors: ['登州府', '応天府', '杭州府'],
  );

  /// 州IDから州を取得
  static Province? getProvinceById(String id) {
    return initialProvinces[id];
  }

  /// 勢力別の州数を取得
  static Map<Faction, int> getProvinceCountByFaction() {
    final Map<Faction, int> counts = {};
    for (final faction in Faction.values) {
      counts[faction] = initialProvinceFactions.values.where((f) => f == faction).length;
    }
    return counts;
  }

  /// プレイヤーの隣接州を取得（拡張可能な州）
  static List<Province> getExpandableProvinces() {
    final playerProvinces =
        initialProvinces.values.where((p) => initialProvinceFactions[p.name] == Faction.liangshan).toList();
    final expandable = <Province>[];

    for (final playerProvince in playerProvinces) {
      for (final neighborName in playerProvince.neighbors) {
        final adjacent = getProvinceById(neighborName);
        if (adjacent != null &&
            initialProvinceFactions[adjacent.name] != Faction.liangshan &&
            !expandable.contains(adjacent)) {
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
