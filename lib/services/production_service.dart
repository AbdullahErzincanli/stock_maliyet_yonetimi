import 'package:isar/isar.dart';
import '../models/ingredient.dart';
import '../services/product_service.dart';
import '../core/utils/exceptions.dart';
import '../core/utils/unit_conversion.dart';

class ProductionService {
  final Isar isar;
  final ProductService productService;

  ProductionService(this.isar, this.productService);

  // Üretim yap: (Atomik olarak reçete x miktar kadar hammaddeden düş)
  Future<void> recordProduction(int productId, double productionAmount) async {
    final recipeItems = await productService.getRecipeItemsForProduct(productId);
    
    if (recipeItems.isEmpty) {
      throw Exception('Bu ürünün reçetesi (içeriği) bulunmamaktadır.');
    }

    await isar.writeTxn(() async {
      // 1. Önce tüm hammaddelerin yeterli olup olmadığını kontrol et (Atomik işlem)
      for (var item in recipeItems) {
        final ingredient = await isar.ingredients.get(item.ingredientId);
        if (ingredient == null) {
          throw Exception('Reçetede bulunan bir hammadde veritabanında yok (ID: ${item.ingredientId})');
        }

        final neededAmount = item.amount * productionAmount;
        if (ingredient.stockAmount < neededAmount) {
          final missing = neededAmount - ingredient.stockAmount;
          final formattedMissing = UnitConversionService.formatAmount(missing, ingredient.unit);
          throw StockInsufficientException('${ingredient.name} stoğu yetersiz: $formattedMissing eksik');
        }
      }

      // 2. Yeterli stok varsa hepsinden düş
      for (var item in recipeItems) {
        final ingredient = (await isar.ingredients.get(item.ingredientId))!;
        final neededAmount = item.amount * productionAmount;
        
        ingredient.stockAmount -= neededAmount;
        await isar.ingredients.put(ingredient);
      }
    });
  }

  // Anlık tam maliyeti al
  Future<double> getUnitProductionCost(int productId) async {
    return await productService.calculateProductCost(productId);
  }
}
