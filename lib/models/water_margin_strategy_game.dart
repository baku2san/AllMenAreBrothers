/// 水滸伝戦略ゲーム専用モデル
/// フェーズ1: 基盤システム（マップ表示とUI基盤、基本的な英雄・勢力データ、シンプルな内政システム）
library;

import 'package:flutter/material.dart';

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
  });

  final int population; // 人口（1-1000万人）
  final int agriculture; // 農業度（1-100）
  final int commerce; // 商業度（1-100）
  final int security; // 治安（1-100）
  final int military; // 軍事力（1-100）
  final int loyalty; // 民心（1-100、高いほど支持）

  ProvinceState copyWith({
    int? population,
    int? agriculture,
    int? commerce,
    int? security,
    int? military,
    int? loyalty,
  }) {
    return ProvinceState(
      population: population ?? this.population,
      agriculture: agriculture ?? this.agriculture,
      commerce: commerce ?? this.commerce,
      security: security ?? this.security,
      military: military ?? this.military,
      loyalty: loyalty ?? this.loyalty,
    );
  }

  /// 州の総合評価
  int get overallRating => ((agriculture + commerce + security + military + loyalty) / 5).round();

  /// 食料生産量（人口 x 農業度）
  int get foodProduction => ((population / 100) * agriculture).round();

  /// 税収（人口 x 商業度）
  int get taxIncome => ((population / 100) * commerce).round();

  /// 兵力上限（人口 x 軍事力）
  int get maxTroops => ((population / 50) * military).round();
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
  });

  final Map<String, Province> provinces; // Mapに変更してAIシステムと互換性を持つ
  final List<Hero> heroes;
  final Map<String, Faction> factions; // 勢力管理
  final int currentTurn;
  final int playerGold;
  final GameStatus gameStatus;
  final String? selectedProvinceId;
  final String? selectedHeroId;

  WaterMarginGameState copyWith({
    Map<String, Province>? provinces,
    List<Hero>? heroes,
    Map<String, Faction>? factions,
    int? currentTurn,
    int? playerGold,
    GameStatus? gameStatus,
    String? selectedProvinceId,
    String? selectedHeroId,
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
