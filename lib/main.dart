import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/main_navigation_screen.dart';

void main() {
  runApp(
    // Riverpod'in çalışması için ProviderScope sarmalıyız
    const ProviderScope(
      child: StokMaliyetApp(),
    ),
  );
}

class StokMaliyetApp extends StatelessWidget {
  const StokMaliyetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stok ve Maliyet',
      theme: AppTheme.lightTheme,
      // Türkçe dil desteği ayarları
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      locale: const Locale('tr', 'TR'),
      home: const MainNavigationScreen(),
    );
  }
}
