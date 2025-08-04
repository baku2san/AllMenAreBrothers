import 'package:flutter/material.dart';

/// 英雄カード（主要ステータス・名前・アイコン表示）
class HeroCard extends StatelessWidget {
  final String name;
  final String nickname;
  final int force;
  final int intelligence;
  final int charisma;
  final int leadership;
  final int loyalty;

  const HeroCard({
    super.key,
    required this.name,
    required this.nickname,
    required this.force,
    required this.intelligence,
    required this.charisma,
    required this.leadership,
    required this.loyalty,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$name（$nickname）', style: Theme.of(context).textTheme.titleMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat('武力', force),
                _stat('知力', intelligence),
                _stat('魅力', charisma),
                _stat('統率', leadership),
                _stat('義理', loyalty),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        Text('$value', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
