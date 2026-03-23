import '../../models/unit_definition.dart';
import '../db/seed_data.dart';

class UnitConversionService {
  // Veritabanındaki veya varsayılan birimler bellek üzerinde (cache) tutulur
  static final List<UnitDefinition> _units = SeedData.defaultUnits;

  /// Parametre olarak verilen birim adına/sembolüne karşılık gelen UnitDefinition'ı döner
  static UnitDefinition? getUnit(String unitNameOrSymbol) {
    if (unitNameOrSymbol.isEmpty) return null;
    
    final lowerInput = unitNameOrSymbol.toLowerCase().trim();
    for (var u in _units) {
      if (u.name.toLowerCase() == lowerInput || u.symbol.toLowerCase() == lowerInput) {
        return u;
      }
    }
    return null;
  }

  /// Verilen miktarı her zaman baseUnit (ml, gr, adet vb.) formatına çevirir
  /// Örn: (5, 'litre') -> 5000 (ml)
  static double toBaseAmount(double amount, String unitName) {
    var unit = getUnit(unitName);
    if (unit != null) {
      return amount * unit.toBaseRatio;
    }
    return amount; // Bulunamadıysa miktar aynı kalır
  }

  /// Belirli bir hammaddenin base tabanlı stoğunu kullanıcıya pratik göstermek için
  /// Örn: 1500 ml -> "1.5 lt", 800 gr -> "800 gr"
  static String formatAmount(double baseAmount, String baseUnit) {
    // Aynı katar için en büyük Ratio'ya sahip birimi bul
    // Örneğin baseUnit = 'ml' -> ('litre', 1000) veya ('mililitre', 1)
    
    // Geçerli baseUnit ile çalışan tüm birimleri büyükten küçüğe sırala
    var applicableUnits = _units.where((u) => u.baseUnit == baseUnit).toList()
      ..sort((a, b) => b.toBaseRatio.compareTo(a.toBaseRatio));

    if (applicableUnits.isEmpty) {
      return '${_formatNumber(baseAmount)} $baseUnit';
    }

    // Hangisinde oran >= 1 çıkıyorsa ona bölüp döndür.
    // Örnek: 1500 ml. 1500 / 1000 (lt) = 1.5. 1.5 >= 1 -> Bunu kullan!
    for (var unit in applicableUnits) {
      double converted = baseAmount / unit.toBaseRatio;
      if (converted >= 1.0 || unit.toBaseRatio == 1.0) {
        return '${_formatNumber(converted)} ${unit.symbol}';
      }
    }

    return '${_formatNumber(baseAmount)} $baseUnit';
  }

  /// OCR veya Regex'ten gelen miktarı bulur ve normalize eder.
  /// Örnek: '5 LT' -> {amount: 5000, unit: 'ml'}
  static Map<String, dynamic> parseFromOcr(String rawAmount, String rawUnit) {
    double? rawAmountNum = double.tryParse(rawAmount.replaceAll(',', '.'));
    if (rawAmountNum == null) return {'amount': 0.0, 'baseUnit': rawUnit};

    var unitDef = getUnit(rawUnit);
    if (unitDef != null) {
      return {
        'amount': rawAmountNum * unitDef.toBaseRatio,
        'baseUnit': unitDef.baseUnit,
      };
    }

    // Tanımlı olmayan birimse olduğu gibi döner (OCR için esneklik)
    return {
      'amount': rawAmountNum,
      'baseUnit': rawUnit.toLowerCase(),
    };
  }

  /// Maliyetleri en büyük birime göre formatlar (örn: gram maliyetini kg maliyetine çevirir)
  static String formatCost(double baseCost, String baseUnit) {
    var applicableUnits = _units.where((u) => u.baseUnit == baseUnit).toList()
      ..sort((a, b) => b.toBaseRatio.compareTo(a.toBaseRatio));

    if (applicableUnits.isNotEmpty) {
      final targetUnit = applicableUnits.first; // En büyük birim (örn kg, lt)
      double convertedCost = baseCost * targetUnit.toBaseRatio;
      return '${convertedCost.toStringAsFixed(2)} ₺ / ${targetUnit.symbol}';
    }

    return '${baseCost.toStringAsFixed(2)} ₺ / $baseUnit';
  }

  // Double sayılardaki gereksiz sondaki .0 kısımlarını temizleme
  static String _formatNumber(double n) {
    // n.toStringAsFixed(2); vb kullanılabilir ama .00 yerine düz basmak için regex:
    return n.toString().replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }
}
