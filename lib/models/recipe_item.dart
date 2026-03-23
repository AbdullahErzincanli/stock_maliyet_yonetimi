import 'package:isar/isar.dart';

part 'recipe_item.g.dart';

@collection
class RecipeItem {
  Id id = Isar.autoIncrement;
  late int productId;
  late int ingredientId;
  late double amount;
}
