/// 水滸伝戦略ゲームのコントローラー
/// フェーズ1: 基本的なゲーム状態管理とUI操作
library;

import 'dart:math';
import 'package:flutter/material.dart' hide Hero;

import '../data/water_margin_map.dart';
import '../data/water_margin_heroes.dart';
import '../models/water_margin_strategy_game.dart';
import '../models/advanced_battle_system.dart';
import '../services/game_save_service.dart';
import '../core/app_config.dart';
import '../utils/app_utils.dart';

/// 水滸伝戦略ゲームのメインコントローラー
class WaterMarginGameController extends ChangeNotifier {
  /// コンストラクタ
  WaterMarginGameController();

  /// ゲーム状態
  WaterMarginGameState _gameState = WaterMarginGameState(
    provinces: const {},
    heroes: const [],
    factions: const {},
    currentTurn: 1,
    playerGold: AppConstants.initialPlayerGold,
    gameStatus: GameStatus.playing,
  );

  /// イベントログ
  List<String> _eventLog = [];

  /// 現在のゲーム状態を取得
  WaterMarginGameState get gameState => _gameState;

  /// イベントログを取得
  List<String> get eventLog => List.unmodifiable(_eventLog);

  /// 選択された州のIDを取得
  String? get selectedProvinceId => _gameState.selectedProvinceId;

  /// 選択された州を取得
  Province? get selectedProvince {
    if (_gameState.selectedProvinceId == null) return null;
    return _gameState.provinces[_gameState.selectedProvinceId!];
  }

  /// ゲームを初期化
  void initializeGame() {
    try {
      _gameState = WaterMarginGameState(
        provinces: WaterMarginMap.initialProvinces,
        heroes: WaterMarginHeroes.initialHeroes,
        factions: {
          'liangshan': Faction.liangshan,
          'imperial': Faction.imperial,
          'warlord': Faction.warlord,
          'bandit': Faction.bandit,
          'neutral': Faction.neutral,
        },
        currentTurn: 1,
        playerGold: AppConstants.initialPlayerGold,
        gameStatus: GameStatus.playing,
      );

      _eventLog.clear();
      _addEventLog('新しいゲームを開始しました');

      notifyListeners();
    } catch (e) {
      // データファイルが存在しない場合のフォールバック
      _gameState = WaterMarginGameState(
        provinces: const {},
        heroes: const [],
        factions: const {},
        currentTurn: 1,
        playerGold: AppConstants.initialPlayerGold,
        gameStatus: GameStatus.playing,
      );
      _addEventLog('ゲームデータの読み込みに失敗しました');
      notifyListeners();
    }
  }

  /// 州を選択
  void selectProvince(String? provinceId) {
    _gameState = _gameState.copyWith(
      selectedProvinceId: provinceId,
    );
    notifyListeners();
  }

  /// 選択をクリア
  void clearSelection() {
    _gameState = _gameState.copyWith(
      selectedProvinceId: null,
    );
    notifyListeners();
  }

  /// ターン終了
  void endTurn() {
    if (_gameState.gameStatus != GameStatus.playing) return;

    // ターン処理
    final income = getTotalIncome();

    _gameState = _gameState.copyWith(
      currentTurn: _gameState.currentTurn + 1,
      playerGold: _gameState.playerGold + income,
    );

    // オートセーブを実行
    autoSave();

    _addEventLog('ターン${_gameState.currentTurn}が開始されました（収入: $income両）');
    notifyListeners();
  }

  /// 州を開発
  void developProvince(String provinceId, DevelopmentType type) {
    final province = _gameState.provinces[provinceId];
    if (province == null || province.controller != Faction.liangshan) return;

    const cost = AppConstants.developmentCost; // 開発コスト
    if (_gameState.playerGold < cost) {
      _addEventLog('資金が不足しています');
      return;
    }

    final updatedProvinces = Map<String, Province>.from(_gameState.provinces);
    var newState = province.state;

    switch (type) {
      case DevelopmentType.agriculture:
        newState = newState.copyWith(
          agriculture: NumberUtils.clampInt(newState.agriculture + 10, 0, AppConstants.maxDevelopmentLevel),
        );
        _addEventLog('${province.name}の農業を発展させました');
        break;
      case DevelopmentType.commerce:
        newState = newState.copyWith(
          commerce: NumberUtils.clampInt(newState.commerce + 10, 0, AppConstants.maxDevelopmentLevel),
        );
        _addEventLog('${province.name}の商業を発展させました');
        break;
      case DevelopmentType.military:
        newState = newState.copyWith(
          military: NumberUtils.clampInt(newState.military + 10, 0, AppConstants.maxDevelopmentLevel),
        );
        _addEventLog('${province.name}の軍事を強化しました');
        break;
      case DevelopmentType.security:
        newState = newState.copyWith(
          security: NumberUtils.clampInt(newState.security + 10, 0, AppConstants.maxDevelopmentLevel),
        );
        _addEventLog('${province.name}の治安を改善しました');
        break;
    }

    updatedProvinces[provinceId] = province.copyWith(state: newState);

    _gameState = _gameState.copyWith(
      provinces: updatedProvinces,
      playerGold: _gameState.playerGold - cost,
    );

    notifyListeners();
  }

