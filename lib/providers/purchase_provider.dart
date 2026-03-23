import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db_provider.dart';
import 'stock_provider.dart';
import '../models/purchase.dart';
import '../services/purchase_service.dart';

final purchaseServiceProvider = FutureProvider<PurchaseService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final stockService = await ref.watch(stockServiceProvider.future);
  return PurchaseService(isar, stockService);
});

final purchasesProvider = FutureProvider<List<Purchase>>((ref) async {
  final service = await ref.watch(purchaseServiceProvider.future);
  return service.getAllPurchases();
});
