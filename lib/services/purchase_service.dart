import 'package:isar/isar.dart';
import '../models/purchase.dart';
import '../models/purchase_item.dart';
import '../models/ingredient.dart';
import '../core/utils/weighted_average.dart';

class PurchaseService {
  final Isar isar;

  PurchaseService(this.isar);

  Future<void> savePurchaseAndProcessStock(Purchase purchase, List<PurchaseItem> items) async {
    await isar.writeTxn(() async {
      // 1. Satın almayı kaydet
      await isar.purchases.put(purchase);

      // 2. Kalem kalem işle — hepsi TEK transaction içinde
      for (var item in items) {
        item.purchaseId = purchase.id;
        await isar.purchaseItems.put(item);

        // 3. Stok güncelle (ayrı writeTxn açmadan, doğrudan)
        //    Not: item.amount ve item.unitPrice zaten base birim cinsinden
        //    (PurchaseCreateScreen'de dönüştürülüyor)
        final ingredient = await isar.ingredients.get(item.ingredientId);
        if (ingredient != null) {
          ingredient.avgCost = WeightedAverage.calculateNewAverageCost(
            currentStock: ingredient.stockAmount,
            currentAvgCost: ingredient.avgCost,
            incomingAmount: item.amount,
            incomingUnitPrice: item.unitPrice,
          );
          ingredient.stockAmount += item.amount;
          await isar.ingredients.put(ingredient);
        }
      }
    });
  }

  Future<List<Purchase>> getAllPurchases() async {
    return await isar.purchases.where().sortByDateDesc().findAll();
  }
}
