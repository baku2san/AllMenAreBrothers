/// 州の施設建設システム
library;

import 'package:flutter/foundation.dart';

/// 施設の種類
enum FacilityType {
  // 軍事施設
  barracks, // 兵舎
  armory, // 武器庫
  watchtower, // 見張り台
  fortress, // 要塞

  // 経済施設
  market, // 市場
  warehouse, // 倉庫
  workshop, // 工房
  mine, // 鉱山

  // 文化施設
  academy, // 学院
  temple, // 神社
  library, // 図書館

  // 特殊施設
  docks, // 港湾
  embassy, // 外交館
  spyNetwork, // 諜報網
}

/// 資源の種類
enum ResourceType {
  population, // 人口
  food, // 食料
  wood, // 木材
  iron, // 鉄
  gold, // 金
  culture, // 文化値
  military, // 軍事力
}

/// 施設クラス
@immutable
class Facility {
  const Facility({
    required this.type,
    required this.name,
    required this.emoji,
    required this.description,
    required this.level,
    required this.maxLevel,
    required this.buildCost,
    required this.upkeepCost,
    required this.buildTime,
    required this.effects,
    this.unlockRequirements = const {},
    this.specialEffects = const {},
  });

  final FacilityType type;
  final String name;
  final String emoji;
  final String description;
  final int level;
  final int maxLevel;
  final Map<ResourceType, int> buildCost;
  final Map<ResourceType, int> upkeepCost;
  final int buildTime; // ターン数
  final Map<ResourceType, int> effects; // 毎ターンの効果
  final Map<ResourceType, int> unlockRequirements;
  final Map<String, double> specialEffects; // 特殊効果

  /// 施設をアップグレード
  Facility upgrade() {
    if (level >= maxLevel) return this;
    
    return copyWith(level: level + 1);
  }

  /// 施設をコピーして更新
  Facility copyWith({
    FacilityType? type,
    String? name,
    String? emoji,
    String? description,
    int? level,
    int? maxLevel,
    Map<ResourceType, int>? buildCost,
    Map<ResourceType, int>? upkeepCost,
    int? buildTime,
    Map<ResourceType, int>? effects,
    Map<ResourceType, int>? unlockRequirements,
    Map<String, double>? specialEffects,
  }) {
    return Facility(
      type: type ?? this.type,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      buildCost: buildCost ?? this.buildCost,
      upkeepCost: upkeepCost ?? this.upkeepCost,
      buildTime: buildTime ?? this.buildTime,
      effects: effects ?? this.effects,
      unlockRequirements: unlockRequirements ?? this.unlockRequirements,
      specialEffects: specialEffects ?? this.specialEffects,
    );
  }

  /// 建設費用（レベルに応じて増加）
  Map<ResourceType, int> get currentBuildCost {
    return buildCost.map((resource, cost) => 
        MapEntry(resource, (cost * (1 + level * 0.5)).round()));
  }

  /// 現在レベルでの効果
  Map<ResourceType, int> get currentEffects {
    return effects.map((resource, effect) => 
        MapEntry(resource, (effect * level).round()));
  }

  /// アップグレード可能かチェック
  bool get canUpgrade => level < maxLevel;
}

/// 建設中の施設
@immutable
class FacilityConstruction {
  const FacilityConstruction({
    required this.facilityType,
    required this.remainingTurns,
    required this.totalTurns,
  });

  final FacilityType facilityType;
  final int remainingTurns;
  final int totalTurns;

  /// 建設進行度（0.0-1.0）
  double get progress => (totalTurns - remainingTurns) / totalTurns;

  /// 建設完了かチェック
  bool get isCompleted => remainingTurns <= 0;

  /// ターン進行
  FacilityConstruction progressTurn() {
    return FacilityConstruction(
      facilityType: facilityType,
      remainingTurns: (remainingTurns - 1).clamp(0, totalTurns),
      totalTurns: totalTurns,
    );
  }
}

/// 州の施設管理クラス
@immutable
class ProvinceFacilities {
  const ProvinceFacilities({
    this.facilities = const [],
    this.constructionQueue = const [],
  });

  final List<Facility> facilities;
  final List<FacilityConstruction> constructionQueue;

  /// 施設をコピーして更新
  ProvinceFacilities copyWith({
    List<Facility>? facilities,
    List<FacilityConstruction>? constructionQueue,
  }) {
    return ProvinceFacilities(
      facilities: facilities ?? this.facilities,
      constructionQueue: constructionQueue ?? this.constructionQueue,
    );
  }

