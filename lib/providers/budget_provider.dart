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

final monthlyBudgetSnapshotProvider = FutureProvider<BudgetSnapshot>((ref) async {
  final service = await ref.watch(budgetServiceProvider.future);
  // En son kaydedilen bütçeleri izle
  final snapshots = await ref.watch(savedBudgetsProvider.future);
  final now = DateTime.now();

  // Eğer bu aya ait kaydedilmiş bir bütçe varsa ve SABİT (manual) ise onu direkt göster
  final currentMonthSnapshot = snapshots.where((s) => s.date.year == now.year && s.date.month == now.month).toList();

  if (currentMonthSnapshot.isNotEmpty && currentMonthSnapshot.first.budgetRatio == -1.0) {
     return currentMonthSnapshot.first;
  }

  // Eğer kaydedilmiş bir bütçe varsa ve oranlıysa onun oranını kullan, yoksa varsayılan %40 (%0.40)
  final double latestRatio = currentMonthSnapshot.isNotEmpty && currentMonthSnapshot.first.budgetRatio != -1.0 
      ? currentMonthSnapshot.first.budgetRatio 
      : (snapshots.isNotEmpty && snapshots.first.budgetRatio != -1.0 ? snapshots.first.budgetRatio : 0.40);

  return await service.calculateProposedBudget(ratio: latestRatio);
});

