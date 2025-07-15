/// 水滸伝戦略ゲーム専用モデル
/// フェーズ1: 基盤システム（マップ表示とUI基盤、基本的な英雄・勢力データ、シンプルな内政システム）
library;

import 'package:flutter/material.dart';
import 'diplomacy_system.dart';
import 'game_difficulty.dart';

/// 勢力（プレイヤー、朝廷、豪族など）
enum Faction {
  liangshan, // 梁山泊（プレイヤー）
  imperial, // 宋朝廷（禁軍）
  warlord, // 豪族・軍閥
  bandit, // 盗賊団
  neutral, // 中立
}

/// 英雄の属性
class HeroStats {
  const HeroStats({
    required this.force, // 武力
    required this.intelligence, // 知力
    required this.charisma, // 魅力
    required this.leadership, // 統率
    required this.loyalty, // 義理
  });

  final int force; // 1-100
  final int intelligence; // 1-100
  final int charisma; // 1-100
  final int leadership; // 1-100
  final int loyalty; // 1-100

  /// 総合戦闘力
  int get combatPower => ((force + leadership) * 0.6 + intelligence * 0.4).round();

  /// 内政能力
  int get administrativePower => ((intelligence + charisma) * 0.7 + leadership * 0.3).round();

  /// JSON変換用のtoJsonメソッド
  Map<String, dynamic> toJson() {
    return {
      'force': force,
      'intelligence': intelligence,
      'charisma': charisma,
      'leadership': leadership,
      'loyalty': loyalty,
    };
  }

  /// JSONからのfromJsonファクトリコンストラクタ
  factory HeroStats.fromJson(Map<String, dynamic> json) {
    return HeroStats(
      force: json['force'] ?? 0,
      intelligence: json['intelligence'] ?? 0,
      charisma: json['charisma'] ?? 0,
      leadership: json['leadership'] ?? 0,
      loyalty: json['loyalty'] ?? 0,
    );
  }
}

/// 英雄の専門技能
enum HeroSkill {
  warrior, // 武将（戦闘特化）
  strategist, // 軍師（策略特化）
  administrator, // 政治家（内政特化）
  diplomat, // 外交官（交渉特化）
  scout, // 斥候（情報収集特化）
}

/// 内政開発の種類
enum DevelopmentType {
  agriculture, // 農業開発
  commerce, // 商業開発
  military, // 軍備強化
  security, // 治安維持
}

/// 水滸伝の英雄
class Hero {
  const Hero({
    required this.id,
    required this.name,
    required this.nickname,
    required this.stats,
    required this.skill,
    required this.faction,
    required this.isRecruited,
    this.currentProvinceId,
    this.experience = 0,
  });

  final String id;
  final String name; // 本名
  final String nickname; // 渾名
  final HeroStats stats;
  final HeroSkill skill;
  final Faction faction;
  final bool isRecruited; // 仲間になっているか
  final String? currentProvinceId; // 現在いる州
  final int experience; // 経験値

  Hero copyWith({
    String? id,
    String? name,
    String? nickname,
    HeroStats? stats,
    HeroSkill? skill,
    Faction? faction,
    bool? isRecruited,
    String? currentProvinceId,
    int? experience,
  }) {
    return Hero(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      stats: stats ?? this.stats,
      skill: skill ?? this.skill,
      faction: faction ?? this.faction,
      isRecruited: isRecruited ?? this.isRecruited,
      currentProvinceId: currentProvinceId ?? this.currentProvinceId,
      experience: experience ?? this.experience,
    );
  }

  /// JSON変換用のtoJsonメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'stats': stats.toJson(),
      'skill': skill.name,
      'faction': faction.name,
      'isRecruited': isRecruited,
      'currentProvinceId': currentProvinceId,
      'experience': experience,
    };
  }

  /// JSONからのfromJsonファクトリコンストラクタ
  factory Hero.fromJson(Map<String, dynamic> json) {
    return Hero(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      stats: HeroStats.fromJson(json['stats'] ?? {}),
      skill: HeroSkill.values.firstWhere(
        (e) => e.name == json['skill'],
        orElse: () => HeroSkill.warrior,
      ),
      faction: Faction.values.firstWhere(
        (e) => e.name == json['faction'],
        orElse: () => Faction.neutral,
      ),
      isRecruited: json['isRecruited'] ?? false,
      currentProvinceId: json['currentProvinceId'],
      experience: json['experience'] ?? 0,
    );
  }

  /// 技能のアイコン
  String get skillIcon {
    switch (skill) {
      case HeroSkill.warrior:
        return '⚔️';
      case HeroSkill.strategist:
        return '📋';
      case HeroSkill.administrator:
        return '📜';
      case HeroSkill.diplomat:
        return '🤝';
      case HeroSkill.scout:
        return '👁️';
    }
  }

  /// 技能の説明
  String get skillDescription {
    switch (skill) {
      case HeroSkill.warrior:
        return '武将 - 戦闘に特化';
      case HeroSkill.strategist:
        return '軍師 - 策略に特化';
      case HeroSkill.administrator:
        return '政治家 - 内政に特化';
      case HeroSkill.diplomat:
        return '外交官 - 交渉に特化';
      case HeroSkill.scout:
        return '斥候 - 情報収集に特化';
    }
  }
}

