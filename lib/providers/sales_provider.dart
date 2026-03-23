import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db_provider.dart';
import 'product_provider.dart';
import 'production_provider.dart';
import '../services/sales_service.dart';
import '../models/sale.dart';

final salesServiceProvider = FutureProvider<SalesService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final productService = await ref.watch(productServiceProvider.future);
  final productionService = await ref.watch(productionServiceProvider.future);
  return SalesService(isar, productService, productionService);
});

final salesProvider = FutureProvider<List<Sale>>((ref) async {
  final service = await ref.watch(salesServiceProvider.future);
  return await service.getAllSales();
});
