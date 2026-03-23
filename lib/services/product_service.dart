import 'package:isar/isar.dart';
import '../models/product.dart';
import '../models/recipe_item.dart';
import '../models/ingredient.dart';

class ProductService {
  final Isar isar;

  ProductService(this.isar);

  // Yeni veya Var Olan Ürün (Reçete) kaydet
  Future<int> saveProduct(Product product, List<RecipeItem> recipeItems) async {
    return await isar.writeTxn(() async {
      int productId = await isar.products.put(product);
      
      // Güncelleme durumu için eski kalemleri sil
      await isar.recipeItems.filter().productIdEqualTo(productId).deleteAll();
      
      for (var item in recipeItems) {
        item.productId = productId;
        await isar.recipeItems.put(item);
      }
      return productId;
    });
  }

  // Tüm ürünleri getir
  Future<List<Product>> getAllProducts() async {
    return await isar.products.where().findAll();
  }

  // Ürüne ait reçete kalemlerini getir
  Future<List<RecipeItem>> getRecipeItemsForProduct(int productId) async {
    return await isar.recipeItems.filter().productIdEqualTo(productId).findAll();
  }

  // Ürün (Reçete) sil
  Future<void> deleteProduct(int productId) async {
    await isar.writeTxn(() async {
      final items = await getRecipeItemsForProduct(productId);
      for (var item in items) {
        await isar.recipeItems.delete(item.id);
      }
      await isar.products.delete(productId);
    });
  }

  // Ürünün anlık maliyetini hesapla (Hammadde'lerin o anki average cost'u üzerinden)
  Future<double> calculateProductCost(int productId) async {
    final recipeItems = await getRecipeItemsForProduct(productId);
    double totalCost = 0.0;
    
    for (var item in recipeItems) {
      final ingredient = await isar.ingredients.get(item.ingredientId);
      if (ingredient != null) {
        // reçetedeki amount * hammaddenin o anki ortalama maliyeti
        // Not: recipe_item.amount, hammaddenin base_unit'i üzerinden kaydedildi varsayımı var
        totalCost += (item.amount * ingredient.avgCost);
      }
    }
    return totalCost;
  }
}
