import 'package:isar/isar.dart';
import '../models/budget_snapshot.dart';
import '../services/sales_service.dart';

class BudgetService {
  final Isar isar;
  final SalesService salesService;

  BudgetService(this.isar, this.salesService);

  // Belirli bir aydaki (varsayılan bu ay) ciroya göre bütçe önerisi hesapla
  Future<BudgetSnapshot> calculateProposedBudget({double ratio = 0.40, DateTime? targetMonth}) async {
    final now = targetMonth ?? DateTime.now();
    final allSales = await salesService.getAllSales();
    
    // Sadece o aya ait olanları filtrele
    final monthSales = allSales.where((s) => s.date.year == now.year && s.date.month == now.month).toList();

    final totalRevenue = monthSales.fold(0.0, (sum, s) => sum + s.totalSalePrice);
    final totalCost = monthSales.fold(0.0, (sum, s) => sum + s.totalCost);

    // Ciro bazlı mı yoksa Kar bazlı mı ayrılacak? Genelde cironun X yüzdesi ayrılır (örn: %40)
    final suggestedBudget = totalRevenue * ratio;

    return BudgetSnapshot()
      ..date = now
      ..totalRevenue = totalRevenue
      ..totalCost = totalCost
      ..budgetRatio = ratio
      ..suggestedBudget = suggestedBudget;
  }

  // Geçmiş kararları/hesapları sakla (İleride geri dönüp "Şubat'ta ne ayırmıştım?" demek için)
  Future<void> saveBudgetSnapshot(BudgetSnapshot snapshot) async {
    await isar.writeTxn(() async {
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
