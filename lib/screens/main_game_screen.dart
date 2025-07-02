/// 水滸伝戦略ゲームのメイン画面
/// マップ表示と基本的なゲーム操作を提供
library;

import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';
import '../widgets/game_map_widget.dart';
import '../widgets/game_info_panel.dart';
import '../services/strategy_game_service.dart';

/// メインゲーム画面
class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  late WaterMarginGameState _gameState;
  late WaterMarginGameService _gameService;

  @override
  void initState() {
    super.initState();
    _gameService = WaterMarginGameService();
    _initializeGame();
  }

  /// ゲーム状態の初期化
  void _initializeGame() {
    _gameState = _gameService.initializeGame();
  }

  /// 州選択処理
  void _onProvinceSelected(String? provinceId) {
    setState(() {
      _gameState = _gameState.copyWith(selectedProvinceId: provinceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '水滸伝戦略ゲーム',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // 設定画面を開く
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // 左側: マップ画面
          Expanded(
            flex: 3,
            child: GameMapWidget(
              gameState: _gameState,
              onProvinceSelected: _onProvinceSelected,
            ),
          ),

          // 右側: 情報パネル
          Container(
            width: 300,
            color: Colors.grey.shade100,
            child: Column(
              children: [
                // ゲーム情報パネル
                GameInfoPanel(
                  gameState: _gameState,
                  eventHistory: const [], // main_game_screen.dartは使用されていないため空リスト
                ),

                // 選択された州の詳細パネル
                if (_gameState.selectedProvince != null)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'このファイルは使用されていません\nwater_margin_game_screen.dartを使用してください',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 設定ダイアログを表示
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設定'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ゲーム設定'),
            SizedBox(height: 16),
            Text('音量調整、表示設定などは今後実装予定です。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
