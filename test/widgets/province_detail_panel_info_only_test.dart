import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_margin_game/models/province.dart';
import 'package:water_margin_game/widgets/province_detail_panel_info_only.dart';
import 'package:water_margin_game/controllers/water_margin_game_controller.dart';
import 'package:water_margin_game/models/water_margin_strategy_game.dart';

void main() {
  testWidgets('ProvinceDetailPanel 基本表示テスト', (WidgetTester tester) async {
    // ダミー Province
    final province = Province(
      name: 'テスト州',
      population: 500,
      agriculture: 80,
      commerce: 60,
      security: 70,
      publicSupport: 90,
      military: 100,
      resources: [],
      development: 50,
      neighbors: ['隣州A', '隣州B'],
    );
    // ダミー GameState（必要なフィールドのみ）
    final gameState = WaterMarginGameState(
      provinces: {'テスト州': province},
      factions: {'テスト州': Faction.liangshan},
      heroes: [],
      currentTurn: 1,
      playerGold: 1000,
      gameStatus: GameStatus.playing,
    );
    // ダミー Controller（引数なしで初期化）
    final controller = WaterMarginGameController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProvinceDetailPanel(
            province: province,
            gameState: gameState,
            controller: controller,
          ),
        ),
      ),
    );

    // 州名が表示される
    expect(find.text('テスト州'), findsOneWidget);
    // 支配情報ラベル
    expect(find.text('支配情報'), findsOneWidget);
    // 兵力表示
    expect(find.textContaining('兵力:'), findsOneWidget);
    // 州の状況ラベル
    expect(find.text('州の状況'), findsOneWidget);
  });
}
