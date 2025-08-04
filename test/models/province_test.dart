import 'package:flutter_test/flutter_test.dart';
import 'package:water_margin_game/models/province.dart';

void main() {
  group('Provinceモデルのテスト', () {
    test('税収計算が仕様通り', () {
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
      final tax = province.taxIncome(taxRate: 0.05, factionBonus: 1.1);
      expect(tax, closeTo(10000 * 0.05 * 0.8 * 0.9 * 1.1, 0.01));
    });
  });
}
