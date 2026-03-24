import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/report_settings.dart';
import 'db_provider.dart';

final reportSettingsProvider = AsyncNotifierProvider<ReportSettingsNotifier, ReportSettings>(() => ReportSettingsNotifier());

class ReportSettingsNotifier extends AsyncNotifier<ReportSettings> {
  @override
  Future<ReportSettings> build() async {
    final isar = await ref.watch(isarProvider.future);
    final settings = await isar.reportSettings.get(1);
    return settings ?? ReportSettings();
  }

  Future<void> updateSettings(ReportSettings newSettings) async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.reportSettings.put(newSettings);
    });
    ref.invalidateSelf(); // Refresh state
  }
}
