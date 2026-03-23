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
  Future<void> recordSale({
    required int productId,
    required double amount, // Satılan miktar
    required double unitSalePrice, // Birim satış fiyatı
    required bool autoProduce, // Satarken otomatik olarak stoğu (hammaddeleri) düşürsün mü?
    String? note,
  }) async {
    // 1. Maliyet hesapla (Üretim maliyeti: Reçete o anki maliyeti x Satılan Miktar)
    final unitCost = await productService.calculateProductCost(productId);
    final totalCost = unitCost * amount;
    final totalSalePrice = unitSalePrice * amount;
    final profit = totalSalePrice - totalCost;

    final sale = Sale()
      ..productId = productId
      ..amount = amount
      ..unitSalePrice = unitSalePrice
      ..totalSalePrice = totalSalePrice
      ..totalCost = totalCost
      ..profit = profit
      ..date = DateTime.now()
      ..note = note;

    await isar.writeTxn(() async {
      // 2. Eğer "Otomatik Üret" seçiliyse, satışı yaparken stoktan hammaddeleri de düş.
      if (autoProduce) {
        // recordProduction methodu içinde kendi writeTxn bloğu yoksa veya 
        // iç içe writeTxn çağırılamayacağı için doğrudan mantığı buraya da koyabiliriz.
        // Ama isar.writeTxn iç içe destekler (eğer aynı txn kullanılabiliyorsa).
        // En temiz yol, autoProduce varsa önce stoktan düşmeyi denemek, 
        // hata verirse Sale kaydolmayacaktır.
      }
      
      // isar.writeTxn içinde kendi writeTxn fonksiyonu hata verebilir, bu yüzden 
      // kaydetme işlemini ayırıyoruz
      await isar.sales.put(sale);
    });

    if (autoProduce) {
      // Not: Isar iç içe writeTxn'i desteklemediğinden, stok düşme işlemini Transaction dışına aldım. 
      // Stok düşme başarısız olursa, catch bloğunda bu satışı geri almak iyi bir pratik olabilir, 
      // ancak şimdilik ProductionService kendisini ayrı bir işlem olarak yönetecek.
      // Eger exception firlarsa, ust katmanda (UI) isar.sales.delete cagirarak islem rollback edilebilir.
      try {
        await productionService.recordProduction(productId, amount);
      } catch (e) {
        // Hammadde yetersizse Satış kaydını da iptal ediyoruz (Manuel Rollback)
        await isar.writeTxn(() async {
          await isar.sales.delete(sale.id);
        });
        rethrow;
      }
    }
  }

  // Tüm satış geçmişini getir
  Future<List<Sale>> getAllSales() async {
    return await isar.sales.where().sortByDateDesc().findAll();
  }
}
