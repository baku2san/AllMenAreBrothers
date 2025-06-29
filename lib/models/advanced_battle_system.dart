/// 改良された戦闘システム
/// フェーズ2: 一騎討ち、水戦、攻城戦など多様な戦闘
library;

import '../models/water_margin_strategy_game.dart' as game show Hero;
import '../models/water_margin_strategy_game.dart' hide Hero;

/// 戦闘の種類
enum BattleType {
  fieldBattle, // 野戦
  siegeBattle, // 攻城戦
  navalBattle, // 水戦
  duel, // 一騎討ち
  ambush, // 奇襲
}

/// 戦闘の地形効果
enum BattleTerrain {
  plains, // 平野
  mountains, // 山地
  forest, // 森林
  river, // 河川
  fortress, // 要塞
  marsh, // 湿地
}

/// 戦闘参加者
class BattleParticipant {
  const BattleParticipant({
    required this.faction,
    required this.troops,
    required this.heroes,
    required this.province,
  });

  final Faction faction;
  final int troops;
  final List<game.Hero> heroes;
  final Province province;

  /// 総戦闘力を計算
  int get totalCombatPower {
    int heroBonus = heroes.fold(0, (sum, hero) => sum + hero.stats.combatPower);
    return troops + (heroBonus * 10); // 英雄1人 = 兵力10人相当
  }

  /// 統率力ボーナス
  int get leadershipBonus {
    if (heroes.isEmpty) return 0;
    return heroes.map((h) => h.stats.leadership).reduce((a, b) => a > b ? a : b);
  }

  /// 知力ボーナス（策略用）
  int get intelligenceBonus {
    if (heroes.isEmpty) return 0;
    return heroes.map((h) => h.stats.intelligence).reduce((a, b) => a > b ? a : b);
  }
}

/// 戦闘結果
class AdvancedBattleResult {
  const AdvancedBattleResult({
    required this.winner,
    required this.battleType,
    required this.attackerLosses,
    required this.defenderLosses,
    required this.heroResults,
    required this.specialEvents,
    required this.territoryConquered,
    this.duelWinner,
  });

  final Faction winner;
  final BattleType battleType;
  final int attackerLosses;
  final int defenderLosses;
  final List<HeroBattleResult> heroResults;
  final List<String> specialEvents;
  final bool territoryConquered;
  final game.Hero? duelWinner; // 一騎討ちの勝者

  bool get attackerWins => winner == Faction.liangshan;
}

/// 英雄の戦闘結果
class HeroBattleResult {
  const HeroBattleResult({
    required this.hero,
    required this.performance,
    required this.experienceGained,
    this.isInjured = false,
    this.specialAchievement,
  });

  final game.Hero hero;
  final HeroPerformance performance;
  final int experienceGained;
  final bool isInjured;
  final String? specialAchievement;
}

/// 英雄の戦闘パフォーマンス
enum HeroPerformance {
  outstanding, // 活躍
  good, // 普通
  poor, // 不調
  defeated, // 敗北
}

/// 戦術の種類
enum BattleTactic {
  frontalAssault, // 正面攻撃
  flanking, // 側面攻撃
  ambush, // 奇襲
  retreat, // 撤退
  defensiveStance, // 守備態勢
  stratagem, // 計略
}

