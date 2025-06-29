/// 水滸伝戦略ゲームのコントローラー
/// フェーズ1: 基本的なゲーム状態管理とUI操作
library;

import 'package:flutter/material.dart' hide Hero;

import '../data/water_margin_map.dart';
import '../data/water_margin_heroes.dart';
import '../models/water_margin_strategy_game.dart';
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

  /// 州を攻撃
  void attackProvince(String targetProvinceId) {
    final sourceProvince = selectedProvince;
    final targetProvince = _gameState.provinces[targetProvinceId];
    
    if (sourceProvince == null || targetProvince == null) return;
    if (sourceProvince.controller != Faction.liangshan) return;
    if (targetProvince.controller == Faction.liangshan) return;
    
    // 簡易戦闘システム
    final attackerPower = sourceProvince.currentTroops;
    final defenderPower = targetProvince.currentTroops;
    
    final attackerWins = attackerPower > defenderPower;
    
    if (attackerWins) {
      final updatedProvinces = Map<String, Province>.from(_gameState.provinces);
      updatedProvinces[targetProvinceId] = targetProvince.copyWith(
        controller: Faction.liangshan,
      );
      
      _gameState = _gameState.copyWith(provinces: updatedProvinces);
      _addEventLog('${targetProvince.name}を占領しました！');
    } else {
      _addEventLog('${targetProvince.name}の攻略に失敗しました');
    }
    
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
    return _gameState.provinces.values
        .where((province) => province.controller == Faction.liangshan)
        .toList();
  }

  /// イベントログに追加
  void _addEventLog(String message) {
    _eventLog.insert(0, 'ターン${_gameState.currentTurn}: $message');
    // 最大20件まで保持
    if (_eventLog.length > AppConstants.maxEventLogEntries) {
      _eventLog = _eventLog.take(AppConstants.maxEventLogEntries).toList();
    }
  }
}
