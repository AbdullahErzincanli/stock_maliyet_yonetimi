import 'package:flutter/material.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Satış Defteri')),
      body: const Center(
        child: Text('Satış Listesi (Yapım Aşamasında)'),
      ),
    );
  }
}
