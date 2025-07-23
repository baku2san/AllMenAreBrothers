/// 水滸伝戦略ゲーム - Providerパターン対応メイン画面
library;

import 'package:flutter/material.dart';
import 'province_detail_screen.dart';
import 'package:provider/provider.dart';

import '../controllers/water_margin_game_controller.dart';
import '../widgets/game_map_widget.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/province_detail_panel.dart';
import '../widgets/battle_result_dialog.dart';
import '../widgets/game_command_bar.dart';
import '../widgets/difficulty_selection_dialog.dart';
import '../widgets/tutorial_hint_panel.dart';
import '../core/app_config.dart';
import '../core/app_theme.dart';

/// 水滸伝戦略ゲームのメイン画面
class WaterMarginGameScreen extends StatelessWidget {
  const WaterMarginGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WaterMarginGameController(),
      child: const _WaterMarginGameView(),
    );
  }
}

class _WaterMarginGameView extends StatefulWidget {
  const _WaterMarginGameView();

  @override
  State<_WaterMarginGameView> createState() => _WaterMarginGameViewState();
}

class _WaterMarginGameViewState extends State<_WaterMarginGameView> {
  bool _isInitialized = false;
  bool _isInitializing = false; // 初期化中フラグを追加

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDifficultySelection();
    });
  }

  /// 難易度選択ダイアログを表示
  Future<void> _showDifficultySelection() async {
    if (_isInitialized || _isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      debugPrint('🎯 難易度選択ダイアログ開始');
      final controller = context.read<WaterMarginGameController>();

      if (!mounted) return;
      debugPrint('🎯 ダイアログ表示中...');
      final selectedDifficulty = await showDifficultySelectionDialog(context);
      debugPrint('🎯 選択された難易度: $selectedDifficulty');

      if (selectedDifficulty != null) {
        debugPrint('🎮 ゲーム初期化開始（選択された難易度: ${selectedDifficulty.displayName}）');
        await controller.initializeGameWithDifficulty(selectedDifficulty);
        debugPrint('🎮 初期化メソッド呼び出し完了');
      } else {
        debugPrint('🎮 ゲーム初期化開始（デフォルト難易度）');
        // キャンセルされた場合は標準難易度
        await controller.initializeGame();
        debugPrint('🎮 デフォルト初期化メソッド呼び出し完了');
      }

      // 初期化完了後の状態チェック
      await Future.delayed(const Duration(milliseconds: 200)); // 状態反映を待つ
      debugPrint('📊 provinces内容: ${controller.gameState.provinces}');
      debugPrint('📊 provinces.keys: ${controller.gameState.provinces.keys.toList()}');
      debugPrint('📊 provinces.names: ${controller.gameState.provinces.values.map((p) => p.name).toList()}');
      debugPrint('📊 heroes内容: ${controller.gameState.heroes}');
      debugPrint('📊 heroes.names: ${controller.gameState.heroes.map((h) => h.name).toList()}');

      // 初期化が本当に完了したかチェック
      if (controller.gameState.provinces.isNotEmpty && controller.gameState.heroes.isNotEmpty) {
        debugPrint('✅ 初期化完了確認OK');
        if (mounted) {
          debugPrint('🔄 setState実行中...');
          setState(() {
            _isInitialized = true;
            _isInitializing = false;
          });
          debugPrint('✅ 初期化完了フラグ設定完了');
        }
      } else {
        debugPrint(
            '❌ 初期化未完了 - provinces=${controller.gameState.provinces.length}, heroes=${controller.gameState.heroes.length}');
        debugPrint('❌ provinces詳細: ${controller.gameState.provinces}');
        debugPrint('❌ heroes詳細: ${controller.gameState.heroes}');
        // 初期化が失敗した場合の処理
        if (mounted) {
          debugPrint('🔄 再初期化試行中...');
          await controller.initializeGame(); // 再試行
          await Future.delayed(const Duration(milliseconds: 200));
          setState(() {
            _isInitialized = true;
            _isInitializing = false;
          });
          debugPrint('🔄 再初期化完了');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 難易度選択エラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      // エラーが発生した場合はデフォルト初期化
      if (mounted) {
        debugPrint('🔄 エラー後フォールバック初期化...');
        final controller = context.read<WaterMarginGameController>();
        try {
          await controller.initializeGame();
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (fallbackError) {
          debugPrint('❌ フォールバック初期化もエラー: $fallbackError');
        }
        // キャンセル時・エラー時でも必ずUIを更新
        setState(() {
          _isInitialized = true;
          _isInitializing = false;
        });
        debugPrint('🔄 フォールバック初期化完了（UI強制更新）');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Container(
          padding: ModernSpacing.horizontalMD,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: ModernSpacing.paddingXS,
                decoration: ModernDecorations.goldAccent(colorScheme),
                child: Icon(
                  Icons.castle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppConstants.appName,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        centerTitle: true,
        actions: [
          Consumer<WaterMarginGameController>(
            builder: (context, controller, child) {
              return Container(
                padding: ModernSpacing.paddingMD,
                margin: const EdgeInsets.only(right: 8),
                decoration: ModernDecorations.goldAccent(colorScheme),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.gameState.playerGold}両',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer<WaterMarginGameController>(
            builder: (context, controller, child) {
              return Container(
                padding: ModernSpacing.paddingMD,
                margin: const EdgeInsets.only(right: 16),
                decoration: ModernDecorations.primaryContainer(colorScheme),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ターン${controller.gameState.currentTurn}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<WaterMarginGameController>(
        builder: (context, controller, child) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          debugPrint(
              '🔄 Build実行: _isInitialized=$_isInitialized, _isInitializing=$_isInitializing, provinces=${controller.gameState.provinces.length}');

          // 初期化中または初期化未完了の場合はローディング画面を表示
          if (_isInitializing || !_isInitialized) {
            debugPrint('🔄 ローディング画面表示中...');
            return Container(
              color: colorScheme.surface,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text(
                      'ゲームを初期化中...',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'しばらくお待ちください',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          debugPrint('🎮 ゲーム画面表示中...');

          // コントローラーにcontextを設定（トースト通知用）
          controller.setContext(context);

          // 戦闘結果ダイアログの自動表示
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.lastBattleResult != null) {
              _showBattleResultDialog(context, controller);
            }
          });

          try {
            debugPrint('🔧 ゲーム画面UI構築開始...');

            return Container(
              decoration: ModernDecorations.surfaceBackground(colorScheme),
              child: Stack(
                children: [
                  Row(
                    children: [
                      // メインマップ領域
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            // マップ
                            Expanded(
                              child: Column(
                                children: [
                                  // マップ表示
                                  Expanded(
                                    child: Container(
                                      margin: ModernSpacing.paddingMD,
                                      decoration: ModernDecorations.elevatedCard(colorScheme),
                                      child: ClipRRect(
                                        borderRadius: ModernRadius.mdRadius,
                                        child: Builder(
                                          builder: (context) {
                                            try {
                                              debugPrint('🗺️ GameMapWidget構築中...');
                                              return GameMapWidget(
                                                gameState: controller.gameState,
                                                onProvinceSelected: controller.selectProvince,
                                              );
                                            } catch (e, stackTrace) {
                                              debugPrint('❌ GameMapWidget構築エラー: $e');
                                              debugPrint('スタックトレース: $stackTrace');
                                              return Container(
                                                color: Colors.red.withValues(alpha: 0.1),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.error, size: 48, color: Colors.red),
                                                      const SizedBox(height: 16),
                                                      Text('マップ読み込みエラー', style: TextStyle(color: Colors.red)),
                                                      const SizedBox(height: 8),
                                                      Text('$e', style: TextStyle(fontSize: 12, color: Colors.red)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  // マップ凡例（より洗練されたデザイン）
                                  if (controller.selectedProvince != null) ...[
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                        ModernSpacing.md,
                                        0,
                                        ModernSpacing.md,
                                        ModernSpacing.md,
                                      ),
                                      decoration: ModernDecorations.card(colorScheme),
                                      child: Padding(
                                        padding: ModernSpacing.paddingMD,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildLegendItem(
                                                '選択中', AppColors.accentGold, Icons.location_on_rounded, colorScheme),
                                            _buildLegendItem(
                                                '隣接州', colorScheme.tertiary, Icons.link_rounded, colorScheme),
                                            _buildLegendItem(
                                                '攻撃可能', colorScheme.error, Icons.gps_fixed_rounded, colorScheme),
                                            _buildLegendItem(
                                                '味方州', colorScheme.primary, Icons.flag_rounded, colorScheme),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // 州詳細画面（経済コマンドUI）
                                    SizedBox(
                                      height: 320,
                                      child: ProvinceDetailScreen(
                                        province: controller.selectedProvince!,
                                        gameState: controller.gameState,
                                        onGameStateUpdated: (newState) {
                                          controller.updateGameState(newState);
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // 統一コマンドバー
                            Builder(
                              builder: (context) {
                                try {
                                  debugPrint('🎮 GameCommandBar構築中...');
                                  return const GameCommandBar();
                                } catch (e, stackTrace) {
                                  debugPrint('❌ GameCommandBar構築エラー: $e');
                                  debugPrint('スタックトレース: $stackTrace');
                                  return Container(
                                    height: 60,
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    child: Center(
                                      child: Text('コマンドバーエラー: $e', style: TextStyle(color: Colors.orange)),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      // サイドバー（モダンデザイン）
                      Container(
                        width: AppConstants.sidebarWidth,
                        margin: ModernSpacing.paddingMD,
                        decoration: ModernDecorations.elevatedCard(colorScheme),
                        child: ClipRRect(
                          borderRadius: ModernRadius.mdRadius,
                          child: Column(
                            children: [
                              // ゲーム情報パネル（改良版）
                              Container(
                                height: 200,
                                decoration: ModernDecorations.primaryContainer(colorScheme),
                                child: Builder(
                                  builder: (context) {
                                    try {
                                      debugPrint('📊 GameInfoPanel構築中...');
                                      return GameInfoPanel(
                                        gameState: controller.gameState,
                                        eventHistory: controller.eventHistory,
                                      );
                                    } catch (e, stackTrace) {
                                      debugPrint('❌ GameInfoPanel構築エラー: $e');
                                      debugPrint('スタックトレース: $stackTrace');
                                      return Container(
                                        color: Colors.yellow.withValues(alpha: 0.1),
                                        child: Center(
                                          child: Text('情報パネルエラー: $e', style: TextStyle(color: Colors.orange)),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),

                              // 州詳細パネル（改良版）
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                  ),
                                  child: controller.selectedProvince != null
                                      ? Builder(
                                          builder: (context) {
                                            try {
                                              debugPrint('🏛️ ProvinceDetailPanel構築中...');
                                              return ProvinceDetailPanel(
                                                province: controller.selectedProvince!,
                                                gameState: controller.gameState,
                                                controller: controller,
                                              );
                                            } catch (e, stackTrace) {
                                              debugPrint('❌ ProvinceDetailPanel構築エラー: $e');
                                              debugPrint('スタックトレース: $stackTrace');
                                              return Container(
                                                color: Colors.purple.withValues(alpha: 0.1),
                                                child: Center(
                                                  child: Text('州詳細パネルエラー: $e', style: TextStyle(color: Colors.purple)),
                                                ),
                                              );
                                            }
                                          },
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: ModernSpacing.paddingXL,
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.touch_app_rounded,
                                                  size: 48,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                '州を選択してください',
                                                style: AppTextStyles.bodyLarge.copyWith(
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // チュートリアル・ヒントパネル
                  if (controller.showTutorial)
                    Builder(
                      builder: (context) {
                        try {
                          debugPrint('💡 TutorialHintPanel構築中...');
                          return TutorialHintPanel(
                            gameState: controller.gameState,
                            onClose: controller.hideTutorial,
                          );
                        } catch (e, stackTrace) {
                          debugPrint('❌ TutorialHintPanel構築エラー: $e');
                          debugPrint('スタックトレース: $stackTrace');
                          return Container(
                            color: Colors.blue.withValues(alpha: 0.1),
                            child: Center(
                              child: Text('チュートリアルパネルエラー: $e', style: TextStyle(color: Colors.blue)),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            );
          } catch (e, stackTrace) {
            debugPrint('❌ ゲーム画面全体構築エラー: $e');
            debugPrint('スタックトレース: $stackTrace');
            return Container(
              color: colorScheme.errorContainer,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                    const SizedBox(height: 24),
                    Text(
                      'ゲーム画面の読み込みに失敗しました',
                      style: AppTextStyles.headlineSmall.copyWith(color: colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'エラー詳細: $e',
                      style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onErrorContainer),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // 画面をリロード
                        setState(() {
                          _isInitialized = false;
                          _isInitializing = false;
                        });
                        _showDifficultySelection();
                      },
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// 凡例アイテムを構築（モダンデザイン）
  Widget _buildLegendItem(String label, Color color, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: ModernSpacing.paddingMD,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: ModernRadius.mdRadius,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: ModernShadows.coloredShadow(color, opacity: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: ModernRadius.smRadius,
              boxShadow: ModernShadows.coloredShadow(color, opacity: 0.3),
            ),
            child: Icon(
              icon,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 戦闘結果ダイアログを表示
  void _showBattleResultDialog(BuildContext context, WaterMarginGameController controller) {
    final battleResult = controller.lastBattleResult;
    if (battleResult == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BattleResultDialog(
        result: battleResult.result,
        attackerProvinceName: battleResult.sourceProvinceName,
        defenderProvinceName: battleResult.targetProvinceName,
      ),
    ).then((_) {
      // ダイアログが閉じられたら戦闘結果をクリア
      controller.clearBattleResult();
    });
  }
}
