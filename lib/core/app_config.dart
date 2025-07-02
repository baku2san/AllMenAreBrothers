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
  static const int recruitmentCostPerTroop = 10;
  static const int foodSupplyCost = 300; // 兵糧補給コスト
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

  /// 基本カラーパレット（Material Design 3準拠）
  static const Color primary = Color(0xFF1B5E20);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFA7F3A1);
  static const Color onPrimaryContainer = Color(0xFF002106);

  static const Color secondary = Color(0xFFFF8F00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFFE0A3);
  static const Color onSecondaryContainer = Color(0xFF3D2F00);

  static const Color tertiary = Color(0xFF2196F3);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFBBDEFB);
  static const Color onTertiaryContainer = Color(0xFF0D47A1);

  /// 表面色
  static const Color surface = Color(0xFFFFFBFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color surfaceLight = Color(0xFFF5F5F5);

  /// エラー・警告色
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color warning = Color(0xFFE65100);
  static const Color success = Color(0xFF2E7D32);
  static const Color info = Color(0xFF1976D2);

  /// 勢力カラー（より鮮やかで識別しやすく）
  static const Color liangshan = Color(0xFF1B5E20);
  static const Color imperial = Color(0xFF6A1B9A);
  static const Color warlord = Color(0xFFD32F2F);
  static const Color bandit = Color(0xFF5D4037);
  static const Color neutral = Color(0xFF757575);

  /// アクセントカラー
  static const Color accentGold = Color(0xFFFFB300);
  static const Color darkGreen = Color(0xFF0A3D0C);
  static const Color lightGreen = Color(0xFF81C784);

  /// レガシーサポート（後方互換性）
  static const Color primaryGreen = primary;
}

/// モダンなテキストスタイル
class AppTextStyles {
  AppTextStyles._();

  /// Display スタイル
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  /// Headline スタイル
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  /// Title スタイル
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Body スタイル
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  /// Label スタイル
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  /// レガシーサポート
  static const TextStyle header = headlineMedium;
  static const TextStyle subHeader = titleLarge;
  static const TextStyle body = bodyMedium;
  static const TextStyle caption = bodySmall;
  static const TextStyle button = labelLarge;
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
      cardTheme: CardThemeData(
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
