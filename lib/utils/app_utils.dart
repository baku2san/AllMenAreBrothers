/// 水滸伝戦略ゲーム - ユーティリティ関数
/// アプリケーション全体で使用する共通関数を定義
library;

import 'package:flutter/material.dart' hide Hero;
import '../models/water_margin_strategy_game.dart';
import '../core/app_config.dart';

/// 数値関連のユーティリティ
class NumberUtils {
  NumberUtils._();

  /// 数値を指定範囲内にクランプ
  static int clampInt(int value, int min, int max) {
    return value.clamp(min, max);
  }

  /// パーセンテージを文字列で表示
  static String toPercentage(int value, {int maxValue = 100}) {
    final percentage = (value / maxValue * 100).round();
    return '$percentage%';
  }

  /// 大きな数値を読みやすい形式に変換（例：1000 → 1K）
  static String formatLargeNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}

/// メインのアプリケーションユーティリティ
class AppUtils {
  AppUtils._();

  /// 金額を読みやすい形式でフォーマット
  static String formatGold(int gold) {
    if (gold >= 1000000) {
      return '${(gold / 1000000).toStringAsFixed(1)}M両';
    } else if (gold >= 1000) {
      return '${(gold / 1000).toStringAsFixed(1)}K両';
    } else {
      return '$gold両';
    }
  }

  /// ターン数を表示用にフォーマット
  static String formatTurn(int turn) {
    return 'ターン$turn';
  }

