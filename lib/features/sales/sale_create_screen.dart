import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/sales_provider.dart';

class SaleCreateScreen extends ConsumerStatefulWidget {
  const SaleCreateScreen({super.key});

  @override
  ConsumerState<SaleCreateScreen> createState() => _SaleCreateScreenState();
}

class _SaleCreateScreenState extends ConsumerState<SaleCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  Product? _selectedProduct;
  double _currentEstimatedCost = 0.0;
  bool _autoProduce = true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _onProductChanged(Product? prod) async {
    setState(() => _selectedProduct = prod);
    _priceCtrl.text = prod?.defaultSalePrice?.toString() ?? '';

    if (prod != null) {
      final productService = await ref.read(productServiceProvider.future);
      final cost = await productService.calculateProductCost(prod.id);
      if (mounted) {
        setState(() {
          _currentEstimatedCost = cost;
        });
      }
    } else {
      setState(() => _currentEstimatedCost = 0.0);
    }
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir ürün seçin!')));
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;

    if (amount <= 0 || price < 0) return;

    final salesService = await ref.read(salesServiceProvider.future);

    try {
      await salesService.recordSale(
        productId: _selectedProduct!.id,
        amount: amount,
        unitSalePrice: price,
        autoProduce: _autoProduce,
        note: _noteCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Satış başarıyla kaydedildi.'), backgroundColor: Colors.green));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Satış Kaydı')),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('Öncelikle "Üretim" sekmesinden reçete (ürün) tasarlamalısınız.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Product>(
                    initialValue: _selectedProduct,
                    decoration: const InputDecoration(labelText: 'Satılan Ürün'),
                    items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                    onChanged: _onProductChanged,
                    validator: (val) => val == null ? 'Gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedProduct != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text('🔍 Bu ürünün güncel tahmini BİRİM maliyeti: ${_currentEstimatedCost.toStringAsFixed(2)} ₺', style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                    ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Miktar (Adet/Kutu)'),
                          validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'BİRİM Satış Fiyatı (₺)'),
                          validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(labelText: 'Not (Kime satıldı, açıklama vb.)'),
                  ),
                  const SizedBox(height: 24),
                  CheckboxListTile(
                    title: const Text('Satarken stoklardan (hammaddelerden) malzemeleri de düş. (Otomatik Üret)'),
                    subtitle: const Text('Bunu önceden sadece "Üret" dediyseniz kaldırın. Aksi takdirde malzemeyi iki defa düşer!'),
                    value: _autoProduce,
                    onChanged: (val) => setState(() => _autoProduce = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveSale,
                    child: const Text('SATIŞI KAYDET'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ürünler yüklenemedi: $e')),
      ),
    );
  }
}
