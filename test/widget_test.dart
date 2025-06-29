// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:water_margin_game/main.dart';

void main() {
  testWidgets('水滸伝ゲーム基本テスト', (WidgetTester tester) async {
    // テスト用の画面サイズを設定（レイアウトオーバーフロー対策）
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    
    // アプリをビルドして最初のフレームをトリガー
    await tester.pumpWidget(const WaterMarginApp());
    
    // レイアウトの完了を待つ
    await tester.pumpAndSettle();

    // AppBarのタイトルを確認
    expect(find.text('水滸伝 天下統一'), findsOneWidget);
    
    // 梁山泊情勢パネルがあることを確認
    expect(find.text('梁山泊情勢'), findsOneWidget);
    
    // ターン終了ボタンがあることを確認
    expect(find.text('ターン終了'), findsWidgets);
  });
}
