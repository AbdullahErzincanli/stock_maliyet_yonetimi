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
}
