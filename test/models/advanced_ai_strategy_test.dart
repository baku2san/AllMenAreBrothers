import 'package:water_margin_game/models/ai_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_margin_game/models/advanced_ai_strategy.dart';
import 'package:water_margin_game/models/province.dart';
import 'package:water_margin_game/models/water_margin_strategy_game.dart';

void main() {
  group('AdvancedAIStrategy', () {
    test('AIが領土拡張戦略で攻撃行動を計画できる', () {
      final provinceA = Province(
        name: 'A',
        population: 10000,
        agriculture: 80,
        commerce: 80,
        security: 0.8,
        publicSupport: 0.8,
        military: 1000,
        resources: [
          Resource(type: ResourceType.rice, baseYield: 0, demand: 1.0, price: 1.0),
        ],
        development: 50,
        neighbors: ['B'],
      );
      final provinceB = Province(
        name: 'B',
        population: 8000,
        agriculture: 60,
        commerce: 60,
        security: 0.7,
        publicSupport: 0.7,
        military: 500,
        resources: [],
        development: 40,
        neighbors: [],
      );
      final gameState = WaterMarginGameState(
        provinces: {'A': provinceA, 'B': provinceB},
        heroes: const [],
        factions: {
          'A': Faction.liangshan,
          'B': Faction.bandit,
        },
        currentTurn: 1,
        playerGold: 1000,
        gameStatus: GameStatus.playing,
      );
      final ai = AdvancedAIStrategy(
        level: AIStrategyLevel.advanced,
        longTermStrategy: LongTermStrategy.expansion,
        factionId: Faction.liangshan,
      );
      final result = ai.performStrategicThinking(gameState);
      expect(result.allActions.any((a) => a.type == AIActionType.attack), isTrue);
    });
  });
}
