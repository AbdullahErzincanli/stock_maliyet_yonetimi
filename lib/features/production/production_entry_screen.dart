import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import 'recipe_create_screen.dart';

class ProductionEntryScreen extends ConsumerWidget {
  const ProductionEntryScreen({super.key});

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reçeteyi Sil'),
        content: Text('${product.name} reçetesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İPTAL')),
          TextButton(
            onPressed: () async {
              final navCtx = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final service = await ref.read(productServiceProvider.future);
                await service.deleteProduct(product.id);
                navCtx.pop();
                messenger.showSnackBar(const SnackBar(content: Text('Reçete başarıyla silindi.')));
                ref.invalidate(productsProvider);
              } catch (e) {
                navCtx.pop();
                messenger.showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('SİL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Üretim ve Reçeteler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Yeni Reçete',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeCreateScreen()));
              ref.invalidate(productsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () => ref.invalidate(productsProvider),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('Henüz reçete/ürün oluşturulmamış.', style: TextStyle(fontSize: 18)));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final prod = products[index];
              return Card(
                child: ListTile(
                  title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  subtitle: Text('Birim: ${prod.unit}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProductCostWidget(productId: prod.id),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final service = await ref.read(productServiceProvider.future);
                          final items = await service.getRecipeItemsForProduct(prod.id);
                          if (!context.mounted) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeCreateScreen(
                                productToEdit: prod,
                                itemsToEdit: items,
                              ),
                            ),
                          );
                          ref.invalidate(productsProvider);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmDialog(context, ref, prod),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class ProductCostWidget extends ConsumerWidget {
  final int productId;
  const ProductCostWidget({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costAsync = ref.watch(productCostProvider(productId));

    return costAsync.when(
      data: (cost) {
        return Text(
          'Maliyet:\n${cost.toStringAsFixed(2)} ₺',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (err, stack) => const Icon(Icons.error, color: Colors.red),
    );
  }
}
