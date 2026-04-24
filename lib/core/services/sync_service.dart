import 'package:hive/hive.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_local_datasource.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_remote_datasource.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/pillbox/data/datasources/medicine_local_datasource.dart';
import 'package:med_guard/features/pillbox/data/datasources/medicine_remote_datasource.dart';
import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';
import 'package:med_guard/features/sync/data/datasources/sync_queue_local_DB.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';
import 'package:med_guard/features/sync/domain/utils/conflict_resolver.dart';
import 'package:logger/logger.dart';

class SyncService {
  SyncService({
    required this.queue,
    required this.remote,
    required this.local,
    required this.trackingRemote,
    required this.trackingLocal,
  });

  final SyncQueueLocalDataSource queue;
  final MedicineRemoteDataSource remote;
  final MedicineLocalDataSource local;
  final TrackingRemoteDataSource trackingRemote;
  final TrackingLocalDataSource trackingLocal;

  bool _isSyncing = false;

  final Logger logger = Logger();

  Future<void> sync(String userId) async {
    if (_isSyncing) return;

    print("SYNC STARTED");

    _isSyncing = true;

    try {
      await _pushWithRetry(userId);
      await _pullWithRetry(userId);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushWithRetry(String userId) async {
    print("PUSHING DATA");
    final items = queue.getAll().take(20).toList();

    for (final item in items) {
      try {
        await retry(() async {
          try {
            final data = Map<String, dynamic>.from(item.data as Map);

            if (item.type == SyncType.add || item.type == SyncType.update) {
              await remote.uploadMedicine(userId, data);
            } else if (item.type == SyncType.updateDose) {
              await trackingRemote.uploadDose(userId, data);
            } else if (item.type == SyncType.delete) {
              await remote.deleteMedicine(userId, data['id']);
            }
          } catch (e) {
            logger.e('Invalid sync item data: ${item.data}', error: e);
            return;
          }
        });

        await queue.remove(item.id);
      } catch (e) {
        logger.e('Push failed', error: e);

        await queue.incrementRetry(item.id);

        if (item.retryCount > 3) {
          logger.e('Dropping item after max retries: ${item.id}');
          await queue.remove(item.id);
        }

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
    print("PULL DATA");
    final lastSync = await _getLastSyncTime();

    final remoteMedicines = await retry(
      () => remote.fetchMedicines(userId, lastSync),
    );

    final localMedicines = local.getMedicines();

    final medicineModels = remoteMedicines
        .map((e) => MedicineModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final resolvedMedicines = ConflictResolver.resolve<MedicineModel>(
      local: localMedicines,
      remote: medicineModels,
      getId: (m) => m.id,
      getUpdatedAt: (m) => m.updatedAt,
    );

    await local.replaceAll(resolvedMedicines);

    final remoteDoses = await retry(
      () => trackingRemote.fetchDoses(userId, lastSync),
    );

    final localDoses = await trackingLocal.getAllDoses();

    final doseModels = remoteDoses
        .map((e) => DoseLogModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final resolvedDoses = ConflictResolver.resolve<DoseLogModel>(
      local: localDoses,
      remote: doseModels,
      getId: (d) => d.id,
      getUpdatedAt: (d) => d.updatedAt,
    );

    await trackingLocal.replaceAllDoses(resolvedDoses);

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
