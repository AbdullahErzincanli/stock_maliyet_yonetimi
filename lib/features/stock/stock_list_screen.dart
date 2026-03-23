import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_provider.dart';
import '../../core/utils/unit_conversion.dart';
import 'stock_edit_screen.dart';
import 'purchase_create_screen.dart';

class StockListScreen extends ConsumerWidget {
  const StockListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final theme = Theme.of(context);

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
      body: Column(
        children: [
          // ── Aksiyon butonları ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StockEditScreen()),
                      );
                      ref.invalidate(ingredientsProvider);
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Yeni Hammadde'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      _showPurchaseOptions(context, ref);
                    },
                    icon: const Icon(Icons.shopping_cart, size: 20),
                    label: const Text('Satın Alım'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Hammadde listesi ──
          Expanded(
            child: ingredientsAsync.when(
              data: (ingredients) {
                if (ingredients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text(
                          'Henüz hammadde eklenmemiş.',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Yukarıdaki "Yeni Hammadde" butonuna tıklayarak ekleyin.',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final item = ingredients[index];
                    final isCritical =
                        item.stockAmount < item.minStockLevel;
                    final formattedAmount = UnitConversionService
                        .formatAmount(item.stockAmount, item.unit);

                    return Card(
                      color: isCritical
                          ? theme.colorScheme.errorContainer
                          : null,
                      child: ListTile(
                        title: Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        subtitle: Text(
                          'Ort. Maliyet: ${item.avgCost.toStringAsFixed(2)} ₺ / ${item.unit}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: Text(
                          formattedAmount,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCritical
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    StockEditScreen(ingredient: item)),
                          );
                          ref.invalidate(ingredientsProvider);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Hata: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Satın Alım Yöntemi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.edit_note),
                ),
                title: const Text('El ile Giriş'),
                subtitle:
                    const Text('Hammadde, miktar ve fiyat bilgisini girin'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PurchaseCreateScreen()),
                  );
                  ref.invalidate(ingredientsProvider);
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: const Icon(Icons.document_scanner),
                ),
                title: const Text('Fiş Tarat'),
                subtitle: const Text('Fişi kameradan taratarak otomatik giriş'),
                enabled: true,
                onTap: () {
                  Navigator.pop(ctx);
                  // OCR tarayıcı sayfasına yönlendir
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        // OcrScanScreen zaten var, onu import edip kullanabiliriz
                        // Şimdilik basit bir placeholder
                        return Scaffold(
                          appBar: AppBar(title: const Text('Fiş Tarama')),
                          body: const Center(
                            child: Text(
                              'Fiş tarama özelliği yakında aktif olacak.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