/// 州の状態
class ProvinceState {
  const ProvinceState({
    required this.population, // 人口
    required this.agriculture, // 農業度
    required this.commerce, // 商業度
    required this.security, // 治安
    required this.military, // 軍事力
    required this.loyalty, // 民心
    this.food = 0, // 備蓄兵糧
  });

  final int population; // 人口（1-1000万人）
  final int agriculture; // 農業度（1-100）
  final int commerce; // 商業度（1-100）
  final int security; // 治安（1-100）
  final int military; // 軍事力（1-100）
  final int loyalty; // 民心（1-100、高いほど支持）
  final int food; // 備蓄兵糧

  ProvinceState copyWith({
    int? population,
    int? agriculture,
    int? commerce,
    int? security,
    int? military,
    int? loyalty,
    int? food,
  }) {
    return ProvinceState(
      population: population ?? this.population,
      agriculture: agriculture ?? this.agriculture,
      commerce: commerce ?? this.commerce,
      security: security ?? this.security,
      military: military ?? this.military,
      loyalty: loyalty ?? this.loyalty,
      food: food ?? this.food,
    );
  }

  /// 州の総合評価
  int get overallRating => ((agriculture + commerce + security + military + loyalty) / 5).round();

  /// 食料生産量（人口 x 農業度）
  int get foodProduction => ((population / 100) * agriculture).round();

  /// 基本兵糧消費量計算用（1兵士あたり月間2兵糧）
  int getFoodConsumption(int troops) => troops * 2;

  /// 兵糧不足判定用（現在備蓄 < 2ヶ月分消費量）
  bool isLowOnFood(int troops) => food < getFoodConsumption(troops) * 2;

  /// 税収（人口・商業度バランス調整版）
  /// 人口の影響を抑え、商業度の絶対値も加算する
  int get taxIncome => ((population / 200) * commerce + commerce * 2).round();

  /// 兵力上限（人口 x 軍事力 / 5、より現実的な計算）
  int get maxTroops => ((population / 100) * (military + 20) / 3).round().clamp(50, 5000);

  /// JSON変換用のtoJsonメソッド
  Map<String, dynamic> toJson() {
    return {
      'population': population,
      'agriculture': agriculture,
      'commerce': commerce,
      'security': security,
      'military': military,
      'loyalty': loyalty,
      'food': food,
    };
  }

  /// JSONからのfromJsonファクトリコンストラクタ
  factory ProvinceState.fromJson(Map<String, dynamic> json) {
    return ProvinceState(
      population: json['population'] ?? 0,
      agriculture: json['agriculture'] ?? 0,
      commerce: json['commerce'] ?? 0,
      security: json['security'] ?? 0,
      military: json['military'] ?? 0,
      loyalty: json['loyalty'] ?? 0,
      food: json['food'] ?? 0,
    );
  }
}

/// 州（Province）
class Province {
  const Province({
    required this.id,
    required this.name,
    required this.position,
    required this.controller,
    required this.state,
    required this.currentTroops,
    required this.adjacentProvinceIds,
    this.capital = false,
    this.specialFeature,
    this.garrison = 0,
  });

  final String id;
  final String name;
  final Offset position; // マップ上の位置
  final Faction controller; // 支配勢力
  final ProvinceState state;
  final int currentTroops; // 現在の兵力
  final List<String> adjacentProvinceIds; // 隣接州
  final bool capital; // 首都かどうか
  final String? specialFeature; // 特殊な特徴
  final int garrison; // 駐屯兵力

  /// 隣接州のリスト（AIシステム互換性のため）
  List<String> get neighbors => adjacentProvinceIds;

