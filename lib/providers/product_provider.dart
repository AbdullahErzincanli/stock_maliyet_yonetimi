import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../models/recipe_item.dart';
import 'db_provider.dart';
import 'stock_provider.dart';
import 'package:isar/isar.dart';

final productServiceProvider = FutureProvider<ProductService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ProductService(isar);
});

final productsProvider = StreamProvider<List<Product>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  
  yield await isar.products.where().findAll();

  await for (var _ in isar.products.watchLazy()) {
    yield await isar.products.where().findAll();
  }
});

final recipeItemsProvider = StreamProvider.family<List<RecipeItem>, int>((ref, productId) async* {
  final isar = await ref.watch(isarProvider.future);
  
  yield await isar.recipeItems.filter().productIdEqualTo(productId).findAll();

  await for (var _ in isar.recipeItems.filter().productIdEqualTo(productId).watchLazy()) {
    yield await isar.recipeItems.filter().productIdEqualTo(productId).findAll();
  }
});

final productCostProvider = FutureProvider.family<double, int>((ref, productId) async {
  final ingredients = await ref.watch(ingredientsProvider.future);
  final recipeItems = await ref.watch(recipeItemsProvider(productId).future);
  
  double totalCost = 0.0;
  
  for (var item in recipeItems) {
    try {
      final ingredient = ingredients.firstWhere((i) => i.id == item.ingredientId);
      totalCost += (item.amount * ingredient.avgCost);
    } catch (e) {
      // Hammadde bulunamazsa hata yutulur
    }
  }
  return totalCost;
});
