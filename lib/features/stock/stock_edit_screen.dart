import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ingredient.dart';
import '../../providers/stock_provider.dart';
import '../../core/db/seed_data.dart';
import '../../core/utils/unit_conversion.dart';

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
  String _selectedUnit = 'gr'; // Seçilen görsel birim

  final _units = SeedData.defaultUnits.map((u) => u.symbol).toList();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.ingredient?.name ?? '');
    
    if (widget.ingredient != null) {
      final baseAmount = widget.ingredient!.minStockLevel;
      final baseUnit = widget.ingredient!.unit;
      
      // Kayıtlı olan miktarı kullanıcıya en uygun birimle göstermek için formatla
      final formattedString = UnitConversionService.formatAmount(baseAmount, baseUnit);
      final parts = formattedString.split(' ');
      
      _minStockCtrl = TextEditingController(text: parts[0]);
      _selectedUnit = parts.length > 1 ? parts[1] : baseUnit;
    } else {
      _minStockCtrl = TextEditingController();
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

      final inputAmount = double.tryParse(_minStockCtrl.text.replaceAll(',', '.')) ?? 0.0;
      
      // Kullanıcının girdiği birimi temel birime dönüştür
      final baseAmount = UnitConversionService.toBaseAmount(inputAmount, _selectedUnit);
      final unitDef = UnitConversionService.getUnit(_selectedUnit);

      item.name = _nameCtrl.text.trim();
      // Her zaman arka planda baseUnit (gr, ml, adet) birimini koruyoruz.
      item.unit = unitDef?.baseUnit ?? _selectedUnit; 
      item.minStockLevel = baseAmount;

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
                initialValue: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Birim',
                  helperText: 'KG, LT gibi birimleri seçerseniz miktar çarpılıp gram/ml olarak saklanır.',
                ),
                items: _units.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u.toUpperCase()));
                }).toList(),
                onChanged: isEditing 
                    ? null
                    : (val) {
                        setState(() {
                          _selectedUnit = val!;
                        });
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minStockCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Kritik Stok Uyarı Seviyesi',
                  suffixText: _selectedUnit,
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
