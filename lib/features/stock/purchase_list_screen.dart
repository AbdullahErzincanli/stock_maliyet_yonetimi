import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/stock_provider.dart';
import '../../models/purchase.dart';
import '../../models/purchase_item.dart';
import '../../models/ingredient.dart';
import 'purchase_create_screen.dart';
import '../../core/utils/snackbar_helper.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satın Alım Geçmişi'),
      ),
      body: purchasesAsync.when(
        data: (purchases) {
          if (purchases.isEmpty) {
            return const Center(child: Text('Henüz satın alım geçmişi yok.'));
          }
          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return _PurchaseListItem(purchase: purchase);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class _PurchaseListItem extends ConsumerWidget {
  final Purchase purchase;

  const _PurchaseListItem({required this.purchase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(purchase.date);

    return FutureBuilder<List<PurchaseItem>>(
      future: ref.read(purchaseServiceProvider.future).then((s) => s.getPurchaseItems(purchase.id)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(title: Text('Yükleniyor...'));
        }
        final items = snapshot.data!;
        if (items.isEmpty) return const SizedBox.shrink();

        final item = items.first; // En az 1 tane vardır varsayıyoruz

        return FutureBuilder<List<Ingredient>>(
          future: ref.read(ingredientsProvider.future),
          builder: (context, ingSnapshot) {
            if (!ingSnapshot.hasData) return const ListTile(title: Text('Yükleniyor...'));
            
            final ingredients = ingSnapshot.data!;
            final ingredient = ingredients.firstWhere(
              (i) => i.id == item.ingredientId, 
              orElse: () => Ingredient()..name = 'Bilinmeyen'..unit = 'gr'
            );

            final ingredientName = ingredient.name;
            final formattedAmount = '${item.amount} ${ingredient.unit}';

            return Dismissible(
              key: Key('purchase_${purchase.id}'),
              background: Container(
                color: theme.colorScheme.error,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Silme Onayı'),
                    content: const Text('Bu satın alımı silmek istediğinize emin misiniz? Bu işlem stokları geri güncelleyecektir.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
              onDismissed: (_) async {
                final service = await ref.read(purchaseServiceProvider.future);
                await service.deletePurchaseAndProcessStock(purchase.id);
                ref.invalidate(purchasesProvider);
                ref.invalidate(ingredientsProvider);
                if (!context.mounted) return;
                SnackBarHelper.show(context, 'Satın alım silindi');
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    '$ingredientName - ${purchase.marketName ?? "Satın Alım"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$dateStr\nMiktar: $formattedAmount'),
                  trailing: Text(
                    '${purchase.totalAmount.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PurchaseCreateScreen(purchase: purchase, item: item),
                      ),
                    );
                    if (res == true) {
                      ref.invalidate(purchasesProvider);
                      ref.invalidate(ingredientsProvider);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
