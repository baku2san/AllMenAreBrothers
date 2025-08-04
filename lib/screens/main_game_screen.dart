import 'package:flutter/material.dart';
import '../models/province.dart';
import '../widgets/province_panel.dart';
import '../widgets/command_bar.dart';

/// 水滸伝戦略ゲームのメイン画面
/// マップ表示と基本的なゲーム操作を提供
class MainGameScreen extends StatelessWidget {
  const MainGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final province = Province(
      name: '梁山泊',
      population: 10000,
      agriculture: 80,
      commerce: 60,
      security: 0.9,
      publicSupport: 0.8,
      military: 100,
      resources: [],
      development: 50,
    );

    final commands = <CommandBarItem>[
      CommandBarItem(command: 'tax', label: '徴税', icon: Icons.attach_money),
      CommandBarItem(command: 'invest', label: '投資', icon: Icons.trending_up),
      CommandBarItem(command: 'trade', label: '交易', icon: Icons.swap_horiz),
      CommandBarItem(command: 'recruit', label: '徴兵', icon: Icons.group_add),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('水滸伝戦略ゲーム')),
      body: Column(
        children: [
          ProvincePanel(province: province),
          const Spacer(),
          CommandBar(
            items: commands,
            onCommandSelected: (cmd) {
              // TODO: コマンド選択時の処理
            },
          ),
        ],
      ),
    );
  }
}
