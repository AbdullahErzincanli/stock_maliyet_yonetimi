import 'package:flutter/material.dart';

class StockListScreen extends StatelessWidget {
  const StockListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stok Yönetimi')),
      body: const Center(
        child: Text('Stok Listesi (Yapım Aşamasında)'),
      ),
    );
  }
}
