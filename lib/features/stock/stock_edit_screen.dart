import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ingredient.dart';
import '../../providers/stock_provider.dart';
import '../../core/db/seed_data.dart';

class StockEditScreen extends ConsumerStatefulWidget {
  final Ingredient? ingredient;

  const StockEditScreen({super.key, this.ingredient});

  @override
  ConsumerState<StockEditScreen> createState() => _StockEditScreenState();
}

class _StockEditScreenState extends ConsumerState<StockEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _minStockCtrl;
  String _selectedBaseUnit = 'ml'; // Varsayılan

  final _units = SeedData.defaultUnits.where((u) => u.baseUnit == u.symbol).map((u) => u.symbol).toSet().toList();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.ingredient?.name ?? '');
    _minStockCtrl = TextEditingController(text: widget.ingredient?.minStockLevel.toString() ?? '');
    if (widget.ingredient != null) {
      _selectedBaseUnit = widget.ingredient!.unit;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minStockCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final service = await ref.read(stockServiceProvider.future);

      final item = widget.ingredient ?? Ingredient()
        ..stockAmount = widget.ingredient?.stockAmount ?? 0.0
        ..avgCost = widget.ingredient?.avgCost ?? 0.0
        ..aliases = widget.ingredient?.aliases;

      item.name = _nameCtrl.text.trim();
      item.unit = _selectedBaseUnit;
      item.minStockLevel = double.tryParse(_minStockCtrl.text) ?? 0.0;

      await service.addOrUpdateIngredient(item);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydetme hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDelete() {
    if (widget.ingredient == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silmeyi Onayla'),
        content: Text('${widget.ingredient!.name} silinecek. Emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final navCtx = Navigator.of(ctx);
              final navContext = Navigator.of(context);
              final service = await ref.read(stockServiceProvider.future);
              await service.deleteIngredient(widget.ingredient!.id);
              navCtx.pop();
              navContext.pop();
            },
            child: const Text('SİL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ingredient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Hammadde Düzenle' : 'Yeni Hammadde'),
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmDelete,
                  tooltip: 'Sil',
                )
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Hammadde Adı (örn: Un, Zeytinyağı)'),
                validator: (val) => val == null || val.isEmpty ? 'İsim boş olamaz' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedBaseUnit,
                decoration: const InputDecoration(
                  labelText: 'Temel Birim',
                  helperText: 'Stok takibi her zaman temel birim ile (gr, ml, adet) yapılır.',
                ),
                items: _units.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u.toUpperCase()));
                }).toList(),
                onChanged: isEditing // Düzenlerken birim değiştirilmesi risklidir ama izin verebiliriz veya kapatabiliriz
                    ? null
                    : (val) {
                        setState(() {
                          _selectedBaseUnit = val!;
                        });
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minStockCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kritik Stok Uyarı Seviyesi',
                  suffixText: _selectedBaseUnit,
                ),
                validator: (val) => val == null || val.isEmpty ? 'Kritik seviye boş olamaz' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: const Text('KAYDET'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
