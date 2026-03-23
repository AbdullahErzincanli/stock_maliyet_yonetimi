import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import 'package:intl/intl.dart';
import 'sale_create_screen.dart';

class SalesListScreen extends ConsumerWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);
    final productsAsync = ref.watch(productsProvider);
    final dateFormatter = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satışlar ve Karlılık'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(salesProvider),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          final productMap = {for (var p in products) p.id: p};

          return salesAsync.when(
            data: (sales) {
              if (sales.isEmpty) {
                return const Center(child: Text('Henüz satış kaydı bulunmuyor.', style: TextStyle(fontSize: 18)));
              }

              // Toplam karı hesaplayalım üstte bir özet için
              double totalProfit = sales.fold(0, (sum, s) => sum + s.profit);
              double totalRevenue = sales.fold(0, (sum, s) => sum + s.totalSalePrice);

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).primaryColor.withAlpha(25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Toplam Ciro', style: TextStyle(fontSize: 14)),
                            Text('${totalRevenue.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Toplam Kar', style: TextStyle(fontSize: 14)),
                            Text(
                              '${totalProfit.toStringAsFixed(2)} ₺', 
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: totalProfit >= 0 ? Colors.green : Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sales.length,
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        final prod = productMap[sale.productId];
                        final prodName = prod?.name ?? 'Bilinmeyen Ürün';
                        final isProfit = sale.profit >= 0;

                        return Card(
                          child: ListTile(
                            title: Text('$prodName (${sale.amount} adet)', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${dateFormatter.format(sale.date)} - Satış: ${sale.totalSalePrice.toStringAsFixed(2)} ₺ | Maliyet: ${sale.totalCost.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 12)),
                                if (sale.note != null && sale.note!.isNotEmpty)
                                  Text('Not: ${sale.note}', style: const TextStyle(fontStyle: FontStyle.italic)),
                              ],
                            ),
                            trailing: Text(
                              '${isProfit ? "+" : ""}${sale.profit.toStringAsFixed(2)} ₺',
                              style: TextStyle(color: isProfit ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Hata: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Hata: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleCreateScreen()));
          ref.invalidate(salesProvider);
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Satış Ekle'),
      ),
    );
  }
}
