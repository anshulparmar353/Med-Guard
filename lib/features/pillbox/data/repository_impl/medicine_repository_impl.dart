import 'package:med_guard/core/services/notification_service.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/sync/data/datasources/sync_queue_local_DB.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';

import '../../domain/entities/medicine.dart';
import '../datasources/medicine_local_datasource.dart';
import '../models/medicine_model.dart';

import 'package:workmanager/workmanager.dart';
import 'package:med_guard/core/services/background_worker.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineLocalDataSource local;
  final SyncQueueLocalDataSource queue;
  final SyncService syncService;

  MedicineRepositoryImpl({
    required this.local,
    required this.queue,
    required this.syncService,
  });

  @override
  Future<void> addMedicine(Medicine medicine) async {
    print("REPOSITORY CALLED");

    final model = MedicineModel.fromEntity(medicine);

    try {
      await local.addMedicine(model);

      for (final time in model.times) {
        final delay = time.difference(DateTime.now());

        if (delay.isNegative) continue;

        if (time.isBefore(DateTime.now())) continue;  

        // 🔹 Normal notification (already exists)
        await NotificationService.schedule(
          id: NotificationService.generateId(),
          title: "Medicine Reminder 💊",
          body: "Take ${model.name} (${model.dosage})",
          time: time,
          payload: model.id,
        );

        // 🔥 BACKUP (WorkManager)
        Workmanager().registerOneOffTask(
          "med_${time.millisecondsSinceEpoch}",
          medicineTask,
          initialDelay: delay,
          inputData: {"body": "Take ${model.name}", "doseId": model.id},
        );
      }

      print("Saving to Hive: ${model.name}");

      print("QUEUE TYPE: ${queue.runtimeType}");

      final cleanData = _cleanForHive(model.toJson());

      print("CLEAN DATA: $cleanData");

      await queue.add(
        SyncItem(
          id: model.id,
          type: SyncType.add,
          data: cleanData,
          createdAt: DateTime.now(),
        ),
      );

      print("ADDED TO SYNC QUEUE");
    } catch (e, stack) {
      print("ERROR IN REPOSITORY: $e");
      print(stack);
    }
  }

  @override
  Future<void> deleteMedicine(String id) async {
    await local.deleteMedicine(id);

    await queue.add(
      SyncItem(
        id: id,
        type: SyncType.delete,
        data: {'id': id},
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> replaceAllMedicines(List<Medicine> medicines) async {
    for (final med in medicines) {
      final model = MedicineModel.fromEntity(med);

      await local.addMedicine(model);

      await queue.add(
        SyncItem(
          id: model.id,
          type: SyncType.add,
          data: _cleanForHive(model.toJson()),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<List<Medicine>> getMedicines() async {
    final data = local.getMedicines();
    return data.map((m) => m.toEntity()).toList();
  }

  Map<String, dynamic> _cleanForHive(Map<String, dynamic> data) {
    return data.map((key, value) {
      return MapEntry(key, _cleanValue(value));
    });
  }

  dynamic _cleanValue(dynamic value) {
    if (value != null && value.toString().contains('Timestamp')) {
      try {
        return value.toDate().toIso8601String();
      } catch (_) {
        return value.toString();
      }
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is List) {
      return value.map((e) => _cleanValue(e)).toList();
    }

    if (value is Map) {
      return value.map((k, v) => MapEntry(k, _cleanValue(v)));
    }

    return value;
  }

  int generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  }
}
