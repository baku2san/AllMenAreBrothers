/// 水滸伝戦略ゲームのメインサービス
/// ゲームロジック、ターン管理、AI処理を統合
library;

import 'dart:math';
import 'package:flutter/material.dart' hide Hero;
import '../models/water_margin_strategy_game.dart';
import '../models/ai_system.dart';
import '../models/game_events.dart';
import '../models/advanced_battle_system.dart';

/// 水滸伝戦略ゲームサービス
class WaterMarginGameService {
  WaterMarginGameService() {
    _random = Random();
    _triggeredEvents = <String>{};
  }

  late Random _random;
  late Set<String> _triggeredEvents;

  /// ゲーム初期化
  WaterMarginGameState initializeGame() {
    // 初期の州データを作成（簡略版）
    final provinces = <String, Province>{
      'liangshan': const Province(
        id: 'liangshan',
        name: '梁山泊',
        position: Offset(2, 2),
        controller: Faction.liangshan,
        state: ProvinceState(
          population: 50,
          agriculture: 60,
          commerce: 40,
          security: 80,
          military: 70,
          loyalty: 90,
        ),
        currentTroops: 1000,
        adjacentProvinceIds: ['jizhou', 'yunzhou'],
        capital: true,
        garrison: 500,
      ),
      'jizhou': const Province(
        id: 'jizhou',
        name: '済州',
        position: Offset(1, 2),
        controller: Faction.imperial,
        state: ProvinceState(
          population: 80,
          agriculture: 70,
          commerce: 60,
          security: 50,
          military: 60,
          loyalty: 30,
        ),
        currentTroops: 800,
        adjacentProvinceIds: ['liangshan', 'yunzhou', 'jeongzhou'],
        garrison: 300,
      ),
      'yunzhou': const Province(
        id: 'yunzhou',
        name: '鄆州',
        position: Offset(3, 2),
        controller: Faction.warlord,
        state: ProvinceState(
          population: 60,
          agriculture: 50,
          commerce: 80,
          security: 40,
          military: 50,
          loyalty: 60,
        ),
        currentTroops: 600,
        adjacentProvinceIds: ['liangshan', 'jizhou'],
        garrison: 200,
      ),
    };

    // 初期の英雄データ（簡略版）
    final heroes = <Hero>[
      const Hero(
        id: 'song_jiang',
        name: '宋江',
        nickname: '及時雨',
        stats: HeroStats(
          force: 60,
          intelligence: 85,
          charisma: 95,
          leadership: 90,
          loyalty: 100,
        ),
        skill: HeroSkill.diplomat,
        faction: Faction.liangshan,
        isRecruited: true,
        currentProvinceId: 'liangshan',
      ),
      const Hero(
        id: 'wu_song',
        name: '武松',
        nickname: '行者',
        stats: HeroStats(
          force: 95,
          intelligence: 70,
          charisma: 75,
          leadership: 80,
          loyalty: 85,
        ),
        skill: HeroSkill.warrior,
        faction: Faction.liangshan,
        isRecruited: false,
      ),
    ];

    // 勢力データ
    final factions = <String, Faction>{
      'liangshan': Faction.liangshan,
      'imperial': Faction.imperial,
      'warlord': Faction.warlord,
      'bandit': Faction.bandit,
      'neutral': Faction.neutral,
    };

    return WaterMarginGameState(
      provinces: provinces,
      heroes: heroes,
      factions: factions,
      currentTurn: 1,
      playerGold: 1000,
      gameStatus: GameStatus.playing,
    );
  }

  /// ターン終了処理
  WaterMarginGameState processTurn(WaterMarginGameState gameState) {
    var newGameState = gameState;

    // 1. プレイヤーフェーズの処理結果を反映
    newGameState = _processPlayerPhase(newGameState);

    // 2. AI勢力のターン
    newGameState = _processAITurns(newGameState);

    // 3. ターン終了処理
    newGameState = _processEndOfTurn(newGameState);

    // 4. イベント発生チェック
    newGameState = _processRandomEvents(newGameState);

    // 5. 勝利条件チェック
    newGameState = _checkVictoryConditions(newGameState);

    // 6. ターン数増加
    newGameState = newGameState.copyWith(
      currentTurn: newGameState.currentTurn + 1,
    );

    return newGameState;
  }

  /// プレイヤーフェーズ処理
  WaterMarginGameState _processPlayerPhase(WaterMarginGameState gameState) {
    // プレイヤーの行動結果を処理
    // 収入計算
    final playerProvinces = gameState.provinces.values
        .where((p) => p.controller == Faction.liangshan);
    
    int income = 0;
    for (final province in playerProvinces) {
      income += province.state.taxIncome;
    }

    return gameState.copyWith(
      playerGold: gameState.playerGold + income,
    );
  }

