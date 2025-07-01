/// 水滸伝戦略ゲームのコントローラー
/// フェーズ1: 基本的なゲーム状態管理とUI操作
library;

import 'dart:math';
import 'package:flutter/material.dart' hide Hero;

import '../data/water_margin_map.dart';
import '../data/water_margin_heroes.dart';
import '../models/water_margin_strategy_game.dart';
import '../models/advanced_battle_system.dart';
import '../models/diplomacy_system.dart';
import '../models/game_difficulty.dart';
import '../services/game_save_service.dart';
import '../core/app_config.dart';
import '../utils/app_utils.dart';
import '../widgets/toast_notification.dart';

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

  /// イベントログ（表示用の一時的なログ）
  List<String> _eventLog = [];

  /// イベント履歴（永続的な全履歴）
  List<String> _eventHistory = [];

  /// トースト通知用のBuildContext（画面から設定される）
  BuildContext? _context;

  /// 現在のゲーム状態を取得
  WaterMarginGameState get gameState => _gameState;

  /// イベントログを取得
  List<String> get eventLog => List.unmodifiable(_eventLog);

  /// イベント履歴を取得
  List<String> get eventHistory => List.unmodifiable(_eventHistory);

  /// BuildContextを設定（画面から呼び出される）
  void setContext(BuildContext context) {
    _context = context;
  }

  /// 選択された州のIDを取得
  String? get selectedProvinceId => _gameState.selectedProvinceId;

  /// 選択された州を取得
  Province? get selectedProvince {
    if (_gameState.selectedProvinceId == null) return null;
    return _gameState.provinces[_gameState.selectedProvinceId!];
  }

  /// ゲームを初期化（難易度指定版）
  void initializeGameWithDifficulty(GameDifficulty difficulty) {
    _difficultySettings = GameDifficultySettings.forDifficulty(difficulty);
    _initializeGameWithSettings(_difficultySettings!);
  }

  /// ゲームを初期化
  void initializeGame() {
    // 標準難易度で初期化
    initializeGameWithDifficulty(GameDifficulty.normal);
  }

  /// 難易度設定でゲームを初期化（内部メソッド）
  void _initializeGameWithSettings(GameDifficultySettings settings) {
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
        playerGold: settings.initialGold, // 難易度に応じた初期資金
        gameStatus: GameStatus.playing,
        diplomacy: DiplomacySystem.withDefaults(),
        difficulty: settings.difficulty,
        triggeredEvents: <String>{},
      );

      _eventLog.clear();
      _addEventLog('新しいゲームを開始しました（難易度: ${settings.difficulty.displayName}）');
      _addEventLog('初期資金: ${settings.initialGold}両');

      // 難易度に応じたヒント表示
      if (settings.difficulty == GameDifficulty.beginner) {
        _addEventLog('💡 初心者モードでは資金と経験値にボーナスがあります');
      } else if (settings.difficulty == GameDifficulty.expert) {
        _addEventLog('⚠️ 達人モードは非常に困難です。慎重に進めてください');
      }

      notifyListeners();
    } catch (e) {
      // データファイルが存在しない場合のフォールバック
      _gameState = WaterMarginGameState(
        provinces: const {},
        heroes: const [],
        factions: const {},
        currentTurn: 1,
        playerGold: settings.initialGold,
        gameStatus: GameStatus.playing,
        difficulty: settings.difficulty,
        triggeredEvents: <String>{},
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

    // 貿易収入を処理
    _processTradeincome();

    // オートセーブを実行
    autoSave();

    _addEventLog('ターン${_gameState.currentTurn}が開始されました（収入: $income両）');
    notifyListeners();
  }

  /// 州を開発
  void developProvince(String provinceId, DevelopmentType type) {
    final province = _gameState.provinces[provinceId];
    if (province == null || province.controller != Faction.liangshan) return;

    // 難易度に応じたコスト計算
    final cost = _difficultySettings?.getDevelopmentCost() ?? AppConstants.developmentCost;
    if (_gameState.playerGold < cost) {
      _addEventLog('資金が不足しています（必要: $cost両）', toastType: ToastType.error);
      return;
    }

    final updatedProvinces = Map<String, Province>.from(_gameState.provinces);
    var newState = province.state;

    switch (type) {
      case DevelopmentType.agriculture:
        newState = newState.copyWith(
          agriculture: NumberUtils.clampInt(newState.agriculture + 10, 0, AppConstants.maxDevelopmentLevel),
        );
        _addEventLog('${province.name}の農業を発展させました（コスト: $cost両）', toastType: ToastType.success);
        break;
      case DevelopmentType.commerce:
        newState = newState.copyWith(
          commerce: NumberUtils.clampInt(newState.commerce + 10, 0, AppConstants.maxDevelopmentLevel),
        );
        _addEventLog('${province.name}の商業を発展させました（コスト: $cost両）', toastType: ToastType.success);
        break;
      case DevelopmentType.military:
        newState = newState.copyWith(
          military: NumberUtils.clampInt(newState.military + 10, 0, AppConstants.maxDevelopmentLevel),
        );
        _addEventLog('${province.name}の軍事を強化しました（コスト: $cost両）', toastType: ToastType.success);
        break;
      case DevelopmentType.security:
        newState = newState.copyWith(
          security: NumberUtils.clampInt(newState.security + 10, 0, AppConstants.maxDevelopmentLevel),
        );
        _addEventLog('${province.name}の治安を改善しました（コスト: $cost両）', toastType: ToastType.success);
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
      _addEventLog('徴兵に必要な資金が不足しています', toastType: ToastType.error);
      return;
    }

    final maxRecruits = province.state.maxTroops - province.currentTroops;
    final actualAmount = amount > maxRecruits ? maxRecruits : amount;

    if (actualAmount <= 0) {
      _addEventLog('${province.name}では兵力が上限に達しています', toastType: ToastType.warning);
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

    final updatedHeroes =
        _gameState.heroes.map((h) => h.id == heroId ? h.copyWith(currentProvinceId: provinceId) : h).toList();

    _gameState = _gameState.copyWith(heroes: updatedHeroes);
    _addEventLog('${hero.name}を${province.name}に派遣しました');
    notifyListeners();
  }

  /// 外交行動を実行
  void performDiplomaticAction(Faction targetFaction, DiplomaticAction action) {
    final diplomacy = _gameState.diplomacy;
    if (diplomacy == null) {
      _addEventLog('外交システムが利用できません');
      return;
    }

    // コストチェック
    if (_gameState.playerGold < action.cost) {
      _addEventLog('${action.displayName}に必要な資金が不足しています (必要: ${action.cost}両)');
      return;
    }

    // 成功率計算
    final successRate = diplomacy.calculateSuccessRate(Faction.liangshan, targetFaction, action);
    final success = Random().nextDouble() < successRate;

    // 資金消費
    _gameState = _gameState.copyWith(
      playerGold: _gameState.playerGold - action.cost,
    );

    if (success) {
      _handleSuccessfulDiplomacy(targetFaction, action, diplomacy);
    } else {
      _handleFailedDiplomacy(targetFaction, action, diplomacy);
    }

    notifyListeners();
  }

  /// 成功した外交行動の処理
  void _handleSuccessfulDiplomacy(Faction targetFaction, DiplomaticAction action, DiplomacySystem diplomacy) {
    final currentRelation = diplomacy.getRelation(Faction.liangshan, targetFaction);
    final newRelation = (currentRelation + action.relationChange).clamp(-100, 100);

    final updatedDiplomacy = diplomacy.setRelation(Faction.liangshan, targetFaction, newRelation);

    switch (action) {
      case DiplomaticAction.requestAlliance:
        if (newRelation >= 80) {
          final treaty = Treaty(
            id: 'alliance_${targetFaction.name}_${_gameState.currentTurn}',
            type: TreatyType.militaryAlliance,
            faction1: Faction.liangshan,
            faction2: targetFaction,
            startTurn: _gameState.currentTurn,
            duration: TreatyType.militaryAlliance.duration,
          );
          _gameState = _gameState.copyWith(
            diplomacy: updatedDiplomacy.addTreaty(treaty),
          );
          _addEventLog('${targetFaction.displayName}との軍事同盟が成立しました！');
        } else {
          _gameState = _gameState.copyWith(diplomacy: updatedDiplomacy);
          _addEventLog('${targetFaction.displayName}との関係が改善しました');
        }
        break;

      case DiplomaticAction.requestTrade:
        final tradeRoute = TradeRoute(
          id: 'trade_${targetFaction.name}_${_gameState.currentTurn}',
          sourceProvinceId: 'liangshan', // 梁山泊の拠点
          targetProvinceId: 'bianliang', // 仮の相手州
          goldPerTurn: 100 + (newRelation ~/ 10),
          startTurn: _gameState.currentTurn,
        );

        final treaty = Treaty(
          id: 'trade_${targetFaction.name}_${_gameState.currentTurn}',
          type: TreatyType.tradeAgreement,
          faction1: Faction.liangshan,
          faction2: targetFaction,
          startTurn: _gameState.currentTurn,
          duration: TreatyType.tradeAgreement.duration,
        );

        _gameState = _gameState.copyWith(
          diplomacy: updatedDiplomacy.addTreaty(treaty).addTradeRoute(tradeRoute),
        );
        _addEventLog('${targetFaction.displayName}との貿易協定が成立しました (収入+${tradeRoute.goldPerTurn}両/ターン)');
        break;

      case DiplomaticAction.demandTribute:
        final tribute = 200 + Random().nextInt(300);
        _gameState = _gameState.copyWith(
          playerGold: _gameState.playerGold + tribute,
          diplomacy: updatedDiplomacy,
        );
        _addEventLog('${targetFaction.displayName}から$tribute両の貢ぎ物を受け取りました');
        break;

      case DiplomaticAction.declarePeace:
        final treaty = Treaty(
          id: 'peace_${targetFaction.name}_${_gameState.currentTurn}',
          type: TreatyType.nonAggression,
          faction1: Faction.liangshan,
          faction2: targetFaction,
          startTurn: _gameState.currentTurn,
          duration: TreatyType.nonAggression.duration,
        );
        _gameState = _gameState.copyWith(
          diplomacy: updatedDiplomacy.addTreaty(treaty),
        );
        _addEventLog('${targetFaction.displayName}との不可侵条約が成立しました');
        break;

      case DiplomaticAction.sendGift:
        _gameState = _gameState.copyWith(diplomacy: updatedDiplomacy);
        _addEventLog('${targetFaction.displayName}に贈り物を送り、関係が改善しました');
        break;

      case DiplomaticAction.threaten:
        _gameState = _gameState.copyWith(diplomacy: updatedDiplomacy);
        _addEventLog('${targetFaction.displayName}への威嚇が効果を上げました');
        break;
    }
  }

  /// 失敗した外交行動の処理
  void _handleFailedDiplomacy(Faction targetFaction, DiplomaticAction action, DiplomacySystem diplomacy) {
    // 失敗時は関係悪化のリスク
    final penalty = action.relationChange < 0 ? action.relationChange ~/ 2 : -10;
    final currentRelation = diplomacy.getRelation(Faction.liangshan, targetFaction);
    final newRelation = (currentRelation + penalty).clamp(-100, 100);

    _gameState = _gameState.copyWith(
      diplomacy: diplomacy.setRelation(Faction.liangshan, targetFaction, newRelation),
    );

    _addEventLog('${targetFaction.displayName}との${action.displayName}は失敗しました');
  }

  /// 勢力との関係を取得
  int getDiplomaticRelation(Faction faction) {
    return _gameState.diplomacy?.getRelation(Faction.liangshan, faction) ?? 0;
  }

  /// 勢力との関係レベルを取得
  DiplomaticRelation getDiplomaticRelationLevel(Faction faction) {
    return _gameState.diplomacy?.getRelationLevel(Faction.liangshan, faction) ?? DiplomaticRelation.neutral;
  }

  /// 有効な協定のリストを取得
  List<Treaty> getActiveTreaties() {
    return _gameState.diplomacy?.getActiveTreaties(_gameState.currentTurn) ?? [];
  }

  /// 勢力間に協定があるかチェック
  bool hasTreatyWith(Faction faction, TreatyType type) {
    return _gameState.diplomacy?.hasTreaty(Faction.liangshan, faction, type, _gameState.currentTurn) ?? false;
  }

  /// 貿易収入を処理 (ターン終了時に呼ばれる)
  void _processTradeincome() {
    final diplomacy = _gameState.diplomacy;
    if (diplomacy == null) return;

    int totalTradeIncome = 0;
    for (final province in _gameState.provinces.values) {
      if (province.controller == Faction.liangshan) {
        totalTradeIncome += diplomacy.calculateTradeIncome(province.id);
      }
    }

    if (totalTradeIncome > 0) {
      _gameState = _gameState.copyWith(
        playerGold: _gameState.playerGold + totalTradeIncome,
      );
      _addEventLog('貿易により$totalTradeIncome両の収入を得ました');
    }
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

    if (sourceProvince == null || targetProvince == null) {
      _addEventLog('攻撃失敗: 州が選択されていません');
      return;
    }
    if (sourceProvince.controller != Faction.liangshan) {
      _addEventLog('攻撃失敗: ${sourceProvince.name}は梁山泊の州ではありません');
      return;
    }
    if (targetProvince.controller == Faction.liangshan) {
      _addEventLog('攻撃失敗: ${targetProvince.name}は味方の州です');
      return;
    }
    if (sourceProvince.currentTroops <= 0) {
      _addEventLog('攻撃失敗: ${sourceProvince.name}に兵力がありません');
      return;
    }

    _addEventLog('${sourceProvince.name}から${targetProvince.name}への攻撃を開始！');

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

    _addEventLog('戦闘結果: ${battleResult.attackerWins ? "勝利" : "敗北"}');
    _addEventLog('味方損失: ${battleResult.attackerLosses}, 敵損失: ${battleResult.defenderLosses}');

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

  /// プレイヤーの総収入を取得（難易度調整込み）
  int getTotalIncome() {
    int total = 0;
    for (final province in _gameState.provinces.values) {
      if (province.controller == Faction.liangshan) {
        total += province.state.taxIncome;
      }
    }

    // 難易度に応じた収入調整
    if (_difficultySettings != null) {
      total = _difficultySettings!.calculateIncome(total);
    }

    // 動的バランス調整
    final adjustment = GameBalanceHelper.calculateDynamicAdjustment(_gameState);
    if (adjustment.hasAdjustments) {
      total = (total * (1.0 + adjustment.incomeBonus)).round();
    }

    return total;
  }

  /// プレイヤーの州一覧を取得
  List<Province> getPlayerProvinces() {
    return _gameState.provinces.values.where((province) => province.controller == Faction.liangshan).toList();
  }

  /// イベントログに追加
  void _addEventLog(String message, {ToastType toastType = ToastType.info}) {
    final formattedMessage = 'ターン${_gameState.currentTurn}: $message';

    // 一時的なログ（画面表示用、すぐに削除されない）
    _eventLog.insert(0, formattedMessage);
    // 最大20件まで保持
    if (_eventLog.length > AppConstants.maxEventLogEntries) {
      _eventLog = _eventLog.take(AppConstants.maxEventLogEntries).toList();
    }

    // 永続的な履歴（全履歴を保持）
    _eventHistory.add(formattedMessage);

    // トースト通知を表示
    if (_context != null) {
      ToastNotificationManager.showNotification(
        _context!,
        message: message,
        type: toastType,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// トースト通知のみを表示（履歴に残さない、将来の拡張用）
  // void _showToastOnly(String message, {ToastType toastType = ToastType.info}) {
  //   if (_context != null) {
  //     ToastNotificationManager.showNotification(
  //       _context!,
  //       message: message,
  //       type: toastType,
  //       duration: const Duration(seconds: 2),
  //     );
  //   }
  // }

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

    // 英雄の経験値を更新
    _applyHeroBattleExperience(result.heroResults);

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

  /// 戦闘での英雄経験値を適用
  void _applyHeroBattleExperience(List<HeroBattleResult> heroResults) {
    for (final heroResult in heroResults) {
      if (heroResult.hero.faction == Faction.liangshan) {
        addHeroExperience(heroResult.hero.id, heroResult.experienceGained);

        // 特別な戦績がある場合
        if (heroResult.specialAchievement != null) {
          _addEventLog('${heroResult.hero.name}: ${heroResult.specialAchievement}');
        }

        // 負傷判定
        if (heroResult.isInjured) {
          _addEventLog('${heroResult.hero.name}が負傷しました');
        }
      }
    }
  }

  // 最後の戦闘結果を保持（UIから参照するため）
  BattleResultInfo? _lastBattleResult;

  /// 現在の難易度設定
  GameDifficultySettings? _difficultySettings;

  /// チュートリアル表示フラグ
  bool _showTutorial = true;

  /// 最後の戦闘結果を取得
  BattleResultInfo? get lastBattleResult => _lastBattleResult;

  /// 現在の難易度設定を取得
  GameDifficultySettings? get difficultySettings => _difficultySettings;

  /// チュートリアル表示フラグを取得
  bool get showTutorial => _showTutorial && _gameState.currentTurn <= 5;

  /// 戦闘結果を消去
  void clearBattleResult() {
    _lastBattleResult = null;
    notifyListeners();
  }

  /// チュートリアルを非表示にする
  void hideTutorial() {
    _showTutorial = false;
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

  /// 英雄に経験値を追加
  void addHeroExperience(String heroId, int amount) {
    final heroIndex = _gameState.heroes.indexWhere((h) => h.id == heroId);
    if (heroIndex == -1) return;

    final hero = _gameState.heroes[heroIndex];
    final updatedHero = hero.copyWith(experience: hero.experience + amount);

    final updatedHeroes = List<Hero>.from(_gameState.heroes);
    updatedHeroes[heroIndex] = updatedHero;

    _gameState = _gameState.copyWith(heroes: updatedHeroes);

    // レベルアップチェック
    _checkHeroLevelUp(hero, updatedHero);

    notifyListeners();
  }

  /// 英雄訓練（費用を消費して経験値獲得）
  void trainHero(String heroId, int cost, int expGain) {
    if (_gameState.playerGold < cost) {
      _addEventLog('訓練費用が不足しています');
      return;
    }

    _gameState = _gameState.copyWith(playerGold: _gameState.playerGold - cost);
    addHeroExperience(heroId, expGain);
  }

  /// 英雄レベルとスキル習得チェック
  void _checkHeroLevelUp(Hero oldHero, Hero newHero) {
    final oldLevel = (oldHero.experience / 100).floor() + 1;
    final newLevel = (newHero.experience / 100).floor() + 1;

    if (newLevel > oldLevel) {
      _addEventLog('🌟 ${newHero.name}がレベル$newLevelに上がりました！');

      // スキル習得チェック（簡易版）
      final skills = _getLearnableSkillsAtLevel(newHero, newLevel);
      for (final skill in skills) {
        _addEventLog('✨ ${newHero.name}が新しいスキル「$skill」を習得！');
      }
    }
  }

  /// レベル習得時のスキル一覧（簡易版）
  List<String> _getLearnableSkillsAtLevel(Hero hero, int level) {
    final skills = <String>[];

    switch (hero.skill) {
      case HeroSkill.warrior:
        if (level == 5) skills.add('強打');
        if (level == 10) skills.add('連撃');
        if (level == 15) skills.add('必殺技');
        break;
      case HeroSkill.strategist:
        if (level == 5) skills.add('戦術指導');
        if (level == 10) skills.add('計略');
        if (level == 15) skills.add('天下三分');
        break;
      case HeroSkill.administrator:
        if (level == 5) skills.add('行政改革');
        if (level == 10) skills.add('徴税強化');
        if (level == 15) skills.add('民心安定');
        break;
      case HeroSkill.diplomat:
        if (level == 5) skills.add('説得術');
        if (level == 10) skills.add('同盟締結');
        if (level == 15) skills.add('天下統一の理想');
        break;
      case HeroSkill.scout:
        if (level == 5) skills.add('情報収集');
        if (level == 10) skills.add('敵情偵察');
        if (level == 15) skills.add('完全隠密');
        break;
    }

    return skills;
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
