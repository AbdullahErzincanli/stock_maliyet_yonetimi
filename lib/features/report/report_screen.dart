import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/sales_provider.dart';
import '../../models/sale.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  // Aylık olarak veriyi gruplamak için
  Map<String, List<Sale>> _groupSalesByMonth(List<Sale> sales) {
    final map = <String, List<Sale>>{};
    final formatter = DateFormat('MM/yyyy');
    for (var s in sales) {
      final key = formatter.format(s.date);
      if (!map.containsKey(key)) map[key] = [];
      map[key]!.add(s);
    }
    return map;
  }

  Future<void> _generateAndSharePDF(List<Sale> sales, String monthKey) async {
    final pdf = pw.Document();
    
    // Basit bir tablo ve toplamı yapalım
    final totalRevenue = sales.fold(0.0, (sum, s) => sum + s.totalSalePrice);
    final totalCost = sales.fold(0.0, (sum, s) => sum + s.totalCost);
    final totalProfit = totalRevenue - totalCost;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Stok ve Maliyet Yonetimi - $monthKey Satis Raporu', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Toplam Gelir: ${totalRevenue.toStringAsFixed(2)} TL', style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Toplam Uretim Maliyeti: ${totalCost.toStringAsFixed(2)} TL', style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Net Kar/Zarar: ${totalProfit.toStringAsFixed(2)} TL', style: pw.TextStyle(fontSize: 18, color: totalProfit >= 0 ? PdfColors.green : PdfColors.red)),
              pw.SizedBox(height: 30),
              // ignore: deprecated_member_use
              pw.TableHelper.fromTextArray(
                headers: ['Tarih', 'Miktar', 'G.Maliyet', 'Satis', 'Kar'],
                data: sales.map((s) => [
                  DateFormat('dd.MM.yyyy HH:mm').format(s.date),
                  s.amount.toStringAsFixed(0),
                  '${s.totalCost.toStringAsFixed(2)} TL',
                  '${s.totalSalePrice.toStringAsFixed(2)} TL',
                  '${s.profit.toStringAsFixed(2)} TL'
                ]).toList(),
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

    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)], text: '$monthKey Ayı Sipariş ve Maliyet Raporu');
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gelir ve Maliyet Raporları')),
      body: salesAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
             return const Center(child: Text('Henüz satış kaydı bulunmuyor.', style: TextStyle(fontSize: 18)));
          }

          final grouped = _groupSalesByMonth(sales);
          final sortedKeys = grouped.keys.toList()..sort((a,b) {
            // Basit string split ile sort
            final pA = a.split('/');
            final pB = b.split('/');
            final dA = DateTime(int.parse(pA[1]), int.parse(pA[0]));
            final dB = DateTime(int.parse(pB[1]), int.parse(pB[0]));
            return dB.compareTo(dA); // Yeni aylar ustte
          });

          // BarChart ayari (En son 6 ay)
          final chartKeys = sortedKeys.take(6).toList().reversed.toList();
          
          List<BarChartGroupData> barGroups = [];
          for (int i=0; i<chartKeys.length; i++) {
            final mSales = grouped[chartKeys[i]]!;
            final rev = mSales.fold(0.0, (sum, s) => sum + s.totalSalePrice);
            final cst = mSales.fold(0.0, (sum, s) => sum + s.totalCost);

            barGroups.add(BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: rev, color: Colors.blue, width: 12, borderRadius: BorderRadius.circular(4)), // Gelir
                BarChartRodData(toY: cst, color: Colors.redAccent, width: 12, borderRadius: BorderRadius.circular(4)), // Maliyet
              ]
            ));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Aylık Gelir ve Maliyet Grafiği (Mavi: Gelir, Kırmızı: Maliyet)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              if (val.toInt() < 0 || val.toInt() >= chartKeys.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(chartKeys[val.toInt()], style: const TextStyle(fontSize: 10)),
                              );
                            }
                          )
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                    )
                  )
                ),
                const SizedBox(height: 32),
                const Text('Aylık Özet ve PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                for (var key in sortedKeys) ...[
                  Card(
                    child: ListTile(
                      title: Text('$key Raporu', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Toplam ${grouped[key]!.length} satış'),
                      trailing: IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        onPressed: () => _generateAndSharePDF(grouped[key]!, key),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