/// 改良された戦闘システム
class AdvancedBattleSystem {
  /// 戦闘を実行
  static AdvancedBattleResult conductBattle({
    required BattleParticipant attacker,
    required BattleParticipant defender,
    required BattleType battleType,
    required BattleTerrain terrain,
    BattleTactic? attackerTactic,
    BattleTactic? defenderTactic,
  }) {
    // 地形効果を計算
    final terrainModifier = _calculateTerrainModifier(terrain, battleType);
    
    // 戦術効果を計算
    final tacticModifier = _calculateTacticModifier(
      attackerTactic ?? BattleTactic.frontalAssault,
      defenderTactic ?? BattleTactic.defensiveStance,
    );

    // 戦闘力を計算
    int attackerPower = attacker.totalCombatPower;
    int defenderPower = defender.totalCombatPower;

    // 各種修正を適用
    attackerPower = (attackerPower * (1.0 + tacticModifier.attackerBonus)).round();
    defenderPower = (defenderPower * (1.0 + tacticModifier.defenderBonus)).round();

    // 地形効果を適用
    if (terrainModifier.favorDefender) {
      defenderPower = (defenderPower * terrainModifier.modifier).round();
    } else {
      attackerPower = (attackerPower * terrainModifier.modifier).round();
    }

    // 戦闘の種類別処理
    switch (battleType) {
      case BattleType.duel:
        return _conductDuel(attacker, defender);
      case BattleType.siegeBattle:
        return _conductSiegeBattle(attacker, defender, attackerPower, defenderPower);
      case BattleType.navalBattle:
        return _conductNavalBattle(attacker, defender, attackerPower, defenderPower);
      default:
        return _conductFieldBattle(attacker, defender, attackerPower, defenderPower);
    }
  }

  /// 野戦を実行
  static AdvancedBattleResult _conductFieldBattle(
    BattleParticipant attacker,
    BattleParticipant defender,
    int attackerPower,
    int defenderPower,
  ) {
    final winner = attackerPower > defenderPower ? attacker.faction : defender.faction;
    final powerDiff = (attackerPower - defenderPower).abs();
    
    // 損失を計算
    final attackerLosses = _calculateLosses(attacker.troops, powerDiff, winner == attacker.faction);
    final defenderLosses = _calculateLosses(defender.troops, powerDiff, winner == defender.faction);

    // 英雄の戦闘結果を生成
    final heroResults = <HeroBattleResult>[];
    heroResults.addAll(_evaluateHeroPerformance(attacker.heroes, winner == attacker.faction));
    heroResults.addAll(_evaluateHeroPerformance(defender.heroes, winner == defender.faction));

    return AdvancedBattleResult(
      winner: winner,
      battleType: BattleType.fieldBattle,
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
      heroResults: heroResults,
      specialEvents: _generateSpecialEvents(attacker, defender),
      territoryConquered: winner == attacker.faction,
    );
  }

  /// 一騎討ちを実行
  static AdvancedBattleResult _conductDuel(
    BattleParticipant attacker,
    BattleParticipant defender,
  ) {
    if (attacker.heroes.isEmpty || defender.heroes.isEmpty) {
      // 一騎討ちできない場合は通常戦闘
      return _conductFieldBattle(attacker, defender, attacker.totalCombatPower, defender.totalCombatPower);
    }

    // 最強の英雄同士で一騎討ち
    final attackerChampion = attacker.heroes.reduce((a, b) => 
        a.stats.combatPower > b.stats.combatPower ? a : b);
    final defenderChampion = defender.heroes.reduce((a, b) => 
        a.stats.combatPower > b.stats.combatPower ? a : b);

    final attackerPower = attackerChampion.stats.combatPower;
    final defenderPower = defenderChampion.stats.combatPower;
    
    final winner = attackerPower > defenderPower ? attacker.faction : defender.faction;
    final duelWinner = winner == attacker.faction ? attackerChampion : defenderChampion;

    return AdvancedBattleResult(
      winner: winner,
      battleType: BattleType.duel,
      attackerLosses: winner == attacker.faction ? 0 : attacker.troops ~/ 10,
      defenderLosses: winner == defender.faction ? 0 : defender.troops ~/ 10,
      heroResults: [
        HeroBattleResult(
          hero: attackerChampion,
          performance: winner == attacker.faction ? HeroPerformance.outstanding : HeroPerformance.defeated,
          experienceGained: winner == attacker.faction ? 100 : 50,
        ),
        HeroBattleResult(
          hero: defenderChampion,
          performance: winner == defender.faction ? HeroPerformance.outstanding : HeroPerformance.defeated,
          experienceGained: winner == defender.faction ? 100 : 50,
        ),
      ],
      specialEvents: ['${duelWinner.nickname}が一騎討ちで勝利！'],
      territoryConquered: winner == attacker.faction,
      duelWinner: duelWinner,
    );
  }

