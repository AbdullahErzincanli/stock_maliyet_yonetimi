import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import 'db_provider.dart';
import 'stock_provider.dart';

final productServiceProvider = FutureProvider<ProductService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ProductService(isar);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = await ref.watch(productServiceProvider.future);
  return await service.getAllProducts();
});

final productCostProvider = FutureProvider.family<double, int>((ref, productId) async {
  final service = await ref.watch(productServiceProvider.future);
  // Stok (ingredient) güncellemelerini izlemek için ingredientsProvider'ı watch ediyoruz
  final ingredients = await ref.watch(ingredientsProvider.future);
  
  final recipeItems = await service.getRecipeItemsForProduct(productId);
  double totalCost = 0.0;
  
  for (var item in recipeItems) {
    try {
      final ingredient = ingredients.firstWhere((i) => i.id == item.ingredientId);
      // item.amount (reçetedeki kullanılan miktar) * ingredient.avgCost (ortalama birim fiyat)
      totalCost += (item.amount * ingredient.avgCost);
    } catch (e) {
      // Hammadde bulunamazsa hata yutulur
    }
  }
  return totalCost;
});
