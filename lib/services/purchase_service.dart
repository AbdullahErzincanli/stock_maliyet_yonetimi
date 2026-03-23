import 'package:isar/isar.dart';
import '../models/purchase.dart';
import '../models/purchase_item.dart';
import '../models/ingredient.dart';
import '../services/stock_service.dart';

class PurchaseService {
  final Isar isar;
  final StockService stockService;

  PurchaseService(this.isar, this.stockService);

  Future<void> savePurchaseAndProcessStock(Purchase purchase, List<PurchaseItem> items) async {
    await isar.writeTxn(() async {
      // Satın almayı kaydet (id ataması otomatik olur)
      await isar.purchases.put(purchase);

      // İlgili ürünleri kaydet ve isar linklerini bağla
      for (var item in items) {
        // Satın alma ID'sini vb bağlayabiliriz, fakat modelde Linkler var
        item.purchaseId = purchase.id;
        await isar.purchaseItems.put(item);
        
        // Stock service üzerinden stok artır (Ağırlıklı Ortalama hesaplanır)
        final ingredient = await stockService.isar.ingredients.get(item.ingredientId);
        if (ingredient != null) {
          await stockService.increaseStock(
            item.ingredientId,
            item.amount,
            ingredient.unit, 
            item.unitPrice,
          );
        }
      }
    });
  }

  Future<List<Purchase>> getAllPurchases() async {
    return await isar.purchases.where().sortByDateDesc().findAll();
  }
}
