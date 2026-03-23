import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_service.dart';
import '../models/ingredient.dart';
import 'db_provider.dart';
import 'package:isar/isar.dart';

final stockServiceProvider = FutureProvider<StockService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return StockService(isar);
});

final ingredientsProvider = StreamProvider<List<Ingredient>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  
  // İlk yükleme
  yield await isar.ingredients.where().findAll();

  // Değişimleri canli dinle
  await for (var _ in isar.ingredients.watchLazy()) {
    yield await isar.ingredients.where().findAll();
  }
});
