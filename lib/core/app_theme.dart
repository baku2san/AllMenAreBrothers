/// 水滸伝戦略ゲーム - モダンテーマシステム
/// Material Design 3 完全準拠の統一テーマシステム
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_config.dart';

/// モダンカラーシステム
class ModernColors {
  ModernColors._();

  /// シード色
  static const Color primarySeed = Color(0xFF1B5E20);
  static const Color secondarySeed = Color(0xFFFF8F00);

  /// カスタムカラー
  static const Color goldAccent = Color(0xFFFFB300);
  static const Color redAccent = Color(0xFFD32F2F);
  static const Color emperialPurple = Color(0xFF6A1B9A);

  /// 勢力カラー（高コントラスト版）
  static const Map<String, Color> factionColors = {
    'liangshan': Color(0xFF1B5E20),
    'imperial': Color(0xFF6A1B9A),
    'warlord': Color(0xFFD32F2F),
    'bandit': Color(0xFF5D4037),
    'neutral': Color(0xFF757575),
  };

  /// グラデーションカラー
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient surfaceGradient = RadialGradient(
    colors: [Color(0xFFFFFBFF), Color(0xFFF8F9FA)],
    center: Alignment.topLeft,
    radius: 1.2,
  );
}

/// モダンシャドウスタイル
class ModernShadows {
  ModernShadows._();

  /// エレベーション1（微細な影）
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// エレベーション2（通常の影）
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 1),
    ),
  ];

  /// エレベーション3（浮上した影）
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  /// エレベーション4（強調された影）
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 16,
      offset: Offset(0, 2),
    ),
  ];

  /// カラードシャドウ（プライマリ）
  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.2}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: color.withValues(alpha: opacity * 0.5),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ];
}

/// モダンボーダーラディウス
class ModernRadius {
  ModernRadius._();

  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;

  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get xxlRadius => BorderRadius.circular(xxl);

  /// 非対称角丸
  static BorderRadius get topRadius => const BorderRadius.only(
        topLeft: Radius.circular(md),
        topRight: Radius.circular(md),
      );

  static BorderRadius get bottomRadius => const BorderRadius.only(
        bottomLeft: Radius.circular(md),
        bottomRight: Radius.circular(md),
      );
}

/// モダンスペーシングシステム
class ModernSpacing {
  ModernSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  /// エッジインセット
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  /// 水平パディング
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  /// 垂直パディング
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);
}

/// 統一テーマシステム
class ModernTheme {
  ModernTheme._();

  /// ライトテーマ（モダン版）
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ModernColors.primarySeed,
      brightness: Brightness.light,
      secondary: ModernColors.secondarySeed,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'Noto Sans JP',
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // AppBar テーマ
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      ),

      // カード テーマ
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: ModernRadius.mdRadius,
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        color: colorScheme.surface,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      ),

      // FilledButton テーマ
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: ModernRadius.mdRadius,
          ),
          padding: ModernSpacing.paddingMD,
          elevation: 0,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ElevatedButton テーマ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: ModernRadius.mdRadius,
          ),
          padding: ModernSpacing.paddingMD,
          elevation: 1,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // OutlinedButton テーマ
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: ModernRadius.mdRadius,
          ),
          padding: ModernSpacing.paddingMD,
          side: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // TextButton テーマ
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: ModernRadius.mdRadius,
          ),
          padding: ModernSpacing.paddingMD,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // InputDecoration テーマ
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: ModernRadius.mdRadius,
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ModernRadius.mdRadius,
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ModernRadius.mdRadius,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ModernRadius.mdRadius,
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        contentPadding: ModernSpacing.paddingMD,
      ),

      // Chip テーマ
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceVariant.withValues(alpha: 0.5),
        labelStyle: AppTextStyles.labelSmall,
        shape: RoundedRectangleBorder(
          borderRadius: ModernRadius.xlRadius,
        ),
        side: BorderSide.none,
        padding: ModernSpacing.horizontalMD,
      ),

      // Dialog テーマ
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: ModernRadius.xlRadius,
        ),
        elevation: 3,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // BottomSheet テーマ
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: ModernRadius.topRadius,
        ),
        elevation: 3,
        modalBackgroundColor: colorScheme.surface,
      ),
    );
  }

  /// ダークテーマ（モダン版）
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ModernColors.primarySeed,
      brightness: Brightness.dark,
      secondary: ModernColors.secondarySeed,
    );

    return lightTheme.copyWith(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      appBarTheme: lightTheme.appBarTheme.copyWith(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}

/// コンポーネント装飾スタイル
class ModernDecorations {
  ModernDecorations._();

  /// 基本カード装飾
  static BoxDecoration card(ColorScheme colorScheme) => BoxDecoration(
        color: colorScheme.surface,
        borderRadius: ModernRadius.mdRadius,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: ModernShadows.elevation1,
      );

  /// 浮上カード装飾
  static BoxDecoration elevatedCard(ColorScheme colorScheme) => BoxDecoration(
        color: colorScheme.surface,
        borderRadius: ModernRadius.mdRadius,
        boxShadow: ModernShadows.elevation2,
      );

  /// プライマリコンテナ装飾
  static BoxDecoration primaryContainer(ColorScheme colorScheme) => BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: ModernRadius.mdRadius,
        boxShadow: ModernShadows.coloredShadow(colorScheme.primary, opacity: 0.1),
      );

  /// セカンダリコンテナ装飾
  static BoxDecoration secondaryContainer(ColorScheme colorScheme) => BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: ModernRadius.mdRadius,
        boxShadow: ModernShadows.coloredShadow(colorScheme.secondary, opacity: 0.1),
      );

  /// ゴールドアクセント装飾
  static BoxDecoration goldAccent(ColorScheme colorScheme) => BoxDecoration(
        gradient: ModernColors.goldGradient,
        borderRadius: ModernRadius.mdRadius,
        boxShadow: ModernShadows.coloredShadow(ModernColors.goldAccent, opacity: 0.2),
      );

  /// サーフェイス装飾（背景用）
  static BoxDecoration surfaceBackground(ColorScheme colorScheme) => BoxDecoration(
        gradient: ModernColors.surfaceGradient,
      );
}
