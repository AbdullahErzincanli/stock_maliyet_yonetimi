import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_provider.dart';
import '../../core/utils/unit_conversion.dart';
import 'stock_edit_screen.dart';

class StockListScreen extends ConsumerWidget {
  const StockListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () => ref.invalidate(ingredientsProvider),
          ),
        ],
      ),
      body: ingredientsAsync.when(
        data: (ingredients) {
          if (ingredients.isEmpty) {
            return const Center(child: Text('Henüz hammadde eklenmemiş.', style: TextStyle(fontSize: 18)));
          }
          return ListView.builder(
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final item = ingredients[index];
              final isCritical = item.stockAmount < item.minStockLevel;
              final formattedAmount = UnitConversionService.formatAmount(item.stockAmount, item.unit);

              return Card(
                color: isCritical ? Theme.of(context).colorScheme.errorContainer : null,
                child: ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle: Text(
                    'Ort. Maliyet: ${item.avgCost.toStringAsFixed(2)} ₺ / ${item.unit}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    formattedAmount,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCritical ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StockEditScreen(ingredient: item)),
                    );
                    // Döndüğünde listeyi yenile
                    ref.invalidate(ingredientsProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const StockEditScreen()));
          ref.invalidate(ingredientsProvider);
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hammadde'),
      ),
    );
  }
}