  /// AI勢力のターン処理
  WaterMarginGameState _processAITurns(WaterMarginGameState gameState) {
    var newGameState = gameState;

    // 各AI勢力のターンを処理
    for (final factionId in ['imperial', 'warlord', 'bandit']) {
      final aiSystem = AISystemFactory.createAI(factionId);
      final aiResult = aiSystem.think(newGameState);
      
      // AI行動を実行
      newGameState = _executeAIAction(newGameState, aiResult.chosenAction);
    }

    return newGameState;
  }

  /// AI行動を実行
  WaterMarginGameState _executeAIAction(WaterMarginGameState gameState, AIAction action) {
    switch (action.type) {
      case AIActionType.attack:
        return _executeAttack(gameState, action);
      case AIActionType.develop:
        return _executeDevelopment(gameState, action);
      case AIActionType.recruit:
        return _executeRecruitment(gameState, action);
      case AIActionType.fortify:
        return _executeFortification(gameState, action);
      default:
        return gameState;
    }
  }

  /// 攻撃実行
  WaterMarginGameState _executeAttack(WaterMarginGameState gameState, AIAction action) {
    final sourceProvince = gameState.provinces[action.sourceProvinceId];
    final targetProvince = gameState.provinces[action.targetProvinceId];
    
    if (sourceProvince == null || targetProvince == null) return gameState;

    // 戦闘参加者を作成
    final attacker = BattleParticipant(
      faction: sourceProvince.controller,
      troops: sourceProvince.currentTroops,
      heroes: _getHeroesInProvince(gameState, action.sourceProvinceId),
      province: sourceProvince,
    );

    final defender = BattleParticipant(
      faction: targetProvince.controller,
      troops: targetProvince.currentTroops,
      heroes: _getHeroesInProvince(gameState, action.targetProvinceId!),
      province: targetProvince,
    );

    // 戦闘実行
    final battleResult = AdvancedBattleSystem.conductBattle(
      attacker: attacker,
      defender: defender,
      battleType: BattleType.fieldBattle,
      terrain: BattleTerrain.plains,
    );

    // 戦闘結果を反映
    return _applyBattleResult(gameState, battleResult, action);
  }

  /// 開発実行
  WaterMarginGameState _executeDevelopment(WaterMarginGameState gameState, AIAction action) {
    final province = gameState.provinces[action.sourceProvinceId];
    if (province == null || action.developmentType == null) return gameState;

    final newState = province.state;
    ProvinceState updatedState;

    switch (action.developmentType!) {
      case DevelopmentType.agriculture:
        updatedState = newState.copyWith(
          agriculture: (newState.agriculture + 5).clamp(0, 100),
        );
        break;
      case DevelopmentType.commerce:
        updatedState = newState.copyWith(
          commerce: (newState.commerce + 5).clamp(0, 100),
        );
        break;
      case DevelopmentType.military:
        updatedState = newState.copyWith(
          military: (newState.military + 5).clamp(0, 100),
        );
        break;
      case DevelopmentType.security:
        updatedState = newState.copyWith(
          security: (newState.security + 5).clamp(0, 100),
        );
        break;
    }

    final updatedProvince = province.copyWith(state: updatedState);
    final updatedProvinces = Map<String, Province>.from(gameState.provinces);
    updatedProvinces[action.sourceProvinceId] = updatedProvince;

    return gameState.copyWith(provinces: updatedProvinces);
  }

  /// 徴兵実行
  WaterMarginGameState _executeRecruitment(WaterMarginGameState gameState, AIAction action) {
    final province = gameState.provinces[action.sourceProvinceId];
    if (province == null) return gameState;

    final newTroops = province.currentTroops + 100;
    final updatedProvince = province.copyWith(currentTroops: newTroops);
    final updatedProvinces = Map<String, Province>.from(gameState.provinces);
    updatedProvinces[action.sourceProvinceId] = updatedProvince;

    return gameState.copyWith(provinces: updatedProvinces);
  }

  /// 要塞化実行
  WaterMarginGameState _executeFortification(WaterMarginGameState gameState, AIAction action) {
    final province = gameState.provinces[action.sourceProvinceId];
    if (province == null) return gameState;

    final newGarrison = province.garrison + 50;
    final updatedProvince = province.copyWith(garrison: newGarrison);
    final updatedProvinces = Map<String, Province>.from(gameState.provinces);
    updatedProvinces[action.sourceProvinceId] = updatedProvince;

    return gameState.copyWith(provinces: updatedProvinces);
  }

