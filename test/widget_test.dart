import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stock_maliyet_yonetimi/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // ProviderScope ile sarmalayıp build alıyoruz.
    await tester.pumpWidget(
      const ProviderScope(
        child: StokMaliyetApp(),
      ),
    );

    // Başlangıç ekranındaki "Özet" başlığını bulmasını bekliyoruz
    expect(find.text('Özet'), findsWidgets);
  });
}
