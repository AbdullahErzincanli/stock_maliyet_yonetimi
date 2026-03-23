import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import 'db_provider.dart';

final productServiceProvider = FutureProvider<ProductService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ProductService(isar);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = await ref.watch(productServiceProvider.future);
  return await service.getAllProducts();
});
