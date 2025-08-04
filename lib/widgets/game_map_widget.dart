import 'package:water_margin_game/models/province.dart';
//
// import文はファイル最上部にまとめる
//
import 'package:flutter/material.dart';
import '../models/water_margin_strategy_game.dart';

/// 全州の接続線を描画するPainter
class AllAdjacencyLinePainter extends CustomPainter {
  /// 州の隣接線を描画するカスタムペインター
  /// [provinces]: 州データのマップ
  /// [mapArea]: マップの描画エリアサイズ
  const AllAdjacencyLinePainter({
    required this.provinces,
    required this.mapArea,
  });

  final Map<String, Province> provinces;
  final Size mapArea;

  @override
  void paint(Canvas canvas, Size size) {
    final drawn = <String>{};
    for (final province in provinces.values) {
      // final center = Offset(
      //   mapArea.width * province.position.dx,
      //   mapArea.height * province.position.dy,
      // );
      for (final adjName in province.neighbors) {
        // 逆方向の重複線を防ぐ
        final key = [province.name, adjName]..sort();
        final keyStr = key.join('-');
        if (drawn.contains(keyStr)) continue;
        final adj = provinces[adjName];
        if (adj == null) continue;
        // final adjCenter = Offset(
        //   mapArea.width * adj.position.dx,
        //   mapArea.height * adj.position.dy,
        // );
        // final paint = Paint()
        //   ..color = Colors.grey.withAlpha(128) // 半透明
        //   ..strokeWidth = 2
        //   ..style = PaintingStyle.stroke;
        // canvas.drawLine(center, adjCenter, paint);
        drawn.add(keyStr);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AllAdjacencyLinePainter oldDelegate) {
    return provinces != oldDelegate.provinces || mapArea != oldDelegate.mapArea;
  }
}

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
    debugPrint('🗺️ GameMapWidget.build開始...');
    debugPrint('🧩 provinces内容: ${widget.gameState.provinces}');
    debugPrint('🧩 provinces.keys: ${widget.gameState.provinces.keys.toList()}');
    debugPrint('🧩 provinces.names: ${widget.gameState.provinces.values.map((p) => p.name).toList()}');

    // ゲーム状態が空の場合はローディング表示
    if (widget.gameState.provinces.isEmpty) {
      debugPrint('🗺️ provinces空のため、ローディング表示');
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              ),
              SizedBox(height: 16),
              Text(
                'ゲーム準備中...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ),
      );
    }

    debugPrint('🗺️ メインマップ構築開始（provinces: ${widget.gameState.provinces.length}）...');

    // 画面サイズに合わせてStackサイズを可変にする
    final size = MediaQuery.of(context).size;
    final double mapWidth = size.width;
    final double mapHeight = size.height;
    debugPrint('🧪 Stackサイズ: width=$mapWidth, height=$mapHeight');

    // メインWidgetツリー

