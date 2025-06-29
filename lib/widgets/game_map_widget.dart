/// ゲームマップ表示ウィジェット
/// 州の配置とプレイヤーの操作を処理
library;

import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';

/// ゲームマップウィジェット
class GameMapWidget extends StatefulWidget {
  const GameMapWidget({
    super.key,
    required this.gameState,
    required this.onProvinceSelected,
  });

  final WaterMarginGameState gameState;
  final void Function(String?) onProvinceSelected;

  @override
  State<GameMapWidget> createState() => _GameMapWidgetState();
}

class _GameMapWidgetState extends State<GameMapWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.brown.shade200,
            Colors.green.shade100,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 背景のマップタイトル
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '北宋天下図',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 州の配置
          ...widget.gameState.provinces.values.map((province) => 
            _buildProvinceMarker(province)),
        ],
      ),
    );
  }

  /// 州マーカーの構築
  Widget _buildProvinceMarker(Province province) {
    final screenSize = MediaQuery.of(context).size;
    final mapArea = Size(screenSize.width * 0.75, screenSize.height - 56); // AppBarを除く
    
    final position = Offset(
      mapArea.width * province.position.dx - 40, // マーカーの半分の幅
      mapArea.height * province.position.dy - 40, // マーカーの半分の高さ
    );

    final isSelected = widget.gameState.selectedProvinceId == province.id;
    final isPlayerProvince = province.controller == Faction.liangshan;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => widget.onProvinceSelected(province.id),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.yellow.withValues(alpha: 0.9)
                : province.controller.factionColor.withValues(alpha: 0.8),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.black,
              width: isSelected ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 州のアイコン
              Text(
                province.provinceIcon,
                style: const TextStyle(fontSize: 20),
              ),
              
              // 州名
              Text(
                province.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              // 兵力表示
              if (isPlayerProvince || isSelected)
                Text(
                  '${province.currentTroops}',
                  style: TextStyle(
                    fontSize: 8,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
