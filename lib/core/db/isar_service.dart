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
import '../../models/report_settings.dart'; // Added
import 'seed_data.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final existingInstance = Isar.getInstance();
    if (existingInstance != null) {
      return existingInstance;
    }

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
        ReportSettingsSchema, // Added
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

    // Seed default settings
    final settingsCount = await isar.reportSettings.count();
    if (settingsCount == 0) {
      await isar.writeTxn(() async {
        await isar.reportSettings.put(ReportSettings()); // id is 1 by default
      });
    }

    return isar;
  }
}
