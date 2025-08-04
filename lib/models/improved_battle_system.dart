/// 改良された戦闘システム
/// 現実的な損失率と降伏・撤退システムを実装
library;

import '../models/province.dart';

import 'dart:math';
import 'package:flutter/material.dart' show Color, Colors;
import '../models/water_margin_strategy_game.dart';

/// 戦闘結果の種類
enum BattleResultType {
  victory, // 勝利
  defeat, // 敗北
  pyrrhicVictory, // 辛勝（大きな損失を伴う勝利）
  tacticalRetreat, // 戦術的撤退
  surrender, // 降伏
  stalemate, // 膠着状態
}

/// 詳細戦闘結果
class DetailedBattleResult {
  const DetailedBattleResult({
    required this.result,
    required this.attackerLosses,
    required this.defenderLosses,
    required this.attackerSurvivors,
    required this.defenderSurvivors,
    required this.moraleFactor,
    required this.battleDescription,
    required this.territoryChanged,
    this.capturedHeroes = const [],
    this.retreatedHeroes = const [],
  });

  final BattleResultType result;
  final int attackerLosses; // 攻撃側損失
  final int defenderLosses; // 防御側損失
  final int attackerSurvivors; // 攻撃側生存者
  final int defenderSurvivors; // 防御側生存者
  final double moraleFactor; // 士気要因
  final String battleDescription; // 戦況説明
  final bool territoryChanged; // 領土変更の有無
  final List<String> capturedHeroes; // 捕虜になった英雄
  final List<String> retreatedHeroes; // 撤退した英雄
}

/// 改良戦闘システム
class ImprovedBattleSystem {
  static const int _maxLossPercentage = 40; // 最大損失率40%
  static const int _surrenderThreshold = 60; // 降伏判定60%損失

  /// 戦闘を実行
  static DetailedBattleResult executeBattle({
    required Province attackerProvince,
    required Province defenderProvince,
    required List<Hero> attackerHeroes,
    required List<Hero> defenderHeroes,
    required bool isPlayerAttacker,
  }) {
    final attackerForce = attackerProvince.military.toInt();
    final defenderForce = defenderProvince.military.toInt();

    if (attackerForce == 0) {
      return DetailedBattleResult(
        result: BattleResultType.defeat,
        attackerLosses: 0,
        defenderLosses: 0,
        attackerSurvivors: 0,
        defenderSurvivors: defenderForce,
        moraleFactor: 0.0,
        battleDescription: '攻撃軍に兵力がありません',
        territoryChanged: false,
      );
    }

    // 基本戦力比（戦闘で使用）
    final forceRatio = attackerForce / defenderForce.clamp(1, double.infinity);

    // 英雄ボーナス計算
    final attackerHeroBonus = _calculateHeroBonus(attackerHeroes);
    final defenderHeroBonus = _calculateHeroBonus(defenderHeroes);

    // 地形・防御ボーナス（防御側に+20%）
    final defenseBonus = 1.2;

    // 士気要因（兵糧状況、民心等）
    final attackerMorale = _calculateMorale(attackerProvince, attackerHeroes);
    final defenderMorale = _calculateMorale(defenderProvince, defenderHeroes) * defenseBonus;

    // 総合戦力計算
    final attackerPower = attackerForce * attackerHeroBonus * attackerMorale;
    final defenderPower = defenderForce * defenderHeroBonus * defenderMorale;

    final totalPower = attackerPower + defenderPower;
    final attackerAdvantage = attackerPower / totalPower;

    // 戦闘結果決定
    final random = Random();
    final battleRoll = random.nextDouble();
    final adjustedRoll = battleRoll + (attackerAdvantage - 0.5) * 0.4; // 戦力差を反映

    // 損失率計算（現実的な範囲）
    final baseLossRate = 0.05 + random.nextDouble() * 0.25; // 5-30%の基本損失
    final intensityFactor = (attackerForce + defenderForce) / 1000; // 規模による激烈さ
    final intensityMultiplier = 1.0 + (intensityFactor * 0.1).clamp(0.0, 0.5); // 規模による損失増加

    int attackerLosses, defenderLosses, attackerSurvivors, defenderSurvivors;
    BattleResultType result;
    String description;
    bool territoryChanged = false;

    // 撤退判定（戦力比を考慮）
    final shouldRetreat = forceRatio < 0.3 && random.nextDouble() < 0.6;
    if (shouldRetreat) {
      result = BattleResultType.tacticalRetreat;
      attackerLosses = (attackerForce * baseLossRate * 0.3).round(); // 撤退時は損失少なめ
      defenderLosses = (defenderForce * baseLossRate * 0.1).round();
      territoryChanged = false;
      description = '${attackerProvince.name}軍が戦術的撤退を実行';
    } else if (adjustedRoll > 0.7) {
      // 攻撃側大勝利
      result = BattleResultType.victory;
      attackerLosses = (attackerForce * (baseLossRate * 0.5) * intensityMultiplier).round();
      defenderLosses = (defenderForce * (baseLossRate * 1.5) * intensityMultiplier).round();
      territoryChanged = true;
      description = '${attackerProvince.name}軍が${defenderProvince.name}を圧倒！';
    } else if (adjustedRoll > 0.55) {
      // 攻撃側勝利
      result = BattleResultType.victory;
      attackerLosses = (attackerForce * baseLossRate * intensityMultiplier).round();
      defenderLosses = (defenderForce * (baseLossRate * 1.2) * intensityMultiplier).round();
      territoryChanged = true;
      description = '激戦の末、${attackerProvince.name}軍が勝利';
    } else if (adjustedRoll > 0.45) {
      // 攻撃側辛勝
      result = BattleResultType.pyrrhicVictory;
      attackerLosses = (attackerForce * (baseLossRate * 1.3) * intensityMultiplier).round();
      defenderLosses = (defenderForce * (baseLossRate * 1.1) * intensityMultiplier).round();
      territoryChanged = true;
      description = '大きな犠牲を払いながらも${attackerProvince.name}軍が勝利';
    } else if (adjustedRoll > 0.35) {
      // 膠着状態
      result = BattleResultType.stalemate;
      attackerLosses = (attackerForce * baseLossRate * intensityMultiplier).round();
      defenderLosses = (defenderForce * baseLossRate * intensityMultiplier).round();
      territoryChanged = false;
      description = '両軍とも決定的な勝利を得られず膠着状態';
    } else if (adjustedRoll > 0.2) {
      // 攻撃側撤退
      result = BattleResultType.tacticalRetreat;
      attackerLosses = (attackerForce * (baseLossRate * 0.8) * intensityMultiplier).round();
      defenderLosses = (defenderForce * (baseLossRate * 0.6) * intensityMultiplier).round();
      territoryChanged = false;
      description = '${attackerProvince.name}軍が戦術的撤退を実施';
    } else {
      // 攻撃側敗北
      result = BattleResultType.defeat;
      attackerLosses = (attackerForce * (baseLossRate * 1.4) * intensityMultiplier).round();
      defenderLosses = (defenderForce * (baseLossRate * 0.7) * intensityMultiplier).round();
      territoryChanged = false;
      description = '${defenderProvince.name}軍が${attackerProvince.name}軍を撃退！';
    }

    // 損失の上限チェック（全滅は避ける）
    attackerLosses = attackerLosses.clamp(0, (attackerForce * _maxLossPercentage / 100).round());
    defenderLosses = defenderLosses.clamp(0, (defenderForce * _maxLossPercentage / 100).round());

    attackerSurvivors = attackerForce - attackerLosses;
    defenderSurvivors = defenderForce - defenderLosses;

    // 降伏判定
    final attackerLossPercent = attackerLosses / attackerForce * 100;
    final defenderLossPercent = defenderLosses / defenderForce * 100;

    if (attackerLossPercent > _surrenderThreshold && result != BattleResultType.victory) {
      result = BattleResultType.surrender;
      description = '${attackerProvince.name}軍が降伏';
      territoryChanged = false;
    } else if (defenderLossPercent > _surrenderThreshold && territoryChanged) {
      description += '、${defenderProvince.name}軍が降伏';
    }

    return DetailedBattleResult(
      result: result,
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
      attackerSurvivors: attackerSurvivors,
      defenderSurvivors: defenderSurvivors,
      moraleFactor: attackerMorale,
      battleDescription: description,
      territoryChanged: territoryChanged,
    );
  }

