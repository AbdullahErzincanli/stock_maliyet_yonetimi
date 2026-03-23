import 'package:flutter/material.dart';

class SnackBarHelper {
  static void show(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars(); // Mevcut barları temizle ki Hero çakışmasın
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
