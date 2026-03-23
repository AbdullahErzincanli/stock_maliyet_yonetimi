import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db_provider.dart';
import 'product_provider.dart';
import '../services/production_service.dart';

final productionServiceProvider = FutureProvider<ProductionService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final productService = await ref.watch(productServiceProvider.future);
  return ProductionService(isar, productService);
});