  /// ターン終了処理
  WaterMarginGameState _processEndOfTurn(WaterMarginGameState gameState) {
    var newGameState = gameState;

    // 各州の自然増加処理
    final updatedProvinces = <String, Province>{};
    for (final entry in gameState.provinces.entries) {
      final province = entry.value;
      final newState = province.state.copyWith(
        population: (province.state.population * 1.01).round(), // 1%の人口増加
      );
      updatedProvinces[entry.key] = province.copyWith(state: newState);
    }

    newGameState = newGameState.copyWith(provinces: updatedProvinces);

    return newGameState;
  }

  /// ランダムイベント処理
  WaterMarginGameState _processRandomEvents(WaterMarginGameState gameState) {
    // 20%の確率でイベント発生
    if (_random.nextDouble() < 0.2) {
      final event = GameEventSystem.getRandomEvent(gameState, _triggeredEvents);
      if (event != null) {
        _triggeredEvents.add(event.id);
        // イベント処理は後で実装
        // TODO: イベントUI表示とプレイヤー選択処理
      }
    }

    return gameState;
  }

  /// 勝利条件チェック
  WaterMarginGameState _checkVictoryConditions(WaterMarginGameState gameState) {
    final playerProvinces = gameState.provinces.values
        .where((p) => p.controller == Faction.liangshan)
        .length;
    
    // 全州の70%を支配で勝利
    if (playerProvinces >= gameState.provinces.length * 0.7) {
      return gameState.copyWith(gameStatus: GameStatus.victory);
    }

    // 梁山泊を失ったら敗北
    final liangshan = gameState.provinces['liangshan'];
    if (liangshan?.controller != Faction.liangshan) {
      return gameState.copyWith(gameStatus: GameStatus.defeat);
    }

    return gameState;
  }

  /// 指定した州にいる英雄を取得
  List<Hero> _getHeroesInProvince(WaterMarginGameState gameState, String provinceId) {
    return gameState.heroes
        .where((h) => h.currentProvinceId == provinceId && h.isRecruited)
        .toList();
  }

  /// 戦闘結果を適用
  WaterMarginGameState _applyBattleResult(
    WaterMarginGameState gameState,
    AdvancedBattleResult result,
    AIAction action,
  ) {
    final updatedProvinces = Map<String, Province>.from(gameState.provinces);
    
    // 攻撃側の損失を反映
    final sourceProvince = updatedProvinces[action.sourceProvinceId]!;
    updatedProvinces[action.sourceProvinceId] = sourceProvince.copyWith(
      currentTroops: (sourceProvince.currentTroops - result.attackerLosses).clamp(0, 999999),
    );

    // 防御側の損失を反映
    if (action.targetProvinceId != null) {
      final targetProvince = updatedProvinces[action.targetProvinceId!]!;
      updatedProvinces[action.targetProvinceId!] = targetProvince.copyWith(
        currentTroops: (targetProvince.currentTroops - result.defenderLosses).clamp(0, 999999),
        controller: result.territoryConquered ? sourceProvince.controller : targetProvince.controller,
      );
    }

    return gameState.copyWith(provinces: updatedProvinces);
  }

  /// プレイヤーの攻撃を実行
  WaterMarginGameState executePlayerAttack(
    WaterMarginGameState gameState,
    String sourceProvinceId,
    String targetProvinceId,
  ) {
    final action = AIAction(
      type: AIActionType.attack,
      priority: 100,
      sourceProvinceId: sourceProvinceId,
      targetProvinceId: targetProvinceId,
    );

    return _executeAttack(gameState, action);
  }

  /// プレイヤーの開発を実行
  WaterMarginGameState executePlayerDevelopment(
    WaterMarginGameState gameState,
    String provinceId,
    DevelopmentType developmentType,
  ) {
    final cost = _getDevelopmentCost(developmentType);
    if (gameState.playerGold < cost) return gameState;

    final action = AIAction(
      type: AIActionType.develop,
      priority: 100,
      sourceProvinceId: provinceId,
      developmentType: developmentType,
    );

    final result = _executeDevelopment(gameState, action);
    return result.copyWith(
      playerGold: result.playerGold - cost,
    );
  }

  /// 開発コストを取得
  int _getDevelopmentCost(DevelopmentType type) {
    switch (type) {
      case DevelopmentType.agriculture:
        return 100;
      case DevelopmentType.commerce:
        return 150;
      case DevelopmentType.military:
        return 200;
      case DevelopmentType.security:
        return 120;
    }
  }
}
