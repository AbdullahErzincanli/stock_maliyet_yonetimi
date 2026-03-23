import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'stock/stock_list_screen.dart';
import 'production/production_entry_screen.dart';
import 'sales/sales_list_screen.dart';
import 'report/report_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    StockListScreen(),
    ProductionEntryScreen(),
    SalesListScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Dış Scaffold kullanmıyoruz!
    // Her alt ekranın kendi Scaffold'u var, FAB'ları engellenmez.
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
        NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Özet'),
            NavigationDestination(icon: Icon(Icons.inventory), label: 'Stok'),
            NavigationDestination(icon: Icon(Icons.restaurant), label: 'Üretim'),
            NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Satış'),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Rapor'),
          ],
        ),
      ],
    );
  }
}
