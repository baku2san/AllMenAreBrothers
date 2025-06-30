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

          // 隣接関係の線を描画
          if (widget.gameState.selectedProvinceId != null) _buildAdjacencyLines(),

          // 州の配置
          ...widget.gameState.provinces.values.map((province) => _buildProvinceMarker(province)),
        ],
      ),
    );
  }

  /// 隣接関係の線を描画
  Widget _buildAdjacencyLines() {
    final selectedProvince = widget.gameState.selectedProvinceId != null
        ? widget.gameState.provinces[widget.gameState.selectedProvinceId!]
        : null;

    if (selectedProvince == null) return const SizedBox();

    final screenSize = MediaQuery.of(context).size;
    final mapArea = Size(screenSize.width * 0.75, screenSize.height - 56);

    return CustomPaint(
      size: mapArea,
      painter: AdjacencyLinePainter(
        selectedProvince: selectedProvince,
        allProvinces: widget.gameState.provinces,
        mapArea: mapArea,
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

    // 隣接関係の表示判定
    final selectedProvince = widget.gameState.selectedProvinceId != null
        ? widget.gameState.provinces[widget.gameState.selectedProvinceId!]
        : null;
    final isAdjacent = selectedProvince != null && selectedProvince.adjacentProvinceIds.contains(province.id);
    final isAttackable =
        isAdjacent && selectedProvince.controller == Faction.liangshan && province.controller != Faction.liangshan;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => widget.onProvinceSelected(province.id),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _getProvinceColor(province, isSelected, isAdjacent, isAttackable),
            border: Border.all(
              color: _getBorderColor(province, isSelected, isAdjacent, isAttackable),
              width: _getBorderWidth(province, isSelected, isAdjacent, isAttackable),
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
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
              // 攻撃可能マーカー
              if (isAttackable)
                const Icon(
                  Icons.gps_fixed,
                  color: Colors.red,
                  size: 16,
                ),

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

  /// 州の色を取得
  Color _getProvinceColor(Province province, bool isSelected, bool isAdjacent, bool isAttackable) {
    if (isSelected) {
      return Colors.yellow.withValues(alpha: 0.9);
    } else if (isAttackable) {
      return Colors.red.withValues(alpha: 0.7);
    } else if (isAdjacent) {
      return Colors.blue.withValues(alpha: 0.6);
    } else {
      return province.controller.factionColor.withValues(alpha: 0.8);
    }
  }

  /// 境界線の色を取得
  Color _getBorderColor(Province province, bool isSelected, bool isAdjacent, bool isAttackable) {
    if (isSelected) {
      return Colors.orange;
    } else if (isAttackable) {
      return Colors.red.shade700;
    } else if (isAdjacent) {
      return Colors.blue.shade700;
    } else {
      return Colors.black;
    }
  }

  /// 境界線の幅を取得
  double _getBorderWidth(Province province, bool isSelected, bool isAdjacent, bool isAttackable) {
    if (isSelected) {
      return 3;
    } else if (isAttackable || isAdjacent) {
      return 2;
    } else {
      return 1;
    }
  }
}

/// 隣接関係の線を描画するPainter
class AdjacencyLinePainter extends CustomPainter {
  const AdjacencyLinePainter({
    required this.selectedProvince,
    required this.allProvinces,
    required this.mapArea,
  });

  final Province selectedProvince;
  final Map<String, Province> allProvinces;
  final Size mapArea;

  @override
  void paint(Canvas canvas, Size size) {
    final selectedCenter = Offset(
      mapArea.width * selectedProvince.position.dx,
      mapArea.height * selectedProvince.position.dy,
    );

    for (final adjacentId in selectedProvince.adjacentProvinceIds) {
      final adjacentProvince = allProvinces[adjacentId];
      if (adjacentProvince == null) continue;

      final adjacentCenter = Offset(
        mapArea.width * adjacentProvince.position.dx,
        mapArea.height * adjacentProvince.position.dy,
      );

      final isAttackable =
          selectedProvince.controller == Faction.liangshan && adjacentProvince.controller != Faction.liangshan;

      final paint = Paint()
        ..color = isAttackable ? Colors.red.withValues(alpha: 0.6) : Colors.blue.withValues(alpha: 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(selectedCenter, adjacentCenter, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AdjacencyLinePainter oldDelegate) {
    return selectedProvince != oldDelegate.selectedProvince || allProvinces != oldDelegate.allProvinces;
  }
}
