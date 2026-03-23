import 'package:isar/isar.dart';

part 'unit_definition.g.dart';

@collection
class UnitDefinition {
  Id id = Isar.autoIncrement;
  late String name;
  late String symbol;
  late String baseUnit;
  late double toBaseRatio;
}