  /// 指定タイプの施設を取得
  Facility? getFacility(FacilityType type) {
    try {
      return facilities.firstWhere((f) => f.type == type);
    } catch (e) {
      return null;
    }
  }

  /// 施設を追加
  ProvinceFacilities addFacility(Facility facility) {
    return copyWith(facilities: [...facilities, facility]);
  }

  /// 施設をアップグレード
  ProvinceFacilities upgradeFacility(FacilityType type) {
    final updatedFacilities = facilities.map((f) => 
        f.type == type ? f.upgrade() : f).toList();
    return copyWith(facilities: updatedFacilities);
  }

  /// 建設をキューに追加
  ProvinceFacilities addToConstructionQueue(FacilityConstruction construction) {
    return copyWith(constructionQueue: [...constructionQueue, construction]);
  }

  /// 建設を進行
  ProvinceFacilities progressConstruction() {
    final updatedQueue = <FacilityConstruction>[];
    final newFacilities = <Facility>[];

    for (final construction in constructionQueue) {
      final progressed = construction.progressTurn();
      
      if (progressed.isCompleted) {
        // 建設完了 - 新しい施設を追加
        final newFacility = _createCompletedFacility(construction.facilityType);
        if (newFacility != null) {
          newFacilities.add(newFacility);
        }
      } else {
        // 建設継続
        updatedQueue.add(progressed);
      }
    }

    return copyWith(
      facilities: [...facilities, ...newFacilities],
      constructionQueue: updatedQueue,
    );
  }

  /// 総合効果を計算
  Map<ResourceType, int> getTotalEffects() {
    final totalEffects = <ResourceType, int>{};
    
    for (final facility in facilities) {
      for (final effect in facility.currentEffects.entries) {
        totalEffects[effect.key] = (totalEffects[effect.key] ?? 0) + effect.value;
      }
    }
    
    return totalEffects;
  }

  /// 総維持費を計算
  Map<ResourceType, int> getTotalUpkeep() {
    final totalUpkeep = <ResourceType, int>{};
    
    for (final facility in facilities) {
      for (final cost in facility.upkeepCost.entries) {
        totalUpkeep[cost.key] = (totalUpkeep[cost.key] ?? 0) + cost.value;
      }
    }
    
    return totalUpkeep;
  }

  /// 施設が存在するかチェック
  bool hasFacility(FacilityType type) {
    return facilities.any((f) => f.type == type);
  }

  /// 施設建設中かチェック
  bool isUnderConstruction(FacilityType type) {
    return constructionQueue.any((c) => c.facilityType == type);
  }

  /// 建設完了時の施設を作成
  Facility? _createCompletedFacility(FacilityType type) {
    switch (type) {
      case FacilityType.barracks:
        return const Facility(
          type: FacilityType.barracks,
          name: '兵舎',
          emoji: '🏭',
          description: '兵士の訓練と駐屯を行う施設',
          level: 1,
          maxLevel: 5,
          buildCost: {
            ResourceType.wood: 50,
            ResourceType.iron: 30,
            ResourceType.gold: 100,
          },
          upkeepCost: {
            ResourceType.food: 5,
            ResourceType.gold: 10,
          },
          buildTime: 3,
          effects: {
            ResourceType.military: 20,
          },
          specialEffects: {
            'recruitment_bonus': 1.2,
          },
        );
      
      case FacilityType.market:
        return const Facility(
          type: FacilityType.market,
          name: '市場',
          emoji: '🏪',
          description: '商業活動の中心地',
          level: 1,
          maxLevel: 4,
          buildCost: {
            ResourceType.wood: 30,
            ResourceType.gold: 80,
          },
          upkeepCost: {
            ResourceType.gold: 5,
          },
          buildTime: 2,
          effects: {
            ResourceType.gold: 15,
          },
          specialEffects: {
            'trade_bonus': 1.15,
          },
        );
      
      case FacilityType.academy:
        return const Facility(
          type: FacilityType.academy,
          name: '学院',
          emoji: '🏫',
          description: '知識と文化の拠点',
          level: 1,
          maxLevel: 3,
          buildCost: {
            ResourceType.wood: 40,
            ResourceType.gold: 120,
          },
          upkeepCost: {
            ResourceType.gold: 8,
          },
          buildTime: 4,
          effects: {
            ResourceType.culture: 25,
          },
          unlockRequirements: {
            ResourceType.population: 1000,
          },
          specialEffects: {
            'hero_experience_bonus': 1.25,
          },
        );
      
      // 他の施設タイプも同様に実装
      default:
        return null;
    }
  }
}
