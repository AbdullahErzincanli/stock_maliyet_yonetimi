import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../purchases/ocr_scan_screen.dart';
import '../budget/budget_screen.dart';
import '../../providers/sales_provider.dart';
import '../../providers/stock_provider.dart';
import '../../core/utils/unit_conversion.dart';
import '../../models/sale.dart';
import '../../models/ingredient.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);
    final ingredientsAsync = ref.watch(ingredientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Özet ve Hızlı İşlemler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTodaySalesSummary(salesAsync),
            const SizedBox(height: 16),
            _buildStockSummary(ingredientsAsync, context),
            const SizedBox(height: 24),
            const Text('Hızlı İşlemler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrScanScreen()));
              },
              icon: const Icon(Icons.document_scanner),
              label: const Text('Yeni Alış Fişi / Fatura Tara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen()));
              },
              icon: const Icon(Icons.savings),
              label: const Text('Hammadde Bütçesini Planla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySalesSummary(AsyncValue<List<Sale>> salesAsync) {
    return salesAsync.when(
      data: (sales) {
        final now = DateTime.now();
        final todaySales = sales.where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day).toList();
        
        final revenue = todaySales.fold(0.0, (sum, s) => sum + s.totalSalePrice);
        final cost = todaySales.fold(0.0, (sum, s) => sum + s.totalCost);
        final profit = todaySales.fold(0.0, (sum, s) => sum + s.profit);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📅 ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(now)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                const Text('Bugünkü Satışlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildRow('Gelir:', revenue),
                _buildRow('Maliyet:', cost),
                _buildRow('Kar:', profit, isProfit: true),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('Satış verisi alınamadı: $e'),
    );
  }

  Widget _buildStockSummary(AsyncValue<List<Ingredient>> ingredientsAsync, BuildContext context) {
    return ingredientsAsync.when(
      data: (ingredients) {
        final totalValue = ingredients.fold(0.0, (sum, i) => sum + (i.stockAmount * i.avgCost));
        final criticals = ingredients.where((i) => i.stockAmount < i.minStockLevel).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Toplam Stok Değeri: ${totalValue.toStringAsFixed(2)} ₺', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 16),
                Text('⚠️ Kritik Stoklar (${criticals.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                if (criticals.isEmpty) const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Kritik seviyede ürün yok', style: TextStyle(fontStyle: FontStyle.italic))),
                for (var c in criticals)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('🔴 ${c.name} — ${UnitConversionService.formatAmount(c.stockAmount, c.unit)} kaldı', style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('Stok verisi alınamadı: $e'),
    );
  }

  Widget _buildRow(String label, double value, {bool isProfit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            '${value.toStringAsFixed(2)} ₺  ${isProfit && value >= 0 ? "✅" : ""}', 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: isProfit ? FontWeight.bold : FontWeight.normal,
              color: isProfit ? (value >= 0 ? Colors.green : Colors.red) : null,
            )
          ),
        ],
      ),
    );
  }
}
