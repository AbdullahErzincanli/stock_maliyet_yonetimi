import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'dart:io';

import 'package:stock_maliyet_yonetimi/models/ingredient.dart';
import 'package:stock_maliyet_yonetimi/models/product.dart';
import 'package:stock_maliyet_yonetimi/models/recipe_item.dart';
import 'package:stock_maliyet_yonetimi/models/sale.dart';
import 'package:stock_maliyet_yonetimi/models/purchase.dart';
import 'package:stock_maliyet_yonetimi/models/purchase_item.dart';
import 'package:stock_maliyet_yonetimi/models/unit_definition.dart';
import 'package:stock_maliyet_yonetimi/models/budget_snapshot.dart';
import 'package:stock_maliyet_yonetimi/services/product_service.dart';
import 'package:stock_maliyet_yonetimi/services/production_service.dart';
import 'package:stock_maliyet_yonetimi/services/sales_service.dart';
import 'package:stock_maliyet_yonetimi/services/ocr_service.dart';
import 'package:stock_maliyet_yonetimi/core/utils/exceptions.dart';

void main() {
  late Isar isar;
  late ProductService productService;
  late ProductionService productionService;
  late SalesService salesService;
  late OcrService ocrService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    // Geçici test klasörü
    final dir = Directory.systemTemp.createTempSync();
    isar = await Isar.open(
      [
        UnitDefinitionSchema,
        IngredientSchema,
        ProductSchema,
        RecipeItemSchema,
        SaleSchema,
        PurchaseSchema,
        PurchaseItemSchema,
        BudgetSnapshotSchema,
      ],
      directory: dir.path,
    );

    productService = ProductService(isar);
    productionService = ProductionService(isar, productService);
    salesService = SalesService(isar, productService, productionService);
    ocrService = OcrService();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('Faz 17: Entegrasyon Testleri', () {
    test('Tam Üretim Akışı: Hammadde ekle -> Ürün ve Reçete Yap -> Üret -> Maliyet ve Stok kontrolü', () async {
      // 1. Hammaddeler oluşturulur
      final un = Ingredient()
        ..name = 'Un'
        ..unit = 'gr'
        ..minStockLevel = 1000
        ..stockAmount = 5000 // 5 KG
        ..avgCost = 0.02; // 1 gr = 0.02 TL (kg'si 20 TL)

      final seker = Ingredient()
        ..name = 'Şeker'
        ..unit = 'gr'
        ..minStockLevel = 500
        ..stockAmount = 2000 // 2 KG
        ..avgCost = 0.03; // 1 gr = 0.03 TL (kg'si 30 TL)

      await isar.writeTxn(() async {
        await isar.ingredients.putAll([un, seker]);
      });

      // 2. Ürün ve Reçete Ekle
      final pasta = Product()
        ..name = 'Ev Pastası'
        ..unit = 'adet'
        ..defaultSalePrice = 150.0;

      final recete = <RecipeItem>[
        RecipeItem()..ingredientId = un.id..amount = 500, // 500 gr un
        RecipeItem()..ingredientId = seker.id..amount = 200, // 200 gr şeker
      ];

      await productService.saveProduct(pasta, recete);

      // 3. Maliyet Hesabı Doğrulama
      // Beklenen maliyet = (500 * 0.02) + (200 * 0.03) = 10 + 6 = 16 TL
      final cost = await productService.calculateProductCost(pasta.id);
      expect(cost, 16.0);

      // 4. Üretim Yap (3 Adet) -> Stok Düşmeli
      await productionService.recordProduction(pasta.id, 3); // 3 * 500 = 1500 un, 3 * 200 = 600 şeker gider.
      
      final guncelUn = await isar.ingredients.get(un.id);
      final guncelSeker = await isar.ingredients.get(seker.id);

      expect(guncelUn!.stockAmount, 5000 - 1500); // 3500 kalmalı
      expect(guncelSeker!.stockAmount, 2000 - 600); // 1400 kalmalı

      // 5. Yetersiz Stok Durumu Testi (Kalan un: 3500, Kalan Şeker: 1400. 10 adet yapmaya kalkarsak un: 5000, şeker: 2000 lazım)
      expect(() async {
        await productionService.recordProduction(pasta.id, 10);
      }, throwsA(isA<StockInsufficientException>()));
    });

    test('Tam Satış Akışı: Ürün sat, karı doğru hesaplasın', () async {
      final peynir = Ingredient()
        ..name = 'Peynir'
        ..unit = 'gr'
        ..minStockLevel = 100
        ..stockAmount = 1000
        ..avgCost = 0.2; // gr 20 krş

      await isar.writeTxn(() async {
        await isar.ingredients.put(peynir);
      });

      final borek = Product()
        ..name = 'Peynirli Börek'
        ..unit = 'tepsi'
        ..defaultSalePrice = 200.0;

      final peynirRecete = RecipeItem()..ingredientId = peynir.id..amount = 500;
      await productService.saveProduct(borek, [peynirRecete]);

      // 1 Adet börek 250 TL'ye satıldı ve 'autoProduce: false' (zaten stoktan düşmemişti gibi farz edelim veya düşüldü hesaba bağlı)
      await salesService.recordSale(
        productId: borek.id,
        amount: 2.0, // 2 Tepsi
        unitSalePrice: 250.0, // Tane 250 (Toplam 500 TL)
        autoProduce: true, // Aynı anda stok da düş
      );

      // Kar hesabı = (2*250) - (2*(500*0.2)) = 500 - 200 = 300 TL net kar.
      final sales = await salesService.getAllSales();
      expect(sales.length, 1);
      
      final dbSale = sales.first;
      expect(dbSale.totalSalePrice, 500.0);
      expect(dbSale.totalCost, 200.0);
      expect(dbSale.profit, 300.0);

      // Stok da autoProduce: true idi. Düşmeli
      final guncelPeynir = await isar.ingredients.get(peynir.id);
      expect(guncelPeynir!.stockAmount, 1000 - (500 * 2)); // 0 kalmalı
      expect(guncelPeynir.stockAmount, 0.0);
    });

    test('OCR Akışı Simülasyonu: string -> fuzzy match', () async {
      // Gerçek Ocr parsing Unit testlerle edildi ama Entegre mantığında:
      final sut = Ingredient()..name = 'Süt'..unit = 'ml'..minStockLevel=100..stockAmount=0..avgCost=0;
      final un = Ingredient()..name = 'Efsane Un'..unit = 'kg'..minStockLevel=100..stockAmount=0..avgCost=0;

      // Fuzzy Match simüle (DB'den gelen isimlere karşı)
      final dummyAvailable = [sut, un];
      
      // OCR'den "EFSAN UN 5KG" okunduğunu düşünelim
      final parsedItems = ocrService.processReceiptText("EFSANE UN 5KG   99,99", dummyAvailable);
      
      // Fuzzy eşleştirmenin 'Efsane Un' ile eşleşmesi beklenir
      expect(parsedItems.length, 1);
      // Fişte top rakam 99.99 çıkarılabilmeli
      expect(parsedItems.first.price, 99.99);
      // DB deki karşılığı
      expect(parsedItems.first.matchedIngredient?.name, 'Efsane Un');
    });
  });
}
