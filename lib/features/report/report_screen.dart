import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/report_settings_provider.dart';
import '../../models/sale.dart';
import '../../models/report_settings.dart';
import 'report_settings_screen.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {

  Map<String, List<Sale>> _groupSales(List<Sale> sales, ReportSettings settings) {
    if (settings.periodType == 'weekly') {
      final map = <String, List<Sale>>{};
      final formatter = DateFormat('dd.MM.yyyy');
      for (var s in sales) {
        final start = _getStartOfPeriod(s.date, settings.startDayOfWeek);
        final end = start.add(const Duration(days: 6));
        final key = '${formatter.format(start)} - ${formatter.format(end)}';
        if (!map.containsKey(key)) map[key] = [];
        map[key]!.add(s);
      }
      return map;
    } else {
      final map = <String, List<Sale>>{};
      final formatter = DateFormat('MM/yyyy');
      for (var s in sales) {
        final key = formatter.format(s.date);
        if (!map.containsKey(key)) map[key] = [];
        map[key]!.add(s);
      }
      return map;
    }
  }

  DateTime _getStartOfPeriod(DateTime date, int startDayOfWeek) {
    int currentDay = date.weekday;
    int diff = currentDay - startDayOfWeek;
    if (diff < 0) diff += 7;
    final start = date.subtract(Duration(days: diff));
    return DateTime(start.year, start.month, start.day);
  }

  List<Sale> _filterSales(List<Sale> sales, ReportSettings settings) {
    if (settings.filterStartDate == null && settings.filterEndDate == null) return sales;
    return sales.where((s) {
      if (settings.filterStartDate != null && s.date.isBefore(settings.filterStartDate!)) return false;
      if (settings.filterEndDate != null && s.date.isAfter(settings.filterEndDate!.add(const Duration(days: 1)))) return false;
      return true;
    }).toList();
  }

  Future<void> _generateAndSharePDF(BuildContext context, List<Sale> sales, String monthKey, Map<int, String> prodNames, bool showProfitAndCost, bool showTime) async {
    final pdf = pw.Document();
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    // Load fonts for Turkish character and currency support
    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    
    final totalRevenue = sales.fold(0.0, (sum, s) => sum + s.totalSalePrice);
    final totalCost = sales.fold(0.0, (sum, s) => sum + s.totalCost);
    final totalProfit = totalRevenue - totalCost;

    final headers = showProfitAndCost 
        ? ['Tarih', 'Ürün', 'Miktar', 'G.Maliyet', 'Sale', 'Kar']
        : ['Tarih', 'Ürün', 'Miktar', 'Satış'];

    final data = sales.map((s) {
      final pName = prodNames[s.productId] ?? 'Bilinmeyen';
      final amountStr = s.quantity > 1 ? '${s.quantity} x ${s.amount.toStringAsFixed(1)}' : s.amount.toStringAsFixed(1);
      if (showProfitAndCost) {
        return [
          DateFormat(showTime ? 'dd.MM.yyyy HH:mm' : 'dd.MM.yyyy').format(s.date),
          pName,
          amountStr,
          '${s.totalCost.toStringAsFixed(2)} ₺',
          '${s.totalSalePrice.toStringAsFixed(2)} ₺',
          '${s.profit.toStringAsFixed(2)} ₺'
        ];
      } else {
        return [
          DateFormat(showTime ? 'dd.MM.yyyy HH:mm' : 'dd.MM.yyyy').format(s.date),
          pName,
          amountStr,
          '${s.totalSalePrice.toStringAsFixed(2)} ₺',
        ];
      }
    }).toList();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Stok ve Maliyet Yönetimi - $monthKey Satış Raporu', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Toplam Gelir: ${totalRevenue.toStringAsFixed(2)} TL'),
              if (showProfitAndCost) ...[
                pw.Text('Toplam Uretim Maliyeti: ${totalCost.toStringAsFixed(2)} TL'),
                pw.Text('Net Kar/Zarar: ${totalProfit.toStringAsFixed(2)} TL'),
              ],
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: headers,
                data: data,
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName = 'Rapor_${monthKey.replaceAll('/', '_')}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '$monthKey Dönemi Satış Raporu',
        sharePositionOrigin: shareOrigin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesProvider);
    final productsAsync = ref.watch(productsProvider);
    final settingsAsync = ref.watch(reportSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelir ve Maliyet Raporları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ReportSettingsScreen()),
            ),
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) => productsAsync.when(
          data: (products) {
            final productMap = {for (var p in products) p.id: p};
            final prodNames = {for (var p in products) p.id: p.name};

            return salesAsync.when(
              data: (sales) {
                final filtered = _filterSales(sales, settings);
                if (filtered.isEmpty) {
                  return const Center(child: Text('Filtrelere uygun satış bulunamadı.', style: TextStyle(fontSize: 18)));
                }

                final grouped = _groupSales(filtered, settings);
                final sortedKeys = grouped.keys.toList()..sort((a, b) {
                  if (settings.periodType == 'weekly') {
                    final pA = a.split(' - ')[0].split('.');
                    final pB = b.split(' - ')[0].split('.');
                    return DateTime(int.parse(pA[2]), int.parse(pA[1]), int.parse(pA[0])).compareTo(
                           DateTime(int.parse(pB[2]), int.parse(pB[1]), int.parse(pB[0]))) * -1;
                  } else {
                    final pA = a.split('/');
                    final pB = b.split('/');
                    return DateTime(int.parse(pA[1]), int.parse(pA[0])).compareTo(DateTime(int.parse(pB[1]), int.parse(pB[0]))) * -1;
                  }
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final key = sortedKeys[index];
                    final mSales = grouped[key]!;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text('$key Raporu', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text('Toplam ${mSales.length} Satış'),
                        childrenPadding: const EdgeInsets.all(8),
                        trailing: Builder(
                          builder: (btnContext) {
                            return IconButton(
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                              onPressed: () => _generateAndSharePDF(btnContext, mSales, key, prodNames, settings.showProfitAndCost, settings.showTime),
                            );
                          }
                        ),
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(flex: 2, child: const Text('Ürün / Tarih', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(flex: 1, child: const Text('Miktar', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                Expanded(flex: 1, child: const Text('Satış', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                                if (settings.showProfitAndCost) ...[
                                  Expanded(flex: 1, child: const Text('Maliyet', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                                  Expanded(flex: 1, child: const Text('Kar', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                                ],
                              ],
                            ),
                          ),
                          const Divider(),
                          ...mSales.map((s) {
                            final prod = productMap[s.productId];
                            final name = prod?.name ?? 'Bilinmeyen';
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2, 
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat(settings.showTime ? 'dd.MM HH:mm' : 'dd.MM').format(s.date),
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1, 
                                    child: Text(
                                      s.quantity > 1 ? '${s.quantity} x ${s.amount} ${prod?.unit ?? ""}' : '${s.amount} ${prod?.unit ?? ""}', 
                                      textAlign: TextAlign.center, 
                                      style: const TextStyle(fontSize: 14)
                                    ),
                                  ),
                                  Expanded(flex: 1, child: Text('${s.totalSalePrice.toStringAsFixed(2)} ₺', textAlign: TextAlign.right, style: const TextStyle(fontSize: 14))),
                                  if (settings.showProfitAndCost) ...[
                                    Expanded(flex: 1, child: Text('${s.totalCost.toStringAsFixed(2)} ₺', textAlign: TextAlign.right, style: const TextStyle(fontSize: 14))),
                                    Expanded(flex: 1, child: Text('${s.profit.toStringAsFixed(2)} ₺', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, color: s.profit >= 0 ? Colors.green : Colors.red))),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Hata: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Ürünler yüklenemedi: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ayarlar yüklenemedi: $e')),
      ),
    );
  }
}
