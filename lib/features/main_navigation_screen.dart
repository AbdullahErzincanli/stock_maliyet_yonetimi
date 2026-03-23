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

  // Hangi sekmelerin daha önce ziyaret edildiğini izle (tembel yükleme)
  final Set<int> _initializedTabs = {0};

  static const List<Widget> _allScreens = [
    DashboardScreen(),
    StockListScreen(),
    ProductionEntryScreen(),
    SalesListScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_allScreens.length, (i) {
          if (_initializedTabs.contains(i)) {
            return HeroMode(
              enabled: i == _currentIndex,
              child: _allScreens[i],
            );
          }
          return const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: NavigationBar(
        height: 65, // Yüksekliği azalttık
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            _initializedTabs.add(index);
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home, size: 22), label: 'Özet'),
          NavigationDestination(icon: Icon(Icons.inventory, size: 22), label: 'Stok'),
          NavigationDestination(icon: Icon(Icons.restaurant, size: 22), label: 'Ürünler'),
          NavigationDestination(icon: Icon(Icons.point_of_sale, size: 22), label: 'Satış'),
          NavigationDestination(icon: Icon(Icons.bar_chart, size: 22), label: 'Rapor'),
        ],
      ),
    );
  }
}
