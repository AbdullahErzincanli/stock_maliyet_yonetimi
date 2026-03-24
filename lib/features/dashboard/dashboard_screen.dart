import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../purchases/ocr_scan_screen.dart';
import '../budget/budget_screen.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget_snapshot.dart';
import '../../providers/sales_provider.dart';
import '../../providers/stock_provider.dart';
import '../../core/utils/unit_conversion.dart';
import '../../models/sale.dart';
import '../../models/ingredient.dart';
import '../../providers/report_settings_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Günaydın ☀️';
    if (hour >= 12 && hour < 17) return 'İyi Günler 🌤️';
    if (hour >= 17 && hour < 21) return 'İyi Akşamlar 🌇';
    return 'İyi Geceler 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final budgetAsync = ref.watch(monthlyBudgetSnapshotProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.1),
      appBar: AppBar(
        title: Text(
          'Özet', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.document_scanner_rounded, color: colorScheme.primary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrScanScreen())),
            tooltip: 'Fatura / Fiş Tara',
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header / Welcome Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(now),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Today's Sales Summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildTodaySalesSummary(salesAsync, context),
            ),
          ),

          // Period Settings Calculation Summary
          SliverToBoxAdapter(
            child: ref.watch(reportSettingsProvider).when(
              data: (settings) => _buildPeriodSalesSummary(salesAsync, settings, context),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
              error: (e, st) => const SizedBox.shrink(),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Stock Status / Warnings
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildStockSummary(ingredientsAsync, context),
            ),
          ),

          // Budget Summary Projection
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildBudgetSummary(budgetAsync, context),
            ),
          ),


          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildTodaySalesSummary(AsyncValue<List<Sale>> salesAsync, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return salesAsync.when(
      data: (sales) {
        final now = DateTime.now();
        final todaySales = sales.where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day).toList();
        
        final revenue = todaySales.fold(0.0, (sum, s) => sum + s.totalSalePrice);
        final cost = todaySales.fold(0.0, (sum, s) => sum + s.totalCost);
        final profit = revenue - cost;

        final bool hasData = revenue > 0 || cost > 0;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primaryContainer.withOpacity(0.9), colorScheme.primaryContainer.withOpacity(0.4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.primary.withOpacity(0.1), width: 1),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bugünkü Satış Performansı',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${todaySales.length} Satış',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildKpiGridItem('Gelir', revenue, Icons.arrow_upward_rounded, Colors.green),
                        const SizedBox(height: 12),
                        _buildKpiGridItem('Maliyet', cost, Icons.arrow_downward_rounded, Colors.orange),
                        const SizedBox(height: 12),
                        _buildKpiGridItem(
                          profit >= 0 ? 'Net Kâr' : 'Net Zarar', 
                          profit.abs(), 
                          profit >= 0 ? Icons.trending_up : Icons.trending_down, 
                          profit >= 0 ? Colors.teal : Colors.red
                        ),
                      ],
                    ),
                  ),
                  if (hasData) ...[
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              startDegreeOffset: -90,
                              sections: _getPieSections(cost, profit, colorScheme),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Kâr Oranı',
                                style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                              ),
                              Text(
                                revenue > 0 ? '%${((profit / revenue) * 100).toStringAsFixed(0)}' : '%0',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: profit >= 0 ? Colors.teal : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Satış verisi alınamadı: $e')),
    );
  }

  List<PieChartSectionData> _getPieSections(double cost, double profit, ColorScheme colorScheme) {
    final double total = cost + (profit > 0 ? profit : 0);
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.orange.withOpacity(0.8),
        value: cost,
        title: '',
        radius: 12,
      ),
      if (profit > 0)
        PieChartSectionData(
          color: Colors.teal.withOpacity(0.8),
          value: profit,
          title: '',
          radius: 16, // Kâr bölümü hafif öne çıksın
        ),
    ];
  }

  Widget _buildPeriodSalesSummary(AsyncValue<List<Sale>> salesAsync, dynamic settings, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    DateTime start, end;
    if (settings.periodType == 'weekly') {
      int currentDay = now.weekday;
      int diff = currentDay - (settings.startDayOfWeek as int);
      if (diff < 0) diff += 7;
      start = now.subtract(Duration(days: diff));
      start = DateTime(start.year, start.month, start.day);
      end = DateTime(start.year, start.month, start.day, 23, 59, 59).add(const Duration(days: 6));
    } else {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }

    return salesAsync.when(
      data: (sales) {
        final periodSales = sales.where((s) => !s.date.isBefore(start) && !s.date.isAfter(end)).toList();
        final revenue = periodSales.fold(0.0, (sum, s) => sum + s.totalSalePrice);
        final cost = periodSales.fold(0.0, (sum, s) => sum + s.totalCost);
        final profit = revenue - cost;

        final isWeekly = settings.periodType == 'weekly';
        final titleText = isWeekly ? 'Bu Haftaki Performans' : 'Bu Ayki Performans';
        final subtitleText = '${DateFormat('dd/MM').format(start)} - ${DateFormat('dd/MM').format(end)} Arası';

        final bool hasData = revenue > 0 || cost > 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.secondaryContainer.withOpacity(0.9), colorScheme.secondaryContainer.withOpacity(0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.secondary.withOpacity(0.1), width: 1),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         const SizedBox(height: 2),
                         Text(subtitleText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                       ]
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${periodSales.length} Satış',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildKpiGridItem('Gelir', revenue, Icons.arrow_upward_rounded, Colors.green),
                          const SizedBox(height: 12),
                          _buildKpiGridItem('Maliyet', cost, Icons.arrow_downward_rounded, Colors.orange),
                          const SizedBox(height: 12),
                          _buildKpiGridItem(
                            profit >= 0 ? 'Net Kâr' : 'Net Zarar', 
                            profit.abs(), 
                            profit >= 0 ? Icons.trending_up : Icons.trending_down, 
                            profit >= 0 ? Colors.teal : Colors.red
                          ),
                        ],
                      ),
                    ),
                    if (hasData) ...[
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 140,
                        width: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 40,
                                startDegreeOffset: -90,
                                sections: _getPieSections(cost, profit, colorScheme),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Kâr Oranı',
                                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                                ),
                                Text(
                                  revenue > 0 ? '%${((profit / revenue) * 100).toStringAsFixed(0)}' : '%0',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: profit >= 0 ? Colors.teal : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                       ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }



  Widget _buildKpiGridItem(String label, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 16,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${value.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: label.contains('Zarar') ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummary(AsyncValue<List<Ingredient>> ingredientsAsync, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ingredientsAsync.when(
      data: (ingredients) {
        final totalValue = ingredients.fold(0.0, (sum, i) => sum + (i.stockAmount * i.avgCost));
        final criticals = ingredients.where((i) => i.stockAmount < i.minStockLevel).toList();

        return Column(
          children: [


            // Kritik Stoklar Bölümü
            if (criticals.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Kritik Stoklar (${criticals.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...criticals.take(4).map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '• ${c.name}',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  UnitConversionService.formatAmount(c.stockAmount, c.unit),
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (criticals.length > 4)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '...ve ${criticals.length - 4} tane daha',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.withOpacity(0.2), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Kritik seviyede hammadde bulunmamaktadır.',
                      style: TextStyle(color: Colors.teal, fontSize: 13),
                    ),
                  ],
                ),
              )
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Stok verisi alınamadı: $e')),
    );
  }

  Widget _buildBudgetSummary(AsyncValue<BudgetSnapshot> budgetAsync, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return budgetAsync.when(
      data: (data) {
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.secondaryContainer.withOpacity(0.9), colorScheme.secondaryContainer.withOpacity(0.4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.secondary.withOpacity(0.1), width: 1),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bütçe ve Fon Planlama',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                        ]
                      ),
                      child: Icon(Icons.savings_rounded, color: Colors.amber[700], size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bu Ayki Toplam Ciro',
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            '${data.totalRevenue.toStringAsFixed(2)} ₺',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '%${(data.budgetRatio * 100).toInt()} Önerilen Hammadde Bütçesi',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${data.suggestedBudget.toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.4),
                     borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                     children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                           child: Text(
                             'Yeni hammadde alımları için bu bütçeyi kenara ayırmayı düşünebilirsiniz.',
                             style: TextStyle(fontSize: 11, color: Colors.black87),
                           ),
                        ),
                     ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Bütçe hesaplanamadı: $e')),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 20,
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
