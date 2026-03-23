import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ingredient.dart';
import '../../models/purchase.dart';
import '../../models/purchase_item.dart';
import '../../services/ocr_service.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/stock_provider.dart';

class OcrReviewScreen extends ConsumerStatefulWidget {
  final List<OcrParsedItem> parsedItems;

  const OcrReviewScreen({super.key, required this.parsedItems});

  @override
  ConsumerState<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends ConsumerState<OcrReviewScreen> {
  late List<OcrParsedItem> _editableItems;
  final TextEditingController _marketNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editableItems = List.from(widget.parsedItems);
  }

  @override
  void dispose() {
    _marketNameCtrl.dispose();
    super.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      _editableItems.removeAt(index);
    });
  }

  Future<void> _savePurchase() async {
    // Sadece DB ile eşleşenleri veya manuel seçilenleri filtreleyelim
    final validItems = _editableItems.where((i) => i.matchedIngredient != null).toList();
    
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eklenecek geçerli ürün bulunamadı.')));
      return;
    }

    final purchaseService = await ref.read(purchaseServiceProvider.future);

    double total = 0;
    final List<PurchaseItem> itemsToSave = [];

    for (var parsed in validItems) {
      final i = PurchaseItem()
        ..ingredientId = parsed.matchedIngredient!.id
        ..amount = parsed.quantity
        ..unitPrice = parsed.price > 0 ? parsed.price : 0.0
        ..totalPrice = parsed.price > 0 ? (parsed.price * parsed.quantity) : 0.0
        ..isOcrMatched = true;

      total += i.totalPrice;
      itemsToSave.add(i);
    }

    final purchase = Purchase()
      ..date = DateTime.now()
      ..marketName = _marketNameCtrl.text.isEmpty ? "Fiş Alışverişi" : _marketNameCtrl.text
      ..totalAmount = total;

    await purchaseService.savePurchaseAndProcessStock(purchase, itemsToSave);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alışveriş kaydedildi ve stoklar güncellendi.')));
    ref.invalidate(ingredientsProvider);
    Navigator.pop(context);
  }

  Future<void> _selectIngredientDialog(int index) async {
    final ingredients = await ref.read(ingredientsProvider.future);
    
    if (!mounted) return;
    final selected = await showDialog<Ingredient>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ürün Eşleştir'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ingredients.length,
            itemBuilder: (ctx, i) {
              final ing = ingredients[i];
              return ListTile(
                title: Text(ing.name),
                onTap: () => Navigator.pop(ctx, ing),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _editableItems[index].matchedIngredient = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiş Onayı')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _marketNameCtrl,
              decoration: const InputDecoration(labelText: 'Market/Fiş Adı (İsteğe Bağlı)'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _editableItems.length,
              itemBuilder: (context, index) {
                final item = _editableItems[index];
                final isMatched = item.matchedIngredient != null;

                return Card(
                  color: isMatched ? Colors.green.shade50 : Colors.red.shade50,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(isMatched ? item.matchedIngredient!.name : item.suggestedName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Okunan: ${item.rawText}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Row(
                          children: [
                            Expanded(child: Text('Miktar: ${item.quantity}')),
                            Expanded(child: Text('Fiyat: ${item.price} ₺')),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMatched)
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.blue),
                            onPressed: () => _selectIngredientDialog(index),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _savePurchase,
              child: const Text('ONAYLA VE STOĞA EKLE'),
            ),
          ),
        ],
      ),
    );
  }
}
