import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_service.dart';
import '../models/ingredient.dart';
import 'db_provider.dart';

final stockServiceProvider = FutureProvider<StockService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return StockService(isar);
});

final ingredientsProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = await ref.watch(stockServiceProvider.future);
  return await service.getAllIngredients();
});
