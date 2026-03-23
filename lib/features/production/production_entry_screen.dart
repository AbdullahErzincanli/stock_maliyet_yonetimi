import 'package:flutter/material.dart';

class ProductionEntryScreen extends StatelessWidget {
  const ProductionEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üretim Girişi')),
      body: const Center(
        child: Text('Üretim Ekranı (Yapım Aşamasında)'),
      ),
    );
  }
}
