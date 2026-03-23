import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db_provider.dart';
import '../models/purchase.dart';
import '../services/purchase_service.dart';

final purchaseServiceProvider = FutureProvider<PurchaseService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return PurchaseService(isar);
});

final purchasesProvider = FutureProvider<List<Purchase>>((ref) async {
  final service = await ref.watch(purchaseServiceProvider.future);
  return service.getAllPurchases();
});