  /// 月間兵糧収支（生産 - 消費）
  int get monthlyFoodBalance => state.foodProduction - state.getFoodConsumption(currentTroops);

  /// 兵糧不足判定
  bool get isLowOnFood => state.isLowOnFood(currentTroops);

  /// 兵糧備蓄量
  int get foodReserve => state.food;

  /// 兵糧生産量
  int get foodProduction => state.foodProduction;

  /// 兵糧消費量
  int get foodConsumption => state.getFoodConsumption(currentTroops);

  Province copyWith({
    String? id,
    String? name,
    Offset? position,
    Faction? controller,
    ProvinceState? state,
    int? currentTroops,
    List<String>? adjacentProvinceIds,
    bool? capital,
    String? specialFeature,
    int? garrison,
  }) {
    return Province(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      controller: controller ?? this.controller,
      state: state ?? this.state,
      currentTroops: currentTroops ?? this.currentTroops,
      adjacentProvinceIds: adjacentProvinceIds ?? this.adjacentProvinceIds,
      capital: capital ?? this.capital,
      specialFeature: specialFeature ?? this.specialFeature,
      garrison: garrison ?? this.garrison,
    );
  }

  /// 州のアイコン
  String get provinceIcon {
    if (capital) return '👑';
    if (specialFeature != null) return '⭐';
    return '🏙️';
  }

  /// JSON変換用のtoJsonメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': {'dx': position.dx, 'dy': position.dy},
      'controller': controller.name,
      'state': state.toJson(),
      'currentTroops': currentTroops,
      'adjacentProvinceIds': adjacentProvinceIds,
      'capital': capital,
      'specialFeature': specialFeature,
      'garrison': garrison,
    };
  }

  /// JSONからのfromJsonファクトリコンストラクタ
  factory Province.fromJson(Map<String, dynamic> json) {
    final positionMap = json['position'] ?? {'dx': 0.0, 'dy': 0.0};
    return Province(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: Offset(
        (positionMap['dx'] ?? 0.0).toDouble(),
        (positionMap['dy'] ?? 0.0).toDouble(),
      ),
      controller: Faction.values.firstWhere(
        (e) => e.name == json['controller'],
        orElse: () => Faction.neutral,
      ),
      state: ProvinceState.fromJson(json['state'] ?? {}),
      currentTroops: json['currentTroops'] ?? 0,
      adjacentProvinceIds: List<String>.from(json['adjacentProvinceIds'] ?? []),
      capital: json['capital'] ?? false,
      specialFeature: json['specialFeature'],
      garrison: json['garrison'] ?? 0,
    );
  }
}

/// ゲーム全体の状態
class WaterMarginGameState {
  WaterMarginGameState({
    required this.provinces,
    required this.heroes,
    required this.factions,
    required this.currentTurn,
    required this.playerGold,
    required this.gameStatus,
    this.selectedProvinceId,
    this.selectedHeroId,
    this.diplomacy,
    this.difficulty,
    this.triggeredEvents = const {},
  });

  final Map<String, Province> provinces; // Mapに変更してAIシステムと互換性を持つ
  final List<Hero> heroes;
  final Map<String, Faction> factions; // 勢力管理
  final int currentTurn;
  final int playerGold;
  final GameStatus gameStatus;
  final String? selectedProvinceId;
  final String? selectedHeroId;
  final DiplomacySystem? diplomacy; // 外交システム
  final GameDifficulty? difficulty; // 難易度設定
  final Set<String> triggeredEvents; // 発生済みイベント

  WaterMarginGameState copyWith({
    Map<String, Province>? provinces,
    List<Hero>? heroes,
    Map<String, Faction>? factions,
    int? currentTurn,
    int? playerGold,
    GameStatus? gameStatus,
    String? selectedProvinceId,
    String? selectedHeroId,
    DiplomacySystem? diplomacy,
    GameDifficulty? difficulty,
    Set<String>? triggeredEvents,
  }) {
    return WaterMarginGameState(
      provinces: provinces ?? this.provinces,
      heroes: heroes ?? this.heroes,
      factions: factions ?? this.factions,
      currentTurn: currentTurn ?? this.currentTurn,
      playerGold: playerGold ?? this.playerGold,
      gameStatus: gameStatus ?? this.gameStatus,
      selectedProvinceId: selectedProvinceId ?? this.selectedProvinceId,
      selectedHeroId: selectedHeroId ?? this.selectedHeroId,
      diplomacy: diplomacy ?? this.diplomacy,
      difficulty: difficulty ?? this.difficulty,
      triggeredEvents: triggeredEvents ?? this.triggeredEvents,
    );
  }