  /// 徴兵
  void recruitTroops(String provinceId, int amount) {
    final province = _gameState.provinces[provinceId];
    if (province == null || province.controller != Faction.liangshan) return;

    final cost = amount * AppConstants.recruitmentCostPerTroop; // 兵士1人につき10両
    if (_gameState.playerGold < cost) {
      _addEventLog('徴兵に必要な資金が不足しています');
      return;
    }

    final maxRecruits = province.state.maxTroops - province.currentTroops;
    final actualAmount = amount > maxRecruits ? maxRecruits : amount;

    if (actualAmount <= 0) {
      _addEventLog('${province.name}では兵力が上限に達しています');
      return;
    }

    final updatedProvinces = Map<String, Province>.from(_gameState.provinces);
    updatedProvinces[provinceId] = province.copyWith(
      currentTroops: province.currentTroops + actualAmount,
    );

    _gameState = _gameState.copyWith(
      provinces: updatedProvinces,
      playerGold: (_gameState.playerGold - (actualAmount * AppConstants.recruitmentCostPerTroop)).toInt(),
    );

    _addEventLog('${province.name}で$actualAmount人の兵士を徴兵しました');
    notifyListeners();
  }

  /// 英雄派遣（簡易版）
  void assignHeroToProvince(String heroId, String provinceId) {
    final hero = _gameState.heroes.firstWhere(
      (h) => h.id == heroId, 
      orElse: () => throw ArgumentError('Hero not found: $heroId'),
    );
    final province = _gameState.provinces[provinceId];
    
    if (province == null || province.controller != Faction.liangshan) return;

    final updatedHeroes = _gameState.heroes.map((h) => 
      h.id == heroId ? h.copyWith(currentProvinceId: provinceId) : h
    ).toList();

    _gameState = _gameState.copyWith(heroes: updatedHeroes);
    _addEventLog('${hero.name}を${province.name}に派遣しました');
    notifyListeners();
  }

  /// 交渉（簡易版）
  void negotiateWithProvince(String provinceId, String negotiationType) {
    final province = _gameState.provinces[provinceId];
    if (province == null || province.controller == Faction.liangshan) return;

    final cost = 200; // 交渉費用
    if (_gameState.playerGold < cost) {
      _addEventLog('交渉に必要な資金が不足しています');
      return;
    }

    final success = Random().nextDouble() < 0.3; // 30%の成功率

    _gameState = _gameState.copyWith(
      playerGold: _gameState.playerGold - cost,
    );

    if (success) {
      if (negotiationType == 'peace') {
        _addEventLog('${province.name}との和平交渉が成功しました');
      } else if (negotiationType == 'trade') {
        _gameState = _gameState.copyWith(
          playerGold: _gameState.playerGold + 300, // 貿易利益
        );
        _addEventLog('${province.name}との貿易交渉が成功し、300両を獲得しました');
      }
    } else {
      _addEventLog('${province.name}との交渉は失敗しました');
    }

    notifyListeners();
  }

  /// 州を攻撃
  void attackProvince(String targetProvinceId) {
    final sourceProvince = selectedProvince;
    final targetProvince = _gameState.provinces[targetProvinceId];

    if (sourceProvince == null || targetProvince == null) return;
    if (sourceProvince.controller != Faction.liangshan) return;
    if (targetProvince.controller == Faction.liangshan) return;

    // 高度な戦闘システムを使用
    final attacker = BattleParticipant(
      faction: sourceProvince.controller,
      troops: sourceProvince.currentTroops,
      heroes: _getHeroesInProvince(sourceProvince.id),
      province: sourceProvince,
    );

    final defender = BattleParticipant(
      faction: targetProvince.controller,
      troops: targetProvince.currentTroops,
      heroes: _getHeroesInProvince(targetProvince.id),
      province: targetProvince,
    );

    // 戦闘実行（地形と戦闘タイプは将来拡張予定）
    final battleResult = AdvancedBattleSystem.conductBattle(
      attacker: attacker,
      defender: defender,
      battleType: BattleType.fieldBattle,
      terrain: BattleTerrain.plains,
    );

    // 戦闘結果を反映
    _applyBattleResult(battleResult, sourceProvince.id, targetProvince.id);

    notifyListeners();
  }

