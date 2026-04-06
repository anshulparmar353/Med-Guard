import 'package:hive/hive.dart';
import 'package:med_guard/features/pillbox/data/datasources/medicine_local_datasource.dart';
import 'package:med_guard/features/pillbox/data/datasources/medicine_remote_datasource.dart';
import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';
import 'package:med_guard/features/sync/data/datasources/sync_queue_local_DB.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';
import 'package:med_guard/features/sync/domain/utils/conflict_resolver.dart';
import 'package:logger/logger.dart';

class SyncService {
  final SyncQueueLocalDataSource queue;
  final MedicineRemoteDataSource remote;
  final MedicineLocalDataSource local;

  bool _isSyncing = false;

  final Logger logger = Logger();

  SyncService({required this.queue, required this.remote, required this.local});

  /// 🔁 PUBLIC SYNC ENTRY
  Future<void> sync(String userId) async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      await _pushWithRetry(userId);
      await _pullWithRetry(userId);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushWithRetry(String userId) async {
    final items = queue.getAll().take(20).toList();

    for (final item in items) {
      try {
        await retry(() async {
          try {
            final data = Map<String, dynamic>.from(item.data as Map);

            if (item.type == SyncType.add || item.type == SyncType.update) {
              await remote.uploadMedicine(userId, data);
            } else if (item.type == SyncType.delete) {
              await remote.deleteMedicine(userId, data['id']);
            }
          } catch (e) {
            logger.e('Invalid sync item data: ${item.data}', error: e);
            return; // ✅ exit this retry attempt safely
          }
        });

        await queue.remove(item.id);
      } catch (e) {
        logger.e('Push failed', error: e);
        break;
      }
    }
  }

  Future<T> retry<T>(
    Future<T> Function() action, {
    int retries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await action();
      } catch (e) {
        if (attempt >= retries) rethrow;

        await Future.delayed(delay * (attempt + 1));
        attempt++;
      }
    }
  }

  Future<void> _pullWithRetry(String userId) async {
    final lastSync = await _getLastSyncTime();

    final remoteData = await retry(
      () => remote.fetchMedicines(userId, lastSync),
    );

    final localData = local.getMedicines();

    final remoteModels = remoteData
        .map((e) => MedicineModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final resolved = ConflictResolver.resolve(
      local: localData, 
      remote: remoteModels,
    );

    await local.replaceAll(resolved);

    await _saveLastSyncTime();
  }

  Future<DateTime?> _getLastSyncTime() async {
    final box = await Hive.openBox('sync_meta');
    return box.get('lastSync');
  }

  Future<void> _saveLastSyncTime() async {
    final box = await Hive.openBox('sync_meta');
    await box.put('lastSync', DateTime.now());
  }
}
