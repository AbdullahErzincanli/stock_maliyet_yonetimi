import 'package:isar/isar.dart';

part 'purchase_item.g.dart';

@collection
class PurchaseItem {
  Id id = Isar.autoIncrement;
  late int purchaseId;
  late int ingredientId;
  late double amount;
  late double unitPrice;
  late double totalPrice;
  bool isOcrMatched = false;
}