  /// プレイヤーが支配する州数
  int get playerProvinceCount => provinces.values.where((p) => p.controller == Faction.liangshan).length;

  /// プレイヤーの総兵力
  int get playerTotalTroops =>
      provinces.values.where((p) => p.controller == Faction.liangshan).fold(0, (sum, p) => sum + p.currentTroops);

  /// 仲間になった英雄数
  int get recruitedHeroCount => heroes.where((h) => h.isRecruited).length;

  /// 選択された州
  Province? get selectedProvince {
    if (selectedProvinceId == null) return null;
    return provinces[selectedProvinceId];
  }

  /// 選択された英雄
  Hero? get selectedHero {
    if (selectedHeroId == null) return null;
    try {
      return heroes.firstWhere((h) => h.id == selectedHeroId);
    } catch (e) {
      return null;
    }
  }

  /// 指定された州を取得
  Province? getProvinceById(String id) {
    return provinces[id];
  }

  /// 指定された英雄を取得
  Hero? getHeroById(String id) {
    try {
      return heroes.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// JSON変換用のtoJsonメソッド
  Map<String, dynamic> toJson() {
    return {
      'provinces': provinces.map((key, value) => MapEntry(key, value.toJson())),
      'heroes': heroes.map((hero) => hero.toJson()).toList(),
      'factions': factions.map((key, value) => MapEntry(key, value.name)),
      'currentTurn': currentTurn,
      'playerGold': playerGold,
      'gameStatus': gameStatus.name,
      'selectedProvinceId': selectedProvinceId,
      'selectedHeroId': selectedHeroId,
      'diplomacy': diplomacy?.toJson(),
    };
  }

  /// JSONからのfromJsonファクトリコンストラクタ
  factory WaterMarginGameState.fromJson(Map<String, dynamic> json) {
    final provincesJson = json['provinces'] ?? <String, dynamic>{};
    final provinces = <String, Province>{};

    for (final entry in provincesJson.entries) {
      provinces[entry.key] = Province.fromJson(entry.value);
    }

    final heroesJson = json['heroes'] ?? <dynamic>[];
    final heroes = heroesJson.map<Hero>((heroJson) => Hero.fromJson(heroJson)).toList();

    final factionsJson = json['factions'] ?? <String, dynamic>{};
    final factions = <String, Faction>{};

    for (final entry in factionsJson.entries) {
      factions[entry.key] = Faction.values.firstWhere(
        (e) => e.name == entry.value,
        orElse: () => Faction.neutral,
      );
    }

    return WaterMarginGameState(
      provinces: provinces,
      heroes: heroes,
      factions: factions,
      currentTurn: json['currentTurn'] ?? 1,
      playerGold: json['playerGold'] ?? 1000,
      gameStatus: GameStatus.values.firstWhere(
        (e) => e.name == json['gameStatus'],
        orElse: () => GameStatus.playing,
      ),
      selectedProvinceId: json['selectedProvinceId'],
      selectedHeroId: json['selectedHeroId'],
      diplomacy: json['diplomacy'] != null ? DiplomacySystem.fromJson(json['diplomacy']) : null,
    );
  }
}

/// ゲームの状態
enum GameStatus {
  playing, // ゲーム中
  victory, // 勝利
  defeat, // 敗北
  paused, // 一時停止
}

/// Faction拡張
extension FactionExtension on Faction {
  /// 勢力の色
  Color get factionColor {
    switch (this) {
      case Faction.liangshan:
        return Colors.green;
      case Faction.imperial:
        return Colors.purple;
      case Faction.warlord:
        return Colors.red;
      case Faction.bandit:
        return Colors.orange;
      case Faction.neutral:
        return Colors.grey;
    }
  }

  /// 勢力の表示名
  String get displayName {
    switch (this) {
      case Faction.liangshan:
        return '梁山泊';
      case Faction.imperial:
        return '宋朝廷';
      case Faction.warlord:
        return '豪族';
      case Faction.bandit:
        return '盗賊';
      case Faction.neutral:
        return '中立';
    }
  }
}

/// Province拡張
extension ProvinceExtension on Province {
  /// 支配勢力の色
  Color get factionColor {
    return controller.factionColor;
  }
}

/// AIシステムとの互換性のためのGameStateエイリアス
typedef GameState = WaterMarginGameState;
