import 'package:isar/isar.dart';

part 'budget_snapshot.g.dart';

@collection
class BudgetSnapshot {
  Id id = Isar.autoIncrement;
  late DateTime date;
  late double totalRevenue;
  late double totalCost;
  late double suggestedBudget;
  late double budgetRatio;
}
