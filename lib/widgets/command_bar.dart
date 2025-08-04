import 'package:flutter/material.dart';

/// コマンドバー（画面下部の主要アクションボタン群）
class CommandBar extends StatelessWidget {
  final List<CommandBarItem> items;
  final void Function(String command) onCommandSelected;

  const CommandBar({
    super.key,
    required this.items,
    required this.onCommandSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => IconButton(
                  icon: Icon(item.icon),
                  tooltip: item.label,
                  onPressed: () => onCommandSelected(item.command),
                ))
            .toList(),
      ),
    );
  }
}

class CommandBarItem {
  final String command;
  final String label;
  final IconData icon;

  CommandBarItem({
    required this.command,
    required this.label,
    required this.icon,
  });
}
