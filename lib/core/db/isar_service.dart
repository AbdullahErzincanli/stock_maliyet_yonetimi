import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/unit_definition.dart';
import '../../models/ingredient.dart';
import '../../models/product.dart';
import '../../models/recipe_item.dart';
import '../../models/sale.dart';
import '../../models/purchase.dart';
import '../../models/purchase_item.dart';
import '../../models/budget_snapshot.dart';
import 'seed_data.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [
          UnitDefinitionSchema,
          IngredientSchema,
          ProductSchema,
          RecipeItemSchema,
          SaleSchema,
          PurchaseSchema,
          PurchaseItemSchema,
          BudgetSnapshotSchema,
        ],
        directory: dir.path,
      );

      // Seed data if empty
      final count = await isar.unitDefinitions.count();
      if (count == 0) {
        await isar.writeTxn(() async {
          await isar.unitDefinitions.putAll(SeedData.defaultUnits);
        });
      }

      return isar;
    }
    return Future.value(Isar.getInstance());
  }
}