    return SizedBox.expand(
      child: Stack(
        children: [
          // PNG地図画像を最背面に表示
          Positioned.fill(
            child: Image.asset(
              'assets/map/china_outline.png',
              fit: BoxFit.contain,
            ),
          ),

          // 全州の接続線を描画
          Positioned.fill(
            child: CustomPaint(
              painter: AllAdjacencyLinePainter(
                provinces: widget.gameState.provinces,
                mapArea: Size(mapWidth, mapHeight),
              ),
            ),
          ),
          // マップタイトル
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
          if (widget.gameState.selectedProvinceId != null)
            Builder(
              builder: (context) {
                try {
                  debugPrint('🔗 隣接関係線構築中...');
                  return _buildAdjacencyLines(mapWidth, mapHeight);
                } catch (e, stackTrace) {
                  debugPrint('❌ 隣接関係線エラー: $e');
                  debugPrint('スタックトレース: $stackTrace');
                  return Container();
                }
              },
            ),
          // 州マーカーを重ねて描画
          ...widget.gameState.provinces.values.map((province) {
            try {
              debugPrint('🏛️ 州マーカー構築中: ${province.name}');
              return _buildProvinceMarker(province, mapWidth, mapHeight);
            } catch (e, stackTrace) {
              debugPrint('❌ 州マーカーエラー (${province.name}): $e');
              debugPrint('スタックトレース: $stackTrace');
              return const SizedBox();
            }
          }),
        ],
      ),
    );
  }

  /// 隣接関係の線を描画
  Widget _buildAdjacencyLines(double mapWidth, double mapHeight) {
    return CustomPaint(
      painter: AllAdjacencyLinePainter(
        provinces: widget.gameState.provinces,
        mapArea: Size(mapWidth, mapHeight),
      ),
    );
  }

  /// 州マーカーの構築
  Widget _buildProvinceMarker(Province province, double mapWidth, double mapHeight) {
    // 座標情報が Province にないため仮で (0,0) に配置
    final position = Offset(0, 0);

    final isSelected = widget.gameState.selectedProvinceId == province.name;
    final isPlayerProvince = widget.gameState.factions[province.name] == Faction.liangshan;

    // 隣接関係の表示判定
    final selectedProvince = widget.gameState.selectedProvinceId != null
        ? widget.gameState.provinces[widget.gameState.selectedProvinceId!]
        : null;
    final isAdjacent = selectedProvince != null && selectedProvince.neighbors.contains(province.name);
    final isAttackable = isAdjacent &&
        widget.gameState.factions[selectedProvince.name] == Faction.liangshan &&
        widget.gameState.factions[province.name] != Faction.liangshan;

    // 経済値の取得（省略可能な補正値はデフォルト）
    final double tax = province.taxIncome();
    final double agri = province.agricultureYield();
    final double comm = province.commerceIncome();

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => widget.onProvinceSelected(province.name),
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

              // 州のアイコン（未実装）
              // Text(
              //   province.provinceIcon,
              //   style: const TextStyle(fontSize: 20),
              // ),

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
              // if (isPlayerProvince || isSelected)
              //   Text(
              //     '${province.currentTroops}',
              //     style: TextStyle(
              //       fontSize: 8,
              //       color: isSelected ? Colors.black : Colors.white,
              //     ),
              //   ),

              // 経済値表示（プレイヤー州または選択州のみ）
              if (isPlayerProvince || isSelected) ...[
                SizedBox(height: 2),
                Text('税収: ${tax.toStringAsFixed(0)}', style: TextStyle(fontSize: 8, color: Colors.white)),
                Text('農業: ${agri.toStringAsFixed(0)}', style: TextStyle(fontSize: 8, color: Colors.white)),
                Text('商業: ${comm.toStringAsFixed(0)}', style: TextStyle(fontSize: 8, color: Colors.white)),
              ],
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
      return widget.gameState.factions[province.name]?.factionColor.withValues(alpha: 0.8) ?? Colors.grey;
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
    // final selectedCenter = Offset(
    //   mapArea.width * selectedProvince.position.dx,
    //   mapArea.height * selectedProvince.position.dy,
    // );

    for (final adjacentName in selectedProvince.neighbors) {
      final adjacentProvince = allProvinces[adjacentName];
      if (adjacentProvince == null) continue;

      // final adjacentCenter = Offset(
      //   mapArea.width * adjacentProvince.position.dx,
      //   mapArea.height * adjacentProvince.position.dy,
      // );

      // final isAttackable = false;

      // final paint = Paint()
      //   ..color = isAttackable ? Colors.red.withValues(alpha: 0.6) : Colors.blue.withValues(alpha: 0.4)
      //   ..strokeWidth = 2
      //   ..style = PaintingStyle.stroke;

      // canvas.drawLine(selectedCenter, adjacentCenter, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AdjacencyLinePainter oldDelegate) {
    return selectedProvince != oldDelegate.selectedProvince || allProvinces != oldDelegate.allProvinces;
  }
}
