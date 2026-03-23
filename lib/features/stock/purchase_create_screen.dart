import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ingredient.dart';
import '../../models/purchase.dart';
import '../../models/purchase_item.dart';
import '../../providers/stock_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/unit_conversion.dart';
import '../../core/db/seed_data.dart';

class PurchaseCreateScreen extends ConsumerStatefulWidget {
  const PurchaseCreateScreen({super.key});

  @override
  ConsumerState<PurchaseCreateScreen> createState() =>
      _PurchaseCreateScreenState();
}

class _PurchaseCreateScreenState extends ConsumerState<PurchaseCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marketNameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _totalPriceCtrl = TextEditingController();

  Ingredient? _selectedIngredient;
  String _selectedUnit = 'gr';
  bool _isSaving = false;

  @override
  void dispose() {
    _marketNameCtrl.dispose();
    _amountCtrl.dispose();
    _totalPriceCtrl.dispose();
    super.dispose();
  }

  /// Seçilen ingredient'ın baz birimine uygun birim listesini döner
  List<String> _getAvailableUnits() {
    if (_selectedIngredient == null) return ['gr', 'ml', 'adet'];
    final baseUnit = _selectedIngredient!.unit;
    return SeedData.defaultUnits
        .where((u) => u.baseUnit == baseUnit)
        .map((u) => u.symbol)
        .toList();
  }

  double? get _computedUnitPrice {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    final totalPrice =
        double.tryParse(_totalPriceCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0 || totalPrice == null || totalPrice <= 0) {
      return null;
    }
    // Birim fiyatı baz birim cinsinden hesapla
    final baseAmount = UnitConversionService.toBaseAmount(amount, _selectedUnit);
    return totalPrice / baseAmount;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIngredient == null) {
      SnackBarHelper.show(context, 'Lütfen bir hammadde seçin', isError: true);
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    final totalPrice =
        double.tryParse(_totalPriceCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      SnackBarHelper.show(context, 'Geçerli bir miktar girin', isError: true);
      return;
    }
    if (totalPrice == null || totalPrice <= 0) {
      SnackBarHelper.show(context, 'Geçerli bir tutar girin', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final purchaseService = await ref.read(purchaseServiceProvider.future);

      final baseAmount =
          UnitConversionService.toBaseAmount(amount, _selectedUnit);
      final unitPrice = totalPrice / baseAmount;

      final purchase = Purchase()
        ..date = DateTime.now()
        ..marketName = _marketNameCtrl.text.trim().isEmpty
            ? null
            : _marketNameCtrl.text.trim()
        ..totalAmount = totalPrice;

      final item = PurchaseItem()
        ..ingredientId = _selectedIngredient!.id
        ..amount = baseAmount
        ..unitPrice = unitPrice
        ..totalPrice = totalPrice;

      await purchaseService.savePurchaseAndProcessStock(purchase, [item]);

      if (!mounted) return;
      SnackBarHelper.show(context, 'Satın alım kaydedildi, stok güncellendi');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.show(context, 'Hata: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final theme = Theme.of(context);
    final availableUnits = _getAvailableUnits();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Satın Alım'),
      ),
      body: ingredientsAsync.when(
        data: (ingredients) {
          if (ingredients.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    const Text(
                      'Henüz hammadde eklenmemiş.\nÖnce Stok sayfasından hammadde ekleyin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          // Güncel listedeki eşleşen ingredient'ı bul (ID bazlı)
          if (_selectedIngredient != null) {
            final match = ingredients.where((i) => i.id == _selectedIngredient!.id);
            _selectedIngredient = match.isNotEmpty ? match.first : null;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Market / Tedarikçi ---
                  TextFormField(
                    controller: _marketNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Market / Tedarikçi (opsiyonel)',
                      prefixIcon: Icon(Icons.store),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Hammadde seçimi ---
                  DropdownButtonFormField<Ingredient>(
                    decoration: const InputDecoration(
                      labelText: 'Hammadde *',
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    initialValue: _selectedIngredient,
                    items: ingredients.map((ing) {
                      final stock = UnitConversionService.formatAmount(
                          ing.stockAmount, ing.unit);
                      return DropdownMenuItem(
                        value: ing,
                        child: Text('${ing.name}  ($stock)'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedIngredient = val;
                        // Seçilen hammaddenin baz birimine göre birim güncelle
                        if (val != null) {
                          final units = SeedData.defaultUnits
                              .where((u) => u.baseUnit == val.unit)
                              .map((u) => u.symbol)
                              .toList();
                          if (!units.contains(_selectedUnit)) {
                            _selectedUnit = val.unit;
                          }
                        }
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Hammadde seçimi zorunlu' : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Miktar & Birim ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Miktar *',
                            prefixIcon: Icon(Icons.scale),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Miktar girin';
                            }
                            final n =
                                double.tryParse(val.replaceAll(',', '.'));
                            if (n == null || n <= 0) {
                              return 'Geçerli bir sayı girin';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Birim',
                          ),
                          initialValue: availableUnits.contains(_selectedUnit)
                              ? _selectedUnit
                              : availableUnits.first,
                          items: availableUnits
                              .map((u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedUnit = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Toplam Tutar ---
                  TextFormField(
                    controller: _totalPriceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Toplam Tutar (₺) *',
                      prefixIcon: Icon(Icons.payments),
                      suffixText: '₺',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Tutar girin';
                      final n = double.tryParse(val.replaceAll(',', '.'));
                      if (n == null || n <= 0) return 'Geçerli tutar girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Birim Fiyat Hesabı ---
                  if (_computedUnitPrice != null)
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: theme.colorScheme.onPrimaryContainer),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Birim Fiyat: ${_computedUnitPrice!.toStringAsFixed(4)} ₺ / ${_selectedIngredient?.unit ?? _selectedUnit}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // --- Kaydet butonu ---
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Kaydediliyor...' : 'KAYDET'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
