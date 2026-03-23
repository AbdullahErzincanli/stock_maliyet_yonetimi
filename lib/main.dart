import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/db/isar_service.dart';
import 'features/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // Isar'ı uygulama açılmadan ÖNCE başlat (splash screen arkasında)
  final isarService = IsarService();
  await isarService.db;

  runApp(
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
