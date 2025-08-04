import 'package:flutter/material.dart';
import '../models/province.dart';

/// 州パネル（州の主要パラメータをグラフ・アイコンで表示）
class ProvincePanel extends StatelessWidget {
  final Province province;

  const ProvincePanel({super.key, required this.province});

  @override
  Widget build(BuildContext context) {
    // TODO: グラフ・アイコンでパラメータ表示
    return Card(
      child: Column(
        children: [
          Text(province.name, style: Theme.of(context).textTheme.titleLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _iconWithValue(Icons.people, province.population, '人口'),
              _iconWithValue(Icons.grass, province.agriculture, '農業'),
              _iconWithValue(Icons.store, province.commerce, '商業'),
              _iconWithValue(Icons.security, province.security, '治安'),
              _iconWithValue(Icons.favorite, province.publicSupport, '民心'),
              _iconWithValue(Icons.military_tech, province.military, '軍事'),
              _iconWithValue(Icons.trending_up, province.development, '発展度'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconWithValue(IconData icon, num value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        Text('$label: $value', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
