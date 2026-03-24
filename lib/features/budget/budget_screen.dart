import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget_snapshot.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  double _ratio = 0.40; // Default %40
  bool _isManual = false;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(budgetServiceProvider);
    final snapshotsAsync = ref.watch(savedBudgetsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bütçe ve Fon Planlama')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gelecek hammadde alımları için ayırmak istediğiniz bütçeyi planlayın. İster ciroya oranlayarak, ister sabit bir tutar belirleyebilirsiniz.',
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Mode Selection
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false, 
                  label: Text('Ciro Oranı %'), 
                  icon: Icon(Icons.calculate_outlined)
                ),
                ButtonSegment(
                  value: true, 
                  label: Text('Sabit Tutar ₺'), 
                  icon: Icon(Icons.edit_note)
                ),
              ],
              selected: {_isManual},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _isManual = selection.first;
                });
              },
            ),
            const SizedBox(height: 20),

            serviceAsync.when(
              data: (service) {
                return FutureBuilder<BudgetSnapshot>(
                  future: service.calculateProposedBudget(ratio: _ratio),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError) {
                      return Text('Hata: ${snapshot.error}');
                    }

                    final data = snapshot.data!;
                    double finalBudget = _isManual 
                        ? (double.tryParse(_amountController.text) ?? 0.0) 
                        : data.suggestedBudget;

                    return Card(
                      color: colorScheme.primaryContainer.withAlpha(40),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: colorScheme.primary.withOpacity(0.1))),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            if (!_isManual) ...[
                              Text(
                                'Bu Ayki Toplam Ciro',
                                style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                              ),
                              Text(
                                '${data.totalRevenue.toStringAsFixed(2)} ₺',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              const Text('Ne Kadarını Hammadde İçin Ayırmak İstersiniz?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                              Slider(
                                value: _ratio,
                                min: 0.1,
                                max: 0.9,
                                divisions: 16,
                                label: '%${(_ratio * 100).toInt()}',
                                onChanged: (val) {
                                  setState(() {
                                    _ratio = val;
                                  });
                                },
                              ),
                              Text(
                                '%${(_ratio * 100).toInt()} olarak ayarlandı',
                                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                              ),
                            ] else ...[
                              const Text('Ayrılacak Sabit Tutar Belirleyin', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Hedef Bütçe (₺)',
                                  prefixIcon: const Icon(Icons.currency_exchange),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  suffixText: '₺',
                                ),
                                onChanged: (val) {
                                  setState(() {}); // Recalculate display
                                },
                              ),
                            ],

                            const Divider(height: 48),
                            const Text(
                              'Hedeflenen Kumbarası Bütçesi',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${finalBudget.toStringAsFixed(2)} ₺',
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final srv = await ref.read(budgetServiceProvider.future);
                                double budgetToSave = finalBudget;
                                
                                final budgetSnapshotToSave = BudgetSnapshot()
                                  ..date = DateTime.now()
                                  ..totalRevenue = _isManual ? 0 : data.totalRevenue
                                  ..totalCost = _isManual ? 0 : data.totalCost
                                  ..suggestedBudget = budgetToSave
                                  ..budgetRatio = _isManual ? -1.0 : _ratio;

                                await srv.saveBudgetSnapshot(budgetSnapshotToSave);
                                ref.invalidate(savedBudgetsProvider);
                                ref.invalidate(monthlyBudgetSnapshotProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bütçe planınız kaydedildi.'), backgroundColor: Colors.green));
                                }
                              },
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('BU PLANI KAYDET'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Servis Hatası: $e'),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Icon(Icons.history_edu_rounded, color: colorScheme.secondary),
                const SizedBox(width: 8),
                const Text('Planlama Geçmişi (Kumbaralar)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            snapshotsAsync.when(
              data: (snapshots) {
                if (snapshots.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('Henüz kaydedilmiş bir plan yok.', style: TextStyle(color: Colors.grey))));
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshots.length,
                  itemBuilder: (context, index) {
                    final b = snapshots[index];
                    final bool isFixed = b.budgetRatio == -1.0;
                    
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5))),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber.withOpacity(0.15),
                          child: Icon(Icons.savings_rounded, color: Colors.amber[700]),
                        ),
                        title: Text(
                          DateFormat('MMMM yyyy', 'tr_TR').format(b.date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isFixed) ...[
                                Text('Ciro: ${b.totalRevenue.toStringAsFixed(2)} ₺'),
                                Text('Pay: %${(b.budgetRatio * 100).toInt()}'),
                              ] else 
                                const Text('Sabit Belirlenen Bütçe'),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${b.suggestedBudget.toStringAsFixed(2)} ₺',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isFixed ? Colors.blue : Colors.purple).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isFixed ? 'Sabit' : 'Oranlı',
                                    style: TextStyle(fontSize: 10, color: isFixed ? Colors.blue : Colors.purple, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                              onPressed: () async {
                                final srv = await ref.read(budgetServiceProvider.future);
                                await srv.deleteSnapshot(b.id);
                                ref.invalidate(savedBudgetsProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Kaydedilen planlar yüklenemedi: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
