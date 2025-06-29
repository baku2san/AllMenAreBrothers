/// 水滸伝戦略ゲーム - メインアプリケーション
/// 梁山泊を拠点に天下統一を目指すターン制戦略ゲーム
library;

import 'package:flutter/material.dart';
import 'screens/water_margin_game_screen.dart';
import 'core/app_config.dart';

void main() {
  runApp(const WaterMarginApp());
}

/// 水滸伝ゲームアプリケーション
class WaterMarginApp extends StatelessWidget {
  const WaterMarginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const WaterMarginGameScreen(),
    );
  }
}

