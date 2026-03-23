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

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(budgetServiceProvider);
    final snapshotsAsync = ref.watch(savedBudgetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bütçe ve Fon Planlama')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bu ayki satışlara (ciro) dayanarak bir sonraki hammadde alımları için ayırmanız gereken bütçeyi planlayın.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            serviceAsync.when(
              data: (service) {
                return FutureBuilder<BudgetSnapshot>(
                  future: service.calculateProposedBudget(ratio: _ratio),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Hata: ${snapshot.error}');
                    }

                    final data = snapshot.data!;
                    return Card(
                      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'Bu Ayki Toplam Ciro:\n${data.totalRevenue.toStringAsFixed(2)} ₺',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            const Text('Ne Kadarını Hammadde İçin Ayırmak İstersiniz?', textAlign: TextAlign.center),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            const Divider(height: 48),
                            const Text(
                              'Önerilen Ayrılacak Bütçe (Kumbara)',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            Text(
                              '${data.suggestedBudget.toStringAsFixed(2)} ₺',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final srv = await ref.read(budgetServiceProvider.future);
                                await srv.saveBudgetSnapshot(data);
                                ref.invalidate(savedBudgetsProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bütçe projeksiyonu kaydedildi.'), backgroundColor: Colors.green));
                                }
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('BU PLANI KAYDET'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                minimumSize: const Size.fromHeight(50),
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
            const Text('Geçmiş Planlamalar (Kumbaralar)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            snapshotsAsync.when(
              data: (snapshots) {
                if (snapshots.isEmpty) return const Text('Hiç kaydedilmiş plan yok.');
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshots.length,
                  itemBuilder: (context, index) {
                    final b = snapshots[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.savings)),
                        title: Text('${DateFormat('dd.MM.yyyy HH:mm').format(b.date)} | %${(b.budgetRatio * 100).toInt()} Pay'),
                        subtitle: Text('Ciro: ${b.totalRevenue.toStringAsFixed(2)} ₺ | Ayrılan: ${b.suggestedBudget.toStringAsFixed(2)} ₺'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final srv = await ref.read(budgetServiceProvider.future);
                            await srv.deleteSnapshot(b.id);
                            ref.invalidate(savedBudgetsProvider);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Kaydedilen planlar yüklenemedi: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
