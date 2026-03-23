import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../models/recipe_item.dart';
import '../../models/ingredient.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_provider.dart';
import '../../core/db/seed_data.dart';

class RecipeCreateScreen extends ConsumerStatefulWidget {
  final Product? productToEdit;
  final List<RecipeItem>? itemsToEdit;

  const RecipeCreateScreen({super.key, this.productToEdit, this.itemsToEdit});

  @override
  ConsumerState<RecipeCreateScreen> createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends ConsumerState<RecipeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  
  String _selectedUnit = "adet";
  late List<String> _availableUnits;
  bool _isLoading = false;

  final List<RecipeItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _availableUnits = SeedData.defaultUnits.map((u) => u.symbol).toSet().toList();
    if (!_availableUnits.contains(_selectedUnit)) {
      _selectedUnit = _availableUnits.first;
    }

    if (widget.productToEdit != null) {
      _nameCtrl.text = widget.productToEdit!.name;
      _selectedUnit = widget.productToEdit!.unit;
      if (!_availableUnits.contains(_selectedUnit)) {
        _availableUnits.add(_selectedUnit);
      }
      if (widget.productToEdit!.defaultSalePrice != null) {
        _salePriceCtrl.text = widget.productToEdit!.defaultSalePrice!.toString().replaceAll('.0', '');
      }
      _loadEditItems();
    }
  }

  Future<void> _loadEditItems() async {
    if (widget.itemsToEdit == null || widget.itemsToEdit!.isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      final ingredients = await ref.read(ingredientsProvider.future);
      for (var ri in widget.itemsToEdit!) {
        final match = ingredients.firstWhere(
          (ing) => ing.id == ri.ingredientId, 
          orElse: () => Ingredient()..name = 'Bilinmeyen'..unit = ''
        );
        _items.add(RecipeItemModel(
          ingredientId: ri.ingredientId, 
          name: match.name, 
          unit: match.unit, 
          amount: ri.amount,
        ));
      }
    } catch (e) {
      // Ignored for UI
    }
    if (mounted) setState(() { _isLoading = false; });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _salePriceCtrl.dispose();
    super.dispose();
  }

  void _addIngredient(Ingredient ing) {
    setState(() {
      if (_items.any((i) => i.ingredientId == ing.id)) return;
      _items.add(RecipeItemModel(ingredientId: ing.id, name: ing.name, unit: ing.unit, amount: 0));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _openIngredientPicker() async {
    List<Ingredient> ingredients;
    try {
      ingredients = await ref.read(ingredientsProvider.future);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hammaddeler yüklenemedi: $e'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!mounted) return;

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Henüz hammadde eklenmemiş. Önce "Stok" sekmesinden hammadde ekleyin.')),
      );
      return;
    }

    final selectedIngredient = await showModalBottomSheet<Ingredient>(
      context: context,
      builder: (ctx) {
        return ListView.builder(
          itemCount: ingredients.length,
          itemBuilder: (ctx, idx) {
            final ing = ingredients[idx];
            return ListTile(
              title: Text(ing.name),
              subtitle: Text("Temel Birim: ${ing.unit}"),
              onTap: () => Navigator.pop(ctx, ing),
            );
          },
        );
      },
    );

    if (selectedIngredient != null && mounted) {
      _addIngredient(selectedIngredient);
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reçete için en az 1 hammadde seçmelisiniz')));
      return;
    }

    final hasZeroAmount = _items.any((elem) => elem.amount <= 0);
    if (hasZeroAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seçilen hammaddelerin miktarları 0 olamaz')));
      return;
    }

    try {
      final productMap = Product()
        ..name = _nameCtrl.text.trim()
        ..unit = _selectedUnit;
        
      if (_salePriceCtrl.text.trim().isNotEmpty) {
        final spClean = _salePriceCtrl.text.replaceAll(',', '.');
        productMap.defaultSalePrice = double.tryParse(spClean);
      }

      if (widget.productToEdit != null) {
        productMap.id = widget.productToEdit!.id;
      }

      final recipeItemsToSave = _items.map((e) {
        return RecipeItem()
          ..ingredientId = e.ingredientId
          ..amount = e.amount;
      }).toList();

      final service = await ref.read(productServiceProvider.future);
      await service.saveProduct(productMap, recipeItemsToSave);

      if (!mounted) return;
      Navigator.pop(context, true); // true dönerek işlem yapıldığını haber verelim
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reçete başarıyla kaydedildi')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kaydetme hatası: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Ürün/Reçete')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ürün Adı (Örn: 500ml Zeytinyağı Şişesi)'),
                  validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Birim'),
                        initialValue: _selectedUnit,
                        items: _availableUnits
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedUnit = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _salePriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Birim Satış Fiyatı (Opsiyonel)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'İçeriği (Harcamalar)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _openIngredientPicker,
                      icon: const Icon(Icons.add),
                      label: const Text('Hammadde Ekle'),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                if (!_isLoading) ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (ctx, index) {
                    final item = _items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Miktar (${item.unit})'),
                                initialValue: item.amount > 0 ? item.amount.toString() : '',
                                onChanged: (val) {
                                  // Türkçe klavye için virgülü noktaya çevirelim
                                  final cleanVal = val.replaceAll(',', '.');
                                  double parsed = double.tryParse(cleanVal) ?? 0.0;
                                  _items[index].amount = parsed;
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeIngredient(index),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('Ürünü üretmek için hammaddeleri seçip her biri için ne kadar maliyet gideceğini (temel birim cinsinden) giriniz.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveRecipe,
                  child: const Text('REÇETEYİ KAYDET'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Ekstradan lokal UI model sınıfı (Reçete kalemi yaparken listelemek için)
class RecipeItemModel {
  int ingredientId;
  String name;
  String unit;
  double amount;

  RecipeItemModel({required this.ingredientId, required this.name, required this.unit, required this.amount});
}
