import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../providers/production_provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/product.dart';
import 'recipe_create_screen.dart';

class ProductionEntryScreen extends ConsumerWidget {
  const ProductionEntryScreen({super.key});

  void _showProduceDialog(BuildContext context, WidgetRef ref, Product product) {
    if (!context.mounted) return;
    
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${product.name} Üretimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Üretilecek miktarı giriniz:'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Miktar (${product.unit})'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İPTAL')),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text);
              if (amount == null || amount <= 0) return;

              final navCtx = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              
              try {
                final productionService = await ref.read(productionServiceProvider.future);
                await productionService.recordProduction(product.id, amount);
                
                navCtx.pop();
                messenger.showSnackBar(const SnackBar(content: Text('Üretim kaydedildi ve hammaddelerden düşüldü.'), backgroundColor: Colors.green));
                ref.invalidate(ingredientsProvider);
              } catch (e) {
                navCtx.pop();
                messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            child: const Text('ÜRET/DÜŞ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    ],
                  ),
                  onTap: () => _showProduceDialog(context, ref, prod),
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

class ProductCostWidget extends ConsumerStatefulWidget {
  final int productId;
  const ProductCostWidget({super.key, required this.productId});

  @override
  ConsumerState<ProductCostWidget> createState() => _ProductCostWidgetState();
}

class _ProductCostWidgetState extends ConsumerState<ProductCostWidget> {
  Future<double>? _costFuture;

  @override
  void initState() {
    super.initState();
    _loadCost();
  }

  void _loadCost() {
    _costFuture = ref.read(productServiceProvider.future).then(
      (service) => service.calculateProductCost(widget.productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _costFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) {
          return const Icon(Icons.error, color: Colors.red);
        }
        final cost = snapshot.data ?? 0.0;
        return Text(
          'Maliyet:\n${cost.toStringAsFixed(2)} ₺',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        );
      },
    );
  }
}