  /// 攻城戦を実行
  static AdvancedBattleResult _conductSiegeBattle(
    BattleParticipant attacker,
    BattleParticipant defender,
    int attackerPower,
    int defenderPower,
  ) {
    // 守備側に要塞ボーナス
    final fortifiedDefenderPower = (defenderPower * 1.5).round();
    
    final winner = attackerPower > fortifiedDefenderPower ? attacker.faction : defender.faction;
    final powerDiff = (attackerPower - fortifiedDefenderPower).abs();
    
    final attackerLosses = _calculateLosses(attacker.troops, powerDiff, winner == attacker.faction);
    final defenderLosses = _calculateLosses(defender.troops, powerDiff, winner == defender.faction);

    final heroResults = <HeroBattleResult>[];
    heroResults.addAll(_evaluateHeroPerformance(attacker.heroes, winner == attacker.faction));
    heroResults.addAll(_evaluateHeroPerformance(defender.heroes, winner == defender.faction));

    return AdvancedBattleResult(
      winner: winner,
      battleType: BattleType.siegeBattle,
      attackerLosses: (attackerLosses * 1.3).round(), // 攻城戦は攻撃側の損失が大きい
      defenderLosses: defenderLosses,
      heroResults: heroResults,
      specialEvents: winner == attacker.faction 
          ? ['要塞を陥落させた！']
          : ['要塞を守り抜いた！'],
      territoryConquered: winner == attacker.faction,
    );
  }

  /// 水戦を実行
  static AdvancedBattleResult _conductNavalBattle(
    BattleParticipant attacker,
    BattleParticipant defender,
    int attackerPower,
    int defenderPower,
  ) {
    // 水戦では知力も重要
    final attackerIntelligence = attacker.intelligenceBonus;
    final defenderIntelligence = defender.intelligenceBonus;
    
    final modifiedAttackerPower = attackerPower + (attackerIntelligence * 5);
    final modifiedDefenderPower = defenderPower + (defenderIntelligence * 5);
    
    final winner = modifiedAttackerPower > modifiedDefenderPower ? attacker.faction : defender.faction;
    final powerDiff = (modifiedAttackerPower - modifiedDefenderPower).abs();
    
    final attackerLosses = _calculateLosses(attacker.troops, powerDiff, winner == attacker.faction);
    final defenderLosses = _calculateLosses(defender.troops, powerDiff, winner == defender.faction);

    final heroResults = <HeroBattleResult>[];
    heroResults.addAll(_evaluateHeroPerformance(attacker.heroes, winner == attacker.faction));
    heroResults.addAll(_evaluateHeroPerformance(defender.heroes, winner == defender.faction));

    return AdvancedBattleResult(
      winner: winner,
      battleType: BattleType.navalBattle,
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
      heroResults: heroResults,
      specialEvents: ['水上で激しい戦闘が繰り広げられた！'],
      territoryConquered: winner == attacker.faction,
    );
  }

  /// 地形効果を計算
  static TerrainModifier _calculateTerrainModifier(BattleTerrain terrain, BattleType battleType) {
    switch (terrain) {
      case BattleTerrain.mountains:
        return const TerrainModifier(modifier: 1.2, favorDefender: true);
      case BattleTerrain.forest:
        return battleType == BattleType.ambush 
            ? const TerrainModifier(modifier: 1.3, favorDefender: false)
            : const TerrainModifier(modifier: 1.1, favorDefender: true);
      case BattleTerrain.river:
        return const TerrainModifier(modifier: 1.15, favorDefender: true);
      case BattleTerrain.fortress:
        return const TerrainModifier(modifier: 1.5, favorDefender: true);
      case BattleTerrain.marsh:
        return const TerrainModifier(modifier: 0.9, favorDefender: true);
      default:
        return const TerrainModifier(modifier: 1.0, favorDefender: false);
    }
  }

