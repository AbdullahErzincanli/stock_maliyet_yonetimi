import 'package:isar/isar.dart';

part 'ingredient.g.dart';

@collection
class Ingredient {
  Id id = Isar.autoIncrement;
  late String name;
  late String unit;
  late double stockAmount;
  late double avgCost;
  late double minStockLevel;
  String? aliases;
}
