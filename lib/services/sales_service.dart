import 'package:isar/isar.dart';
import '../models/sale.dart';
import '../services/product_service.dart';
import '../services/production_service.dart';

class SalesService {
  final Isar isar;
  final ProductService productService;
  final ProductionService productionService;

  SalesService(this.isar, this.productService, this.productionService);

  // Satış Kaydı Oluşturan Fonksiyon
  Future<String?> recordSale({
    required int productId,
    required double amount, // Satılan miktar (Örn: 5 kg)
    required double unitSalePrice, // Birim satış fiyatı (Örn: 10 TL / kg)
    required bool autoProduce,
    int quantity = 1, // Satış Adedi (Örn: 3 adet 5kg)
    String? note,
  }) async {
    // 1. Maliyet hesapla (Üretim maliyeti: Reçete o anki maliyeti x Satılan Miktar)
    final unitCost = await productService.calculateProductCost(productId);
    final totalCost = unitCost * amount * quantity;
    final totalSalePrice = unitSalePrice * amount * quantity;
    final profit = totalSalePrice - totalCost;

    final sale = Sale()
      ..productId = productId
      ..amount = amount
      ..unitSalePrice = unitSalePrice
      ..totalSalePrice = totalSalePrice
      ..totalCost = totalCost
      ..profit = profit
      ..date = DateTime.now()
      ..note = note
      ..quantity = quantity;

    String? warning;

    await isar.writeTxn(() async {
      await isar.sales.put(sale);
    });

    if (autoProduce) {
      try {
        warning = await productionService.recordProduction(productId, amount * quantity);
      } catch (e) {
        // Genel bir hata (Örn: Reçete bulunamadı) durumunda isterseniz rollback yapabilirsiniz:
        await isar.writeTxn(() async {
          await isar.sales.delete(sale.id);
        });
        rethrow;
      }
    }

    return warning;
  }

  // Tüm satış geçmişini getir
  Future<List<Sale>> getAllSales() async {
    return await isar.sales.where().sortByDateDesc().findAll();
  }
}
