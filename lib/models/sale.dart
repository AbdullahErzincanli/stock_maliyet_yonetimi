import 'package:isar/isar.dart';

part 'sale.g.dart';

@collection
class Sale {
  Id id = Isar.autoIncrement;
  late int productId;
  late double amount;
  late double unitSalePrice;
  late double totalSalePrice;
  late double totalCost;
  late double profit;
  late DateTime date;
  String? note;
  int quantity = 1; // Satış adedi (Örn: 3 adet 5kg luk peksemet için 3)
}
