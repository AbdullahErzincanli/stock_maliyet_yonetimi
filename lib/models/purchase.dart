import 'package:isar/isar.dart';

part 'purchase.g.dart';

@collection
class Purchase {
  Id id = Isar.autoIncrement;
  late DateTime date;
  String? marketName;
  String? receiptImagePath;
  late double totalAmount;
}