  /// 人口を読みやすい形式でフォーマット
  static String formatPopulation(int population) {
    if (population >= 10000) {
      return '${(population / 10000).toStringAsFixed(1)}万人';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(1)}千人';
    } else {
      return '$population人';
    }
  }

  /// 開発レベルをパーセンテージ表示
  static String formatDevelopmentLevel(int level) {
    return NumberUtils.toPercentage(level);
  }

  /// 勢力名を日本語で取得
  static String getFactionDisplayName(Faction faction) {
    switch (faction) {
      case Faction.liangshan:
        return '梁山泊';
      case Faction.imperial:
        return '朝廷';
      case Faction.warlord:
        return '豪族';
      case Faction.bandit:
        return '盗賊';
      case Faction.neutral:
        return '中立';
    }
  }

  /// 日付/時刻の表示用フォーマット
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 割合を色付きテキストで表示するためのカラー取得
  static Color getValueColor(int current, int max) {
    final ratio = current / max;
    if (ratio >= 0.8) return AppColors.success;
    if (ratio >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  /// 開発タイプに対応するアイコンを取得
  static IconData getDevelopmentTypeIcon(DevelopmentType type) {
    switch (type) {
      case DevelopmentType.agriculture:
        return Icons.agriculture;
      case DevelopmentType.commerce:
        return Icons.store;
      case DevelopmentType.military:
        return Icons.security;
      case DevelopmentType.security:
        return Icons.shield;
    }
  }
}

/// 文字列関連のユーティリティ
class StringUtils {
  StringUtils._();

  /// 文字列が空かnullかチェック
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  /// 文字列を指定長でトランケート
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// 勢力名を日本語表示用に変換
  static String getFactionDisplayName(Faction faction) {
    switch (faction) {
      case Faction.liangshan:
        return '梁山泊';
      case Faction.imperial:
        return '朝廷';
      case Faction.warlord:
        return '豪族';
      case Faction.bandit:
        return '盗賊';
      case Faction.neutral:
        return '中立';
    }
  }

  /// 開発種類を日本語表示用に変換
  static String getDevelopmentTypeDisplayName(DevelopmentType type) {
    switch (type) {
      case DevelopmentType.agriculture:
        return '農業';
      case DevelopmentType.commerce:
        return '商業';
      case DevelopmentType.military:
        return '軍事';
      case DevelopmentType.security:
        return '治安';
    }
  }

  /// 英雄スキルを日本語表示用に変換
  static String getHeroSkillDisplayName(HeroSkill skill) {
    switch (skill) {
      case HeroSkill.warrior:
        return '武将';
      case HeroSkill.strategist:
        return '軍師';
      case HeroSkill.administrator:
        return '政治家';
      case HeroSkill.diplomat:
        return '外交官';
      case HeroSkill.scout:
        return '斥候';
    }
  }
}

/// 色関連のユーティリティ
class ColorUtils {
  ColorUtils._();

  /// 勢力に対応する色を取得
  static Color getFactionColor(Faction faction) {
    switch (faction) {
      case Faction.liangshan:
        return AppColors.liangshan;
      case Faction.imperial:
        return AppColors.imperial;
      case Faction.warlord:
        return AppColors.warlord;
      case Faction.bandit:
        return AppColors.bandit;
      case Faction.neutral:
        return AppColors.neutral;
    }
  }

  /// パフォーマンス値に基づく色を取得（緑→黄→赤）
  static Color getPerformanceColor(int value, {int maxValue = 100}) {
    final ratio = value / maxValue;
    if (ratio >= 0.7) {
      return AppColors.success;
    } else if (ratio >= 0.4) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  /// 色の明度を調整
  static Color adjustBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final adjustedLightness = (hsl.lightness * factor).clamp(0.0, 1.0);
    return hsl.withLightness(adjustedLightness).toColor();
  }
}

/// UI関連のユーティリティ
class UIUtils {
  UIUtils._();

  /// 成功メッセージスナックバーを表示
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// エラーメッセージスナックバーを表示
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// 情報メッセージスナックバーを表示
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 確認ダイアログを表示
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'はい',
    String cancelText = 'いいえ',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// ローディングダイアログを表示
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  /// ローディングダイアログを閉じる
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// ゲームロジック関連のユーティリティ
class GameUtils {
  GameUtils._();

  /// 戦闘力計算
  static int calculateCombatPower(int troops, int military, {int heroBonus = 0}) {
    final basePower = (troops * 0.7 + military * 0.3).round();
    return basePower + heroBonus;
  }

  /// 収入計算
  static int calculateIncome(int population, int commerce, {int heroBonus = 0}) {
    final baseIncome = ((population / 100) * commerce * 0.5).round();
    return baseIncome + heroBonus;
  }

  /// 開発効果の計算
  static int calculateDevelopmentEffect(
    int currentLevel,
    DevelopmentType type, {
    int baseIncrease = 10,
  }) {
    // レベルが高くなるほど効果が低下
    final efficiency = (100 - currentLevel) / 100;
    return (baseIncrease * efficiency).round().clamp(1, baseIncrease);
  }

  /// 勝利条件チェック
  static GameStatus checkVictoryConditions(
    Map<String, Province> provinces,
    List<Hero> heroes,
  ) {
    final playerProvinces = provinces.values
        .where((p) => p.controller == Faction.liangshan)
        .length;
    final totalProvinces = provinces.length;

    // 勝利条件：全州の80%以上を支配
    if (playerProvinces >= (totalProvinces * 0.8)) {
      return GameStatus.victory;
    }

    // 敗北条件：支配州が3つ以下
    if (playerProvinces <= 3) {
      return GameStatus.defeat;
    }

    return GameStatus.playing;
  }
}

/// デバッグ関連のユーティリティ
class DebugUtils {
  DebugUtils._();

  /// デバッグモードかどうかの判定
  static bool get isDebugMode {
    bool debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }

  /// デバッグ情報をコンソールに出力
  static void debugLog(String message, {String? tag}) {
    if (isDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('[$timestamp] $formattedTag$message');
    }
  }

  /// ゲーム状態をデバッグ出力
  static void debugGameState(WaterMarginGameState gameState) {
    if (!isDebugMode) return;

    debugLog('=== ゲーム状態 ===', tag: 'GameState');
    debugLog('ターン: ${gameState.currentTurn}', tag: 'GameState');
    debugLog('軍資金: ${gameState.playerGold}両', tag: 'GameState');
    debugLog('支配州数: ${gameState.playerProvinceCount}', tag: 'GameState');
    debugLog('総兵力: ${gameState.playerTotalTroops}', tag: 'GameState');
    debugLog('仲間数: ${gameState.recruitedHeroCount}', tag: 'GameState');
    debugLog('===============', tag: 'GameState');
  }
}
