import 'package:flutter_test/flutter_test.dart';
import 'package:stock_maliyet_yonetimi/core/utils/unit_conversion.dart';

void main() {
  group('Faz 16: UnitConversionService Testleri', () {
    test('5 LT -> 5000 ml dönüşümü (parseFromOcr)', () {
      final res = UnitConversionService.parseFromOcr("5", "lt");
      expect(res['amount'], 5000.0);
      expect(res['baseUnit'], "ml");
    });

    test('2 KG -> 2000 gr dönüşümü', () {
      final res = UnitConversionService.parseFromOcr("2", "kg");
      expect(res['amount'], 2000.0);
      expect(res['baseUnit'], "gr");
    });

    test('500 ML -> 500 ml dönüşümü (değişmez)', () {
      final res = UnitConversionService.parseFromOcr("500", "ml");
      expect(res['amount'], 500.0);
      expect(res['baseUnit'], "ml");
    });

    test('formatAmount: 1500 ml -> 1.5 lt', () {
      final res = UnitConversionService.formatAmount(1500.0, "ml");
      expect(res, "1.5 lt");
    });

    test('formatAmount: 800 gr -> 800 gr', () {
      final res = UnitConversionService.formatAmount(800.0, "gr");
      expect(res, "800 gr");
    });

    test('formatAmount: 2500 gr -> 2.5 kg', () {
      final res = UnitConversionService.formatAmount(2500.0, "gr");
      expect(res, "2.5 kg");
    });
  });
}
