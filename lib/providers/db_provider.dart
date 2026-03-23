import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/db/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final isarProvider = FutureProvider((ref) async {
  final service = ref.watch(isarServiceProvider);
  return await service.db;
});
