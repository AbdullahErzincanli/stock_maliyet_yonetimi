import '../../models/unit_definition.dart';

class SeedData {
  static List<UnitDefinition> get defaultUnits => [
        UnitDefinition()
          ..name = 'mililitre'
          ..symbol = 'ml'
          ..baseUnit = 'ml'
          ..toBaseRatio = 1.0,
        UnitDefinition()
          ..name = 'litre'
          ..symbol = 'lt'
          ..baseUnit = 'ml'
          ..toBaseRatio = 1000.0,
        UnitDefinition()
          ..name = 'gram'
          ..symbol = 'gr'
          ..baseUnit = 'gr'
          ..toBaseRatio = 1.0,
        UnitDefinition()
          ..name = 'kilogram'
          ..symbol = 'kg'
          ..baseUnit = 'gr'
          ..toBaseRatio = 1000.0,
        UnitDefinition()
          ..name = 'adet'
          ..symbol = 'adet'
          ..baseUnit = 'adet'
          ..toBaseRatio = 1.0,
      ];
}
