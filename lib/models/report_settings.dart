import 'package:isar/isar.dart';

part 'report_settings.g.dart';

@collection
class ReportSettings {
  Id id = 1; // Tek bir ayar kaydı yeterli, id=1 sabitleyebiliriz.

  String periodType = 'monthly'; // 'monthly', 'weekly'
  int startDayOfWeek = 6; // 6 = Cumartesi (DateTime.saturday), haftalık periyot başlangıcı
  bool showProfitAndCost = false;
  bool showTime = false; // Added: Raporlarda saati göster/gizle

  DateTime? filterStartDate; // Raporlama filtre başlangıç tarihi
  DateTime? filterEndDate; // Raporlama filtre bitiş tarihi
}
