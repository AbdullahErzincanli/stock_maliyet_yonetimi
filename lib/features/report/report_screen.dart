import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:gal/gal.dart';

import '../../providers/sales_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/report_settings_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/db_provider.dart';
import '../../models/sale.dart';
import '../../models/purchase.dart';
import '../../models/purchase_item.dart';
import '../../models/report_settings.dart';
import 'report_settings_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:isar/isar.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int? _selectedId;
  String _analysisType = 'product'; // 'product' veya 'ingredient'

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

  Future<pw.Document> _buildPDF(List<Sale> sales, String monthKey, Map<int, String> prodNames, bool showProfitAndCost, bool showTime) async {
    final pdf = pw.Document();
    
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
        margin: pw.EdgeInsets.zero, // Sayfa kenar boşluklarını sıfırla
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.white, // Beyaz arka plan
            padding: const pw.EdgeInsets.all(32), // Kenar boşluklarını buraya ekle
            width: double.infinity,
            height: double.infinity,
            child: pw.Column(
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
            ),
          );
        },
      ),
    );
    return pdf;
  }

  Future<void> _generateAndSharePDF(BuildContext context, List<Sale> sales, String monthKey, Map<int, String> prodNames, bool showProfitAndCost, bool showTime) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    final pdf = await _buildPDF(sales, monthKey, prodNames, showProfitAndCost, showTime);

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

  Future<void> _generateAndShareImage(BuildContext context, List<Sale> sales, String monthKey, Map<int, String> prodNames, bool showProfitAndCost, bool showTime) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    final pdf = await _buildPDF(sales, monthKey, prodNames, showProfitAndCost, showTime);

    final bytes = await pdf.save();
    final List<XFile> files = [];
    final output = await getTemporaryDirectory();
    int pageNum = 1;

    await for (final page in Printing.raster(bytes)) {
      final pngBytes = await page.toPng();
      final fileName = 'Rapor_${monthKey.replaceAll('/', '_')}_sayfa$pageNum.png';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      files.add(XFile(file.path));
      pageNum++;
    }

    if (files.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(
        files: files,
        text: '$monthKey Dönemi Satış Raporu Görseli',
        sharePositionOrigin: shareOrigin,
      ),
    );
  }

  Future<void> _savePDFToDevice(List<Sale> sales, String monthKey, Map<int, String> prodNames, bool showProfitAndCost, bool showTime) async {
    final pdf = await _buildPDF(sales, monthKey, prodNames, showProfitAndCost, showTime);
    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: 'Rapor_${monthKey.replaceAll('/', '_')}',
    );
  }

  Future<void> _saveImageToDevice(BuildContext context, List<Sale> sales, String monthKey, Map<int, String> prodNames, bool showProfitAndCost, bool showTime) async {
    final pdf = await _buildPDF(sales, monthKey, prodNames, showProfitAndCost, showTime);
    final bytes = await pdf.save();
    int count = 0;

    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Galeriye erişim izni verilmedi.')),
        );
        return;
      }
    }

    await for (final page in Printing.raster(bytes)) {
      final pngBytes = await page.toPng();
      await Gal.putImageBytes(pngBytes, name: 'Rapor_${monthKey.replaceAll('/', '_')}_$count');
      count++;
    }

    if (count > 0 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count Görsel Galeriye Kaydedildi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesProvider);
    final productsAsync = ref.watch(productsProvider);
    final settingsAsync = ref.watch(reportSettingsProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gelir ve Maliyet Raporları'),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.analytics_outlined), text: 'Satış Raporları'),
              Tab(icon: Icon(Icons.show_chart), text: 'Maliyet Analizi'),
            ],
          ),
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
        body: TabBarView(
          children: [
            // ── Tab 1: Satış Raporları ──
            settingsAsync.when(
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
                                  return PopupMenuButton<String>(
                                    icon: const Icon(Icons.share, color: Colors.blue),
                                    tooltip: 'Seçenekler',
                                    onSelected: (value) {
                                      if (value == 'pdf') {
                                        _generateAndSharePDF(btnContext, mSales, key, prodNames, settings.showProfitAndCost, settings.showTime);
                                      } else if (value == 'image') {
                                        _generateAndShareImage(btnContext, mSales, key, prodNames, settings.showProfitAndCost, settings.showTime);
                                      } else if (value == 'save_pdf') {
                                        _savePDFToDevice(mSales, key, prodNames, settings.showProfitAndCost, settings.showTime);
                                      } else if (value == 'save_image') {
                                        _saveImageToDevice(btnContext, mSales, key, prodNames, settings.showProfitAndCost, settings.showTime);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'pdf',
                                        child: ListTile(
                                          leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                                          title: Text('PDF Olarak Paylaş'),
                                          dense: true,
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'image',
                                        child: ListTile(
                                          leading: Icon(Icons.image, color: Colors.green),
                                          title: Text('Görsel Olarak Paylaş (PNG)'),
                                          dense: true,
                                        ),
                                      ),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem<String>(
                                        value: 'save_pdf',
                                        child: ListTile(
                                          leading: Icon(Icons.download, color: Colors.blue),
                                          title: Text('Telefona Kaydet (PDF)'),
                                          dense: true,
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'save_image',
                                        child: ListTile(
                                          leading: Icon(Icons.save_alt, color: Colors.blue),
                                          title: Text('Telefona Kaydet (Görsel)'),
                                          dense: true,
                                        ),
                                      ),
                                    ],
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
            
            // ── Tab 2: Maliyet Analizi ──
            _buildAnalysisTab(context, colorScheme),
          ],
        ),
      ),
    );
  }
  Widget _buildAnalysisTab(BuildContext context, ColorScheme colorScheme) {
    final productsAsync = ref.watch(productsProvider);
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final salesAsync = ref.watch(salesProvider);
    final settingsAsync = ref.watch(reportSettingsProvider);

    return settingsAsync.when(
      data: (settings) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ürün veya Hammadde için Maliyet Değişim Analitiği', style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.grey)),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'product', label: Text('Ürün'), icon: Icon(Icons.fastfood_outlined)),
                ButtonSegment(value: 'ingredient', label: Text('Hammadde'), icon: Icon(Icons.egg_outlined)),
              ],
              selected: {_analysisType},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _analysisType = selection.first;
                  _selectedId = null; // Reset selection
                });
              },
            ),
            const SizedBox(height: 20),
            
            if (_analysisType == 'product') ...[
               productsAsync.when(
                 data: (products) {
                    if (products.isEmpty) return const Text('Ürün bulunamadı.');
                    if (_selectedId == null && products.isNotEmpty) {
                      _selectedId = products.first.id;
                    }
                    return DropdownButtonFormField<int>(
                      value: _selectedId,
                      decoration: InputDecoration(labelText: 'Ürün Seçin', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      items: products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                      onChanged: (val) => setState(() => _selectedId = val),
                    );
                 },
                 loading: () => const CircularProgressIndicator(),
                 error: (e, st) => Text('Hata: $e'),
               ),
            ] else ...[
               ingredientsAsync.when(
                 data: (ingredients) {
                    if (ingredients.isEmpty) return const Text('Hammadde bulunamadı.');
                    if (_selectedId == null && ingredients.isNotEmpty) {
                      _selectedId = ingredients.first.id;
                    }
                    return DropdownButtonFormField<int>(
                      value: _selectedId,
                      decoration: InputDecoration(labelText: 'Hammadde Seçin', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      items: ingredients.map((i) => DropdownMenuItem(value: i.id, child: Text(i.name))).toList(),
                      onChanged: (val) => setState(() => _selectedId = val),
                    );
                 },
                 loading: () => const CircularProgressIndicator(),
                 error: (e, st) => Text('Hata: $e'),
               ),
            ],
            
            const SizedBox(height: 24),
            if (_selectedId != null) ...[
               Card(
                 elevation: 0,
                 color: colorScheme.surfaceVariant.withOpacity(0.2),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5))),
                 child: Padding(
                   padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                   child: SizedBox(
                     height: 260,
                     child: _analysisType == 'product'
                       ? salesAsync.when(
                           data: (sales) => _buildProductChart(sales, _selectedId!, settings),
                           loading: () => const Center(child: CircularProgressIndicator()),
                           error: (e, st) => Text('Hata: $e'),
                         )
                       : FutureBuilder<List<_MaliyetNoktasi>>(
                           future: _getIngredientHistory(_selectedId!, settings),
                           builder: (context, snapshot) {
                             if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                             if (snapshot.hasError) return Text('Hata: ${snapshot.error}');
                             return _buildIngredientChart(snapshot.data ?? []);
                           },
                         ),
                   ),
                 ),
               ),
            ],
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Hata: $e')),
    );
  }

  Future<List<_MaliyetNoktasi>> _getIngredientHistory(int ingredientId, ReportSettings settings) async {
    final isar = await ref.read(isarProvider.future);
    final items = await isar.purchaseItems.filter().ingredientIdEqualTo(ingredientId).findAll();
    final points = <_MaliyetNoktasi>[];
    for (var i in items) {
      final p = await isar.purchases.get(i.purchaseId);
      if (p != null) {
        if (settings.filterStartDate != null && p.date.isBefore(settings.filterStartDate!)) continue;
        if (settings.filterEndDate != null && p.date.isAfter(settings.filterEndDate!.add(const Duration(days: 1)))) continue;
        points.add(_MaliyetNoktasi(p.date, i.unitPrice));
      }
    }
    points.sort((a,b) => a.date.compareTo(b.date));
    return points;
  }

  Widget _buildProductChart(List<Sale> sales, int productId, ReportSettings settings) {
    var filteredSales = sales.where((s) => s.productId == productId).toList();
    filteredSales = _filterSales(filteredSales, settings);
    filteredSales.sort((a, b) => a.date.compareTo(b.date));

    if (filteredSales.isEmpty) return const Center(child: Text('Bu ürüne ait satış (maliyet geçmişi) yok.'));

    final spots = <FlSpot>[];
    final map = <int, DateTime>{};
    for (int i = 0; i < filteredSales.length; i++) {
      final s = filteredSales[i];
      final totalSoldAmount = s.amount * s.quantity;
      final costPerUnit = s.totalCost / totalSoldAmount;
      spots.add(FlSpot(i.toDouble(), costPerUnit));
      map[i] = s.date;
    }

    return _renderLineChart(spots, map);
  }

  Widget _buildIngredientChart(List<_MaliyetNoktasi> points) {
    if (points.isEmpty) return const Center(child: Text('Bu hammaddeye ait satın alım geçmişi yok.'));

    final spots = <FlSpot>[];
    final map = <int, DateTime>{};
    for (int i = 0; i < points.length; i++) {
        spots.add(FlSpot(i.toDouble(), points[i].value));
        map[i] = points[i].date;
    }

    return _renderLineChart(spots, map);
  }

  Widget _renderLineChart(List<FlSpot> spots, Map<int, DateTime> xToDate) {
    final colorScheme = Theme.of(context).colorScheme;

    if (spots.isEmpty) return const SizedBox.shrink();

    final firstVal = spots.first.y;
    final lastVal = spots.last.y;
    final double percentChange = firstVal == 0 ? 0 : ((lastVal - firstVal) / firstVal) * 100;
    
    final isIncrease = percentChange >= 0;
    final badgeColor = isIncrease ? Colors.red : Colors.green;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Genel Maliyet Değişimi', style: TextStyle(fontSize: 13, color: Colors.grey)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(isIncrease ? Icons.trending_up : Icons.trending_down, size: 16, color: badgeColor),
                  const SizedBox(width: 4),
                  Text(
                    '${isIncrease ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.outlineVariant.withOpacity(0.3), strokeWidth: 1)),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (val, meta) => Text('${val.toStringAsFixed(1)} ₺', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                        final date = xToDate[value.toInt()];
                        if (date == null) return const Text('');
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(DateFormat('dd/MM').format(date), style: const TextStyle(fontSize: 9, color: Colors.grey)));
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: colorScheme.primary.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MaliyetNoktasi {
  final DateTime date;
  final double value;
  _MaliyetNoktasi(this.date, this.value);
}
