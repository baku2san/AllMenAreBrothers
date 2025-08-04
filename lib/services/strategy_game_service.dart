/// 水滸伝戦略ゲームのメインサービス
/// ゲームロジック、ターン管理、AI処理を統合
library;

import 'dart:math';
import '../models/water_margin_strategy_game.dart';
import '../models/province.dart';
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
    // 新 Province モデルのみで初期化
    final provinces = <String, Province>{
      'liangshan': Province(
        name: '梁山泊',
        population: 50000,
        agriculture: 60,
        commerce: 40,
        security: 0.8,
        publicSupport: 0.9,
        military: 70,
        resources: [
          Resource(type: ResourceType.rice, baseYield: 100, demand: 1.0, price: 1.0),
        ],
        development: 50,
      ),
      'jizhou': Province(
        name: '済州',
        population: 80000,
        agriculture: 70,
        commerce: 60,
        security: 0.5,
        publicSupport: 0.3,
        military: 60,
        resources: [
          Resource(type: ResourceType.salt, baseYield: 80, demand: 1.2, price: 1.1),
        ],
        development: 40,
      ),
      'yunzhou': Province(
        name: '鄆州',
        population: 60000,
        agriculture: 50,
        commerce: 80,
        security: 0.4,
        publicSupport: 0.6,
        military: 50,
        resources: [
          Resource(type: ResourceType.iron, baseYield: 60, demand: 1.3, price: 1.2),
        ],
        development: 35,
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
    // 収入計算（新設計：ProvinceモデルのtaxIncomeメソッドを直接呼び出し）
    final playerProvinces = gameState.provinces.values.where((p) => gameState.factions[p.name] == Faction.liangshan);

    double income = 0;
    for (final province in playerProvinces) {
      income += province.taxIncome();
    }

    return gameState.copyWith(
      playerGold: gameState.playerGold + income.round(),
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
      faction: gameState.factions[sourceProvince.name] ?? Faction.neutral,
      troops: sourceProvince.military.round(),
      heroes: _getHeroesInProvince(gameState, action.sourceProvinceId),
      province: sourceProvince,
    );

    final defender = BattleParticipant(
      faction: gameState.factions[targetProvince.name] ?? Faction.neutral,
      troops: targetProvince.military.round(),
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

    Province updatedProvince;
    switch (action.developmentType!) {
      case DevelopmentType.agriculture:
        updatedProvince = province.copyWith(
          agriculture: (province.agriculture + 5),
        );
        break;
      case DevelopmentType.commerce:
        updatedProvince = province.copyWith(
          commerce: (province.commerce + 5),
        );
        break;
      case DevelopmentType.military:
        updatedProvince = province.copyWith(
          military: (province.military + 5),
        );
        break;
      case DevelopmentType.security:
        updatedProvince = province.copyWith(
          security: (province.security + 0.05).clamp(0.0, 1.0),
        );
        break;
    }

    final updatedProvinces = Map<String, Province>.from(gameState.provinces);
    updatedProvinces[action.sourceProvinceId] = updatedProvince;

    return gameState.copyWith(provinces: updatedProvinces);
  }

  /// 徴兵実行
  WaterMarginGameState _executeRecruitment(WaterMarginGameState gameState, AIAction action) {
    final province = gameState.provinces[action.sourceProvinceId];
    if (province == null) return gameState;

    final newTroops = province.military + 100;
    final updatedProvince = province.copyWith(military: newTroops);
    final updatedProvinces = Map<String, Province>.from(gameState.provinces);
    updatedProvinces[action.sourceProvinceId] = updatedProvince;

    return gameState.copyWith(provinces: updatedProvinces);
  }

  /// 要塞化実行
  WaterMarginGameState _executeFortification(WaterMarginGameState gameState, AIAction action) {
    final province = gameState.provinces[action.sourceProvinceId];
    if (province == null) return gameState;

    // 新モデルに garrison フィールドが無い場合は development を仮利用
    final newDevelopment = province.development + 5;
    final updatedProvince = province.copyWith(development: newDevelopment);
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
      final newPopulation = (province.population * 1.01).round(); // 1%の人口増加
      updatedProvinces[entry.key] = province.copyWith(population: newPopulation);
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
    final playerProvinces =
        gameState.provinces.values.where((p) => gameState.factions[p.name] == Faction.liangshan).length;

    // 全州の70%を支配で勝利
    if (playerProvinces >= gameState.provinces.length * 0.7) {
      return gameState.copyWith(gameStatus: GameStatus.victory);
    }

    // 梁山泊を失ったら敗北
    final liangshan = gameState.provinces['梁山泊'];
    if (liangshan == null || gameState.factions[liangshan.name] != Faction.liangshan) {
      return gameState.copyWith(gameStatus: GameStatus.defeat);
    }

    return gameState;
  }

  /// 指定した州にいる英雄を取得
  List<Hero> _getHeroesInProvince(WaterMarginGameState gameState, String provinceId) {
    return gameState.heroes.where((h) => h.currentProvinceId == provinceId && h.isRecruited).toList();
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
      military: (sourceProvince.military - result.attackerLosses).clamp(0, 999999),
    );

    // 防御側の損失を反映
    if (action.targetProvinceId != null) {
      final targetProvince = updatedProvinces[action.targetProvinceId!]!;
      updatedProvinces[action.targetProvinceId!] = targetProvince.copyWith(
        military: (targetProvince.military - result.defenderLosses).clamp(0, 999999),
        // 勢力変更は factions マップ側で処理する必要あり（ここでは省略）
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
