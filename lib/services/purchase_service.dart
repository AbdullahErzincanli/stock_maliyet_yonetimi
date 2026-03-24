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

  Future<List<PurchaseItem>> getPurchaseItems(int purchaseId) async {
    return await isar.purchaseItems.filter().purchaseIdEqualTo(purchaseId).findAll();
  }

  Future<void> deletePurchaseAndProcessStock(int purchaseId) async {
    await isar.writeTxn(() async {
      final purchase = await isar.purchases.get(purchaseId);
      if (purchase == null) throw Exception('Satın alım bulunamadı');

      final items = await isar.purchaseItems
          .filter()
          .purchaseIdEqualTo(purchaseId)
          .findAll();

      for (var item in items) {
        final ingredient = await isar.ingredients.get(item.ingredientId);
        if (ingredient != null) {
          double totalValue = (ingredient.stockAmount * ingredient.avgCost) -
              (item.amount * item.unitPrice);
          double totalAmount = ingredient.stockAmount - item.amount;

          ingredient.avgCost = (totalAmount <= 0) ? 0.0 : (totalValue / totalAmount);
          if (ingredient.avgCost < 0) ingredient.avgCost = 0;
          ingredient.stockAmount = totalAmount;

          if (ingredient.stockAmount < 0) ingredient.stockAmount = 0;

          await isar.ingredients.put(ingredient);
        }
        await isar.purchaseItems.delete(item.id);
      }
      await isar.purchases.delete(purchaseId);
    });
  }

  Future<void> updatePurchaseAndProcessStock(Purchase updatedPurchase, List<PurchaseItem> newItems) async {
    await isar.writeTxn(() async {
      // 1. Eski kalemlerin stok üzerindeki etkisini geri al
      final oldItems = await isar.purchaseItems
          .filter()
          .purchaseIdEqualTo(updatedPurchase.id)
          .findAll();

      for (var item in oldItems) {
        final ingredient = await isar.ingredients.get(item.ingredientId);
        if (ingredient != null) {
          double totalValue = (ingredient.stockAmount * ingredient.avgCost) -
              (item.amount * item.unitPrice);
          double totalAmount = ingredient.stockAmount - item.amount;

          ingredient.avgCost = (totalAmount <= 0) ? 0.0 : (totalValue / totalAmount);
          if (ingredient.avgCost < 0) ingredient.avgCost = 0;
          ingredient.stockAmount = totalAmount;
          if (ingredient.stockAmount < 0) ingredient.stockAmount = 0;

          await isar.ingredients.put(ingredient);
        }
        await isar.purchaseItems.delete(item.id);
      }

      // 2. Satın almayı güncelle
      await isar.purchases.put(updatedPurchase);

      // 3. Yeni kalemleri işle
      for (var item in newItems) {
        item.purchaseId = updatedPurchase.id;
        await isar.purchaseItems.put(item);

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
}

