/// 水滸伝戦略ゲーム - メインアプリケーション
/// 梁山泊を拠点に天下統一を目指すターン制戦略ゲーム
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/water_margin_game_screen.dart';
import 'core/app_config.dart';
import 'core/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // システムUIオーバーレイスタイルを設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // エッジツーエッジ表示を有効化
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  runApp(const WaterMarginApp());
}

/// 水滸伝ゲームアプリケーション
class WaterMarginApp extends StatelessWidget {
  const WaterMarginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ModernTheme.lightTheme,
      darkTheme: ModernTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WaterMarginGameScreen(),
    );
  }
}