  /// 英雄による戦力ボーナス計算
  static double _calculateHeroBonus(List<Hero> heroes) {
    if (heroes.isEmpty) return 1.0;

    double totalBonus = 1.0;
    for (final hero in heroes) {
      // 武将は戦闘力、軍師は戦術ボーナス
      final heroBonus = hero.skill == HeroSkill.warrior
          ? 1.0 + (hero.stats.combatPower / 1000)
          : hero.skill == HeroSkill.strategist
              ? 1.0 + (hero.stats.intelligence / 1500)
              : 1.0 + (hero.stats.leadership / 2000);
      totalBonus *= heroBonus;
    }

    return totalBonus.clamp(1.0, 2.0); // 最大2倍まで
  }

  /// 士気計算
  static double _calculateMorale(Province province, List<Hero> heroes) {
    double morale = 1.0;

    // 民心による士気
    morale += (province.publicSupport * 100 - 50) / 200; // ±0.25

    // 兵糧状況による士気
    if (province.agriculture < 20) {
      morale -= 0.2; // 兵糧不足でペナルティ
    }

    // 英雄による士気ボーナス
    final heroMoraleBonus = heroes.length * 0.05; // 英雄1人につき5%
    morale += heroMoraleBonus;

    return morale.clamp(0.5, 1.5); // 0.5～1.5倍の範囲
  }

  /// 戦闘結果の文字列表現
  static String getResultDescription(BattleResultType result) {
    switch (result) {
      case BattleResultType.victory:
        return '勝利';
      case BattleResultType.defeat:
        return '敗北';
      case BattleResultType.pyrrhicVictory:
        return '辛勝';
      case BattleResultType.tacticalRetreat:
        return '戦術的撤退';
      case BattleResultType.surrender:
        return '降伏';
      case BattleResultType.stalemate:
        return '膠着状態';
    }
  }

  /// 戦闘結果の色
  static Color getResultColor(BattleResultType result, bool isPlayerWin) {
    switch (result) {
      case BattleResultType.victory:
        return isPlayerWin ? Colors.green : Colors.red;
      case BattleResultType.defeat:
        return isPlayerWin ? Colors.red : Colors.green;
      case BattleResultType.pyrrhicVictory:
        return isPlayerWin ? Colors.orange : Colors.deepOrange;
      case BattleResultType.tacticalRetreat:
        return Colors.blue;
      case BattleResultType.surrender:
        return isPlayerWin ? Colors.green : Colors.red;
      case BattleResultType.stalemate:
        return Colors.grey;
    }
  }
}
