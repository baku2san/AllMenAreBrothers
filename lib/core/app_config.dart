/// 水滸伝戦略ゲーム - アプリケーション設定
/// 定数やテーマなどのアプリケーション全体で使用する設定を管理
library;

import 'package:flutter/material.dart';

/// アプリケーション定数
class AppConstants {
  // プライベートコンストラクタ（静的クラスとして使用）
  AppConstants._();

  /// アプリ情報
  static const String appName = '水滸伝 天下統一';
  static const String appDescription = '中国古典小説「水滸伝」を題材にしたターン制戦略シミュレーションゲーム';
  static const String version = '1.0.0';

  /// ゲーム設定
  static const int initialPlayerGold = 1000;
  static const int developmentCost = 200;
  static const int maxEventLogEntries = 20;
  static const int maxDevelopmentLevel = 100;

  /// UIレイアウト設定
  static const double mapAreaFlex = 3.0;
  static const double sidebarWidth = 300.0;
  static const double defaultPadding = 8.0;
  static const double defaultBorderRadius = 8.0;

  /// アニメーション設定
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
}

/// カラーパレット
class AppColors {
  AppColors._();

  /// 基本カラー（梁山泊をイメージした緑系）
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color darkGreen = Color(0xFF1B5E20);
  
  /// アクセントカラー（中国古典の金系）
  static const Color accentGold = Color(0xFFFFB300);
  static const Color lightGold = Color(0xFFFFC947);
  static const Color darkGold = Color(0xFFFF8F00);

  /// 勢力カラー
  static const Color liangshan = primaryGreen;
  static const Color imperial = Color(0xFF7B1FA2);
  static const Color warlord = Color(0xFFD32F2F);
  static const Color bandit = Color(0xFF5D4037);
  static const Color neutral = Color(0xFF616161);

  /// ステータスカラー
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE91E63);
  static const Color info = Color(0xFF2196F3);

  /// 背景・表面色
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF212121);
}

/// テキストスタイル
class AppTextStyles {
  AppTextStyles._();

  /// ヘッダーテキスト
  static const TextStyle header = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryGreen,
  );

  /// サブヘッダーテキスト
  static const TextStyle subHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGreen,
  );

  /// 本文テキスト
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceLight,
  );

  /// キャプションテキスト
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  /// ボタンテキスト
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

/// アプリテーマ
class AppTheme {
  AppTheme._();

  /// ライトテーマ
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Noto Sans JP',
      
      // AppBar テーマ
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // カード テーマ
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        color: AppColors.surfaceLight,
      ),

      // ボタン テーマ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // テキスト テーマ
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.header,
        headlineMedium: AppTextStyles.subHeader,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.body,
        labelLarge: AppTextStyles.button,
        bodySmall: AppTextStyles.caption,
      ),
    );
  }

  /// ダークテーマ（将来の拡張用）
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.dark,
      ),
    );
  }
}

/// レスポンシブブレークポイント
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// 現在の画面サイズがモバイルかどうか
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// 現在の画面サイズがタブレットかどうか
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// 現在の画面サイズがデスクトップかどうか
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
}