  /// プレイヤーの総兵力を取得
  int getTotalTroops() {
    int total = 0;
    for (final province in _gameState.provinces.values) {
      if (province.controller == Faction.liangshan) {
        total += province.currentTroops;
      }
    }
    return total;
  }

  /// プレイヤーの総収入を取得
  int getTotalIncome() {
    int total = 0;
    for (final province in _gameState.provinces.values) {
      if (province.controller == Faction.liangshan) {
        total += province.state.taxIncome;
      }
    }
    return total;
  }

  /// プレイヤーの州一覧を取得
  List<Province> getPlayerProvinces() {
    return _gameState.provinces.values.where((province) => province.controller == Faction.liangshan).toList();
  }

  /// イベントログに追加
  void _addEventLog(String message) {
    _eventLog.insert(0, 'ターン${_gameState.currentTurn}: $message');
    // 最大20件まで保持
    if (_eventLog.length > AppConstants.maxEventLogEntries) {
      _eventLog = _eventLog.take(AppConstants.maxEventLogEntries).toList();
    }
  }

  /// 州にいる英雄を取得
  List<Hero> _getHeroesInProvince(String provinceId) {
    return _gameState.heroes.where((hero) => hero.currentProvinceId == provinceId).toList();
  }

  /// 戦闘結果を適用
  void _applyBattleResult(AdvancedBattleResult result, String sourceProvinceId, String targetProvinceId) {
    final updatedProvinces = Map<String, Province>.from(_gameState.provinces);

    // 攻撃側の損失を反映
    final sourceProvince = updatedProvinces[sourceProvinceId]!;
    updatedProvinces[sourceProvinceId] = sourceProvince.copyWith(
      currentTroops: (sourceProvince.currentTroops - result.attackerLosses).clamp(0, 999999),
    );

    // 防御側の損失を反映
    final targetProvince = updatedProvinces[targetProvinceId]!;
    updatedProvinces[targetProvinceId] = targetProvince.copyWith(
      currentTroops: (targetProvince.currentTroops - result.defenderLosses).clamp(0, 999999),
      controller: result.territoryConquered ? sourceProvince.controller : targetProvince.controller,
    );

    // 英雄の経験値を更新（将来実装）
    // TODO: result.heroResults を使って英雄の経験値とレベルアップを処理

    _gameState = _gameState.copyWith(provinces: updatedProvinces);

    // 戦闘結果をログに記録
    if (result.territoryConquered) {
      _addEventLog('${targetProvince.name}を占領しました！ 敵${result.defenderLosses}、味方${result.attackerLosses}の損失');
    } else {
      _addEventLog('${targetProvince.name}の攻略に失敗しました。敵${result.defenderLosses}、味方${result.attackerLosses}の損失');
    }

    // 特殊イベントをログに追加
    for (final event in result.specialEvents) {
      _addEventLog(event);
    }

    // 戦闘結果ダイアログを表示する準備（UIレイヤーから呼び出し）
    _lastBattleResult = BattleResultInfo(
      result: result,
      sourceProvinceName: sourceProvince.name,
      targetProvinceName: targetProvince.name,
    );

    notifyListeners();
  }

  // 最後の戦闘結果を保持（UIから参照するため）
  BattleResultInfo? _lastBattleResult;

  /// 最後の戦闘結果を取得
  BattleResultInfo? get lastBattleResult => _lastBattleResult;

  /// 戦闘結果を消去
  void clearBattleResult() {
    _lastBattleResult = null;
    notifyListeners();
  }

  /// ゲームデータを保存
  Future<bool> saveGame({String? saveName}) async {
    return await GameSaveService.saveGame(_gameState, saveName: saveName);
  }

  /// オートセーブを実行
  Future<bool> autoSave() async {
    return await GameSaveService.saveGame(_gameState, isAutoSave: true);
  }

  /// ゲームデータを読み込み
  Future<bool> loadGame(String saveName) async {
    final loadedState = await GameSaveService.loadGame(saveName);
    if (loadedState != null) {
      _gameState = loadedState;
      _addEventLog('ゲームデータを読み込みました');
      notifyListeners();
      return true;
    }
    return false;
  }

  /// オートセーブデータを読み込み
  Future<bool> loadAutoSave() async {
    final loadedState = await GameSaveService.loadAutoSave();
    if (loadedState != null) {
      _gameState = loadedState;
      _addEventLog('オートセーブデータを読み込みました');
      notifyListeners();
      return true;
    }
    return false;
  }

  /// セーブファイル一覧を取得
  Future<List<SaveFileInfo>> getSaveList() async {
    return await GameSaveService.getSaveList();
  }
}

/// 戦闘結果情報
class BattleResultInfo {
  const BattleResultInfo({
    required this.result,
    required this.sourceProvinceName,
    required this.targetProvinceName,
  });

  final AdvancedBattleResult result;
  final String sourceProvinceName;
  final String targetProvinceName;
}
