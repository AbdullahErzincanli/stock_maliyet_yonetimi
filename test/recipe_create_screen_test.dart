import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_maliyet_yonetimi/features/production/recipe_create_screen.dart';

void main() {
  testWidgets('RecipeCreateScreen renders fully without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RecipeCreateScreen(),
        ),
      ),
    );

    // Verifying if basic UI elements are present to rule out a build crash.
    expect(find.text('Yeni Ürün/Reçete'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Name, Unit
    expect(find.text('Hammadde Ekle'), findsOneWidget);
    expect(find.text('REÇETEYİ KAYDET'), findsOneWidget);
  });
}
