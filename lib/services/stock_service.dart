import 'package:isar/isar.dart';
import '../models/ingredient.dart';
import '../core/utils/unit_conversion.dart';
import '../core/utils/weighted_average.dart';
import '../core/utils/exceptions.dart';

class StockService {
  final Isar isar;

  StockService(this.isar);

  Future<void> addOrUpdateIngredient(Ingredient item) async {
    await isar.writeTxn(() async {
      await isar.ingredients.put(item);
    });
  }

  Future<void> deleteIngredient(int id) async {
    await isar.writeTxn(() async {
      await isar.ingredients.delete(id);
    });
  }

  Future<List<Ingredient>> getAllIngredients() async {
    return await isar.ingredients.where().findAll();
  }

  Future<void> increaseStock(int ingredientId, double incomingAmount, String unit, double unitPrice) async {
    final ingredient = await isar.ingredients.get(ingredientId);
    if (ingredient == null) throw Exception("Hammadde bulunamadı");

    final incomingBaseAmount = UnitConversionService.toBaseAmount(incomingAmount, unit);

    await isar.writeTxn(() async {
      ingredient.avgCost = WeightedAverage.calculateNewAverageCost(
        currentStock: ingredient.stockAmount,
        currentAvgCost: ingredient.avgCost,
        incomingAmount: incomingBaseAmount,
        incomingUnitPrice: unitPrice,
      );
      ingredient.stockAmount += incomingBaseAmount;
      await isar.ingredients.put(ingredient);
    });
  }

  Future<void> decreaseStock(int ingredientId, double amountToDecrease, String unit) async {
    final ingredient = await isar.ingredients.get(ingredientId);
    if (ingredient == null) throw Exception("Hammadde bulunamadı");

    final neededBaseAmount = UnitConversionService.toBaseAmount(amountToDecrease, unit);

    if (ingredient.stockAmount < neededBaseAmount) {
      final formattedNeeded = UnitConversionService.formatAmount(neededBaseAmount - ingredient.stockAmount, ingredient.unit);
      throw StockInsufficientException("${ingredient.name} stoğu yetersiz: $formattedNeeded eksik");
    }

    await isar.writeTxn(() async {
      ingredient.stockAmount -= neededBaseAmount;
      await isar.ingredients.put(ingredient);
    });
  }

  Future<List<Ingredient>> checkCriticalStocks() async {
    final all = await getAllIngredients();
    return all.where((i) => i.stockAmount < i.minStockLevel).toList();
  }

  Future<double> getStockValue() async {
    final all = await getAllIngredients();
    double total = 0.0;
    for (var i in all) {
      total += (i.stockAmount * i.avgCost);
    }
    return total;
  }
}
