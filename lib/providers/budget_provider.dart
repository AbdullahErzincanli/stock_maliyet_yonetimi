import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'db_provider.dart';
import 'sales_provider.dart';
import '../services/budget_service.dart';
import '../models/budget_snapshot.dart';

final budgetServiceProvider = FutureProvider<BudgetService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final salesService = await ref.watch(salesServiceProvider.future);
  return BudgetService(isar, salesService);
});

final savedBudgetsProvider = FutureProvider<List<BudgetSnapshot>>((ref) async {
  final service = await ref.watch(budgetServiceProvider.future);
  return await service.getSavedSnapshots();
});
