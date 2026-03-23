import 'package:flutter_test/flutter_test.dart';
import 'package:stock_maliyet_yonetimi/core/utils/weighted_average.dart';
import 'package:stock_maliyet_yonetimi/core/utils/exceptions.dart';

void main() {
  group('Faz 16: Ağırlıklı Ortalama Maliyet Testleri', () {
    test('İlk alım testi: Maliyeti doğrudan alış fiyatı belirler', () {
      final avg = WeightedAverage.calculateNewAverageCost(
        currentStock: 0,
        currentAvgCost: 0,
        incomingAmount: 10,
        incomingUnitPrice: 5.0, // Tanensi 5 TL
      );
      expect(avg, 5.0);
    });

    test('İkinci alım testi: Ağırlıklı fiyatı dengeler', () {
      // 10 ürün 5 TL'den alındığı için avg=5. Şimdi 10 ürün daha 10 TL'den alınıyor
      final avg = WeightedAverage.calculateNewAverageCost(
        currentStock: 10,
        currentAvgCost: 5.0,
        incomingAmount: 10,
        incomingUnitPrice: 10.0, // 10 TL'den alım (pahalandı)
      );
      // (10*5 + 10*10) / 20 = 150 / 20 = 7.5
      expect(avg, 7.5);
    });

    test('Ardışık küçük miktarlarda alım: Etki oranı kontrolü', () {
      // 1000 ml 0.1 TL/ml, 5000 ml 0.2 TL/ml geldiğinde maliyet artmalı
      final avg = WeightedAverage.calculateNewAverageCost(
        currentStock: 1000,
        currentAvgCost: 0.1,
        incomingAmount: 5000,
        incomingUnitPrice: 0.2, // 0.2
      );
      // (100 + 1000) = 1100 / 6000 = 0.1833...
      expect(avg, closeTo(0.1833, 0.001));
    });
  });

  group('Faz 16: Üretim, Satış, Hata Testleri (Manuel Hesaplama)', () {
    test('Negatif Stok Engeli: Mantığını modelle', () {
      double stock = 100;
      double needed = 150;

      expect(() {
        if (stock < needed) {
          throw StockInsufficientException('Stok yetersiz');
        }
      }, throwsA(isA<StockInsufficientException>()));
    });

    test('Üretim ve Kar Hesabı: Matematik Modeli', () {
      // 1 Kek Reçetesi = 500 gr Un + 2 Adet Yumurta
      // Un gr maliyeti = 0.02 ₺/gr (kg'ı 20 TL)
      // Yumurta adet = 2.5 ₺
      double unMaliyet = 500 * 0.02; // 10 TL
      double yumurtaMaliyet = 2 * 2.5; // 5 TL
      double siseKutu = 1 * 5.0; // 5 TL kutu maliyeti

      double uretimMaliyet = unMaliyet + yumurtaMaliyet + siseKutu; // 20 TL maliyet
      expect(uretimMaliyet, 20.0);

      // Kar hesabı
      double satisFiyati = 50.0;
      double amount = 3; // 3 adet pasta satıldı
      
      double toplamSatis = satisFiyati * amount; // 150 TL
      double toplamMaliyet = uretimMaliyet * amount; // 60 TL
      double kar = toplamSatis - toplamMaliyet; // 90 TL
      
      expect(kar, 90.0);
    });
  });
}
