class WeightedAverage {
  /// Stoklara yeni ürün eklendiğinde ağırlıklı ortalama maliyeti günceller
  /// avgCost = (mevcutMiktar × mevcutOrtalamaFiyat + eklenenMiktar × yeniFiyat) / (mevcutMiktar + eklenenMiktar)
  static double calculateNewAverageCost({
    required double currentStock,
    required double currentAvgCost,
    required double incomingAmount,
    required double incomingUnitPrice,
  }) {
    // Özel durumlar (Boş stok veya sıfır gelen)
    if (incomingAmount <= 0) return currentAvgCost;
    if (currentStock <= 0) return incomingUnitPrice;

    double totalValue = (currentStock * currentAvgCost) + (incomingAmount * incomingUnitPrice);
    double totalAmount = currentStock + incomingAmount;

    return totalValue / totalAmount;
  }
}
