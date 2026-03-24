import 'package:isar/isar.dart';
import '../models/budget_snapshot.dart';
import '../services/sales_service.dart';

class BudgetService {
  final Isar isar;
  final SalesService salesService;

  BudgetService(this.isar, this.salesService);

  // Dinamik periyoda (Örn: haftalık/aylık) göre bütçe önerisi hesapla
  Future<BudgetSnapshot> calculateProposedBudget({
    double ratio = 0.40, 
    String periodType = 'monthly', 
    int startDayOfWeek = 1
  }) async {
    final now = DateTime.now();
    final allSales = await salesService.getAllSales();
    
    DateTime start, end;
    if (periodType == 'weekly') {
      int currentDay = now.weekday;
      int diff = currentDay - startDayOfWeek;
      if (diff < 0) diff += 7;
      start = now.subtract(Duration(days: diff));
      start = DateTime(start.year, start.month, start.day);
      end = DateTime(start.year, start.month, start.day, 23, 59, 59).add(const Duration(days: 6));
    } else {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }
    
    final periodSales = allSales.where((s) => !s.date.isBefore(start) && !s.date.isAfter(end)).toList();

    final totalRevenue = periodSales.fold(0.0, (sum, s) => sum + s.totalSalePrice);
    final totalCost = periodSales.fold(0.0, (sum, s) => sum + s.totalCost);

    final suggestedBudget = totalRevenue * ratio;

    return BudgetSnapshot()
      ..date = now
      ..totalRevenue = totalRevenue
      ..totalCost = totalCost
      ..budgetRatio = ratio
      ..suggestedBudget = suggestedBudget;
  }

  // Geçmiş kararları/hesapları sakla (İleride geri dönüp "Şubat'ta ne ayırmıştım?" demek için)
  // Aynı yıla ve aya ait bütçe varsa üzerine yazar (tekilleştirir)
  Future<void> saveBudgetSnapshot(BudgetSnapshot snapshot) async {
    await isar.writeTxn(() async {
      final startOfMonth = DateTime(snapshot.date.year, snapshot.date.month, 1);
      final endOfMonth = DateTime(snapshot.date.year, snapshot.date.month + 1, 0, 23, 59, 59);

      final existing = await isar.budgetSnapshots
          .filter()
          .dateBetween(startOfMonth, endOfMonth)
          .findFirst();

      if (existing != null) {
        snapshot.id = existing.id; // Mevcut kaydın ID'sini vererek güncelleme yapıyoruz.
      }

      await isar.budgetSnapshots.put(snapshot);
    });
  }

  // Tüm kayıtlı bütçeleri getir
  Future<List<BudgetSnapshot>> getSavedSnapshots() async {
    return await isar.budgetSnapshots.where().sortByDateDesc().findAll();
  }

  // Kayıtlı bütçeyi sil
  Future<void> deleteSnapshot(int id) async {
    await isar.writeTxn(() async {
      await isar.budgetSnapshots.delete(id);
    });
  }
}
