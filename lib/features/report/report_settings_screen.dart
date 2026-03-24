import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/report_settings.dart';
import '../../providers/report_settings_provider.dart';

class ReportSettingsScreen extends ConsumerStatefulWidget {
  const ReportSettingsScreen({super.key});

  @override
  ConsumerState<ReportSettingsScreen> createState() => _ReportSettingsScreenState();
}

class _ReportSettingsScreenState extends ConsumerState<ReportSettingsScreen> {
  late ReportSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final settingsVal = await ref.read(reportSettingsProvider.future);
    setState(() {
      _settings = settingsVal;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    await ref.read(reportSettingsProvider.notifier).updateSettings(_settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayarlar kaydedildi.')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Rapor Sıralama ve Filtreleme')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Gruplama Periyodu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _settings.periodType,
            items: const [
              DropdownMenuItem(value: 'monthly', child: Text('Aylık')),
              DropdownMenuItem(value: 'weekly', child: Text('Haftalık')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _settings.periodType = val);
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          if (_settings.periodType == 'weekly') ...[
            const Text('Hafta Başlangıç Günü', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _settings.startDayOfWeek,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Pazartesi')),
                DropdownMenuItem(value: 2, child: Text('Salı')),
                DropdownMenuItem(value: 3, child: Text('Çarşamba')),
                DropdownMenuItem(value: 4, child: Text('Perşembe')),
                DropdownMenuItem(value: 5, child: Text('Cuma')),
                DropdownMenuItem(value: 6, child: Text('Cumartesi')),
                DropdownMenuItem(value: 7, child: Text('Pazar')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _settings.startDayOfWeek = val);
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const Text('Tarih Filtresi (İsteğe Bağlı)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _settings.filterStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _settings.filterStartDate = picked);
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _settings.filterStartDate == null ? 'Başlangıç' : DateFormat('dd.MM.yyyy').format(_settings.filterStartDate!),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('-'),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _settings.filterEndDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _settings.filterEndDate = picked);
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _settings.filterEndDate == null ? 'Bitiş' : DateFormat('dd.MM.yyyy').format(_settings.filterEndDate!),
                  ),
                ),
              ),
            ],
          ),
          if (_settings.filterStartDate != null || _settings.filterEndDate != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _settings.filterStartDate = null;
                  _settings.filterEndDate = null;
                });
              },
              child: const Text('Filtreyi Temizle', style: TextStyle(color: Colors.red)),
            ),
          const Divider(),
          SwitchListTile(
            title: const Text('Gelir-Gider / Kâr Oranlarını Göster'),
            subtitle: const Text('Verilerinizin detaylarını açık veya kapalı yapabilirsiniz.'),
            value: _settings.showProfitAndCost,
            onChanged: (val) {
              setState(() => _settings.showProfitAndCost = val);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Satış Raporlarında Saat Bilgisi Göster'),
            subtitle: const Text('Satış kaydedilen saatleri de listeye ekleyin.'),
            value: _settings.showTime,
            onChanged: (val) {
              setState(() => _settings.showTime = val);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: const Text('AYARLARI KAYDET'),
          ),
        ],
      ),
    );
  }
}