  /// 戦術効果を計算
  static TacticModifier _calculateTacticModifier(BattleTactic attackerTactic, BattleTactic defenderTactic) {
    // 戦術の相性を計算
    double attackerBonus = 0.0;
    double defenderBonus = 0.0;

    switch (attackerTactic) {
      case BattleTactic.frontalAssault:
        attackerBonus = 0.1;
        break;
      case BattleTactic.flanking:
        attackerBonus = defenderTactic == BattleTactic.defensiveStance ? 0.2 : 0.05;
        break;
      case BattleTactic.ambush:
        attackerBonus = 0.25;
        break;
      case BattleTactic.stratagem:
        attackerBonus = 0.15;
        break;
      default:
        break;
    }

    switch (defenderTactic) {
      case BattleTactic.defensiveStance:
        defenderBonus = 0.15;
        break;
      case BattleTactic.retreat:
        defenderBonus = -0.1; // 撤退は戦力低下
        break;
      default:
        break;
    }

    return TacticModifier(attackerBonus: attackerBonus, defenderBonus: defenderBonus);
  }

  /// 損失を計算
  static int _calculateLosses(int totalTroops, int powerDiff, bool isWinner) {
    if (isWinner) {
      return (totalTroops * 0.1 * (powerDiff / 1000)).round().clamp(0, totalTroops ~/ 3);
    } else {
      return (totalTroops * 0.3 * (1 + powerDiff / 1000)).round().clamp(totalTroops ~/ 4, totalTroops);
    }
  }

  /// 英雄のパフォーマンスを評価
  static List<HeroBattleResult> _evaluateHeroPerformance(List<game.Hero> heroes, bool factionWon) {
    return heroes.map((hero) {
      final performance = _determineHeroPerformance(hero, factionWon);
      final experienceGained = _calculateExperienceGain(performance);
      
      return HeroBattleResult(
        hero: hero,
        performance: performance,
        experienceGained: experienceGained,
        isInjured: performance == HeroPerformance.poor && !factionWon,
      );
    }).toList();
  }

  /// 英雄のパフォーマンスを決定
  static HeroPerformance _determineHeroPerformance(game.Hero hero, bool factionWon) {
    final combatRating = hero.stats.combatPower;
    
    if (factionWon) {
      if (combatRating > 80) return HeroPerformance.outstanding;
      if (combatRating > 60) return HeroPerformance.good;
      return HeroPerformance.good;
    } else {
      if (combatRating > 90) return HeroPerformance.good;
      if (combatRating > 70) return HeroPerformance.poor;
      return HeroPerformance.defeated;
    }
  }

  /// 経験値獲得量を計算
  static int _calculateExperienceGain(HeroPerformance performance) {
    switch (performance) {
      case HeroPerformance.outstanding:
        return 100;
      case HeroPerformance.good:
        return 60;
      case HeroPerformance.poor:
        return 20;
      case HeroPerformance.defeated:
        return 10;
    }
  }

  /// 特殊イベントを生成
  static List<String> _generateSpecialEvents(BattleParticipant attacker, BattleParticipant defender) {
    final events = <String>[];
    
    // 英雄の活躍による特殊イベント
    for (final hero in [...attacker.heroes, ...defender.heroes]) {
      if (hero.stats.combatPower > 90) {
        events.add('${hero.nickname}が戦場で大活躍！');
      }
    }
    
    return events;
  }
}

/// 地形修正値
class TerrainModifier {
  const TerrainModifier({
    required this.modifier,
    required this.favorDefender,
  });

  final double modifier;
  final bool favorDefender;
}

/// 戦術修正値
class TacticModifier {
  const TacticModifier({
    required this.attackerBonus,
    required this.defenderBonus,
  });

  final double attackerBonus;
  final double defenderBonus;
}
