import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';

class SalesFilterScreen extends ConsumerStatefulWidget {
  const SalesFilterScreen({super.key});

  @override
  ConsumerState<SalesFilterScreen> createState() => _SalesFilterScreenState();
}

class _SalesFilterScreenState extends ConsumerState<SalesFilterScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormatter = DateFormat('dd.MM.yyyy');

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          // Günün sonuna al (23:59:59)
          _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Satış Filtrele')),
      body: Column(
        children: [
          // Filtre Bölümü
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Tarih Aralığı',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isStart: true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_startDate != null
                              ? _dateFormatter.format(_startDate!)
                              : 'Başlangıç'),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isStart: false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_endDate != null
                              ? _dateFormatter.format(_endDate!)
                              : 'Bitiş'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_startDate != null || _endDate != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      child: const Text('Filtreleri Temizle'),
                    ),
                ],
              ),
            ),
          ),

          // Sonuçlar
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final productMap = {for (var p in products) p.id: p};

                return salesAsync.when(
                  data: (allSales) {
                    // Filtre uygula
                    final filtered = allSales.where((s) {
                      if (_startDate != null && s.date.isBefore(_startDate!)) return false;
                      if (_endDate != null && s.date.isAfter(_endDate!)) return false;
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                          child: Text('Bu tarih aralığında satış bulunamadı.',
                              style: TextStyle(fontSize: 16)));
                    }

                    double totalRevenue = filtered.fold(0, (sum, s) => sum + s.totalSalePrice);
                    double totalCost = filtered.fold(0, (sum, s) => sum + s.totalCost);
                    double totalProfit = filtered.fold(0, (sum, s) => sum + s.profit);

                    return Column(
                      children: [
                        // Özet banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Theme.of(context).primaryColor.withAlpha(25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _summaryColumn('Ciro', totalRevenue, Colors.blue),
                              _summaryColumn('Maliyet', totalCost, Colors.orange),
                              _summaryColumn('Kar', totalProfit,
                                  totalProfit >= 0 ? Colors.green : Colors.red),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${filtered.length} satış gösteriliyor',
                              style: const TextStyle(color: Colors.grey)),
                        ),
                        // Liste
                        Expanded(
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final sale = filtered[index];
                              final prod = productMap[sale.productId];
                              final isProfit = sale.profit >= 0;

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    '${prod?.name ?? "?"} (${sale.amount.toStringAsFixed(0)} adet)',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${_dateFormatter.format(sale.date)} • '
                                    'Satış: ${sale.totalSalePrice.toStringAsFixed(2)} ₺ • '
                                    'Maliyet: ${sale.totalCost.toStringAsFixed(2)} ₺',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Text(
                                    '${isProfit ? "+" : ""}${sale.profit.toStringAsFixed(2)} ₺',
                                    style: TextStyle(
                                      color: isProfit ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
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
                  error: (e, _) => Center(child: Text('Hata: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryColumn(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          '${value.toStringAsFixed(2)} ₺',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
