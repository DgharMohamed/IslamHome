import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/services/firestore_sync_service.dart';

final systemConfigProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final syncService = ref.watch(firestoreSyncServiceProvider);
  return await syncService.getSystemConfig();
});

final maintenanceModeProvider = Provider<bool>((ref) {
  final config = ref.watch(systemConfigProvider).asData?.value;
  return config?['maintenanceMode'] ?? false;
});
