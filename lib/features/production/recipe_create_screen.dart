import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../models/recipe_item.dart';
import '../../models/ingredient.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_provider.dart';

class RecipeCreateScreen extends ConsumerStatefulWidget {
  const RecipeCreateScreen({super.key});

  @override
  ConsumerState<RecipeCreateScreen> createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends ConsumerState<RecipeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: "adet");

  final List<RecipeItemModel> _items = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tasarım için en az 1 hammadde seçmelisiniz')));
      return;
    }

    final hasZeroAmount = _items.any((elem) => elem.amount <= 0);
    if (hasZeroAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seçilen hammaddelerin miktarları 0 olamaz')));
      return;
    }

    final productMap = Product()
      ..name = _nameCtrl.text.trim()
      ..unit = _unitCtrl.text.trim();

    final recipeItemsToSave = _items.map((e) {
      return RecipeItem()
        ..ingredientId = e.ingredientId
        ..amount = e.amount;
    }).toList();

    final service = await ref.read(productServiceProvider.future);
    await service.saveProduct(productMap, recipeItemsToSave);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reçete kaydedildi')));
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
                TextFormField(
                  controller: _unitCtrl,
                  decoration: const InputDecoration(labelText: 'Birim (Örn: adet, kutu)'),
                  validator: (val) => val == null || val.isEmpty ? 'Gerekli' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('İçeriği (Harcamalar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ElevatedButton.icon(
                      onPressed: _openIngredientPicker,
                      icon: const Icon(Icons.add),
                      label: const Text('Hammadde Ekle'),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
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
                                  double parsed = double.tryParse(val) ?? 0.0;
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
