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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Sekmeler her zaman görünsün
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Özet'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stok'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Üretim'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Satış'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Rapor'),
        ],
      ),
    );
  }
}
