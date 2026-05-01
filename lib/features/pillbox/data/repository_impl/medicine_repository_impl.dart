import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/sync/data/datasources/sync_queue_local_DB.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';

import '../../domain/entities/medicine.dart';
import '../datasources/medicine_local_datasource.dart';
import '../models/medicine_model.dart';

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

    final med = MedicineModel.fromEntity(medicine);

    try {
      await local.addMedicine(med);
      await local.box.flush();

      print("✅ SAVED TO HIVE: ${med.name}");
      final cleanData = _cleanForHive(med.toJson());

      print("CLEAN DATA: $cleanData");

      await queue.add(
        SyncItem(
          id: med.id,
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
    final med = local.box.get(id);

    if (med == null) return;

    final updated = med.copyWith(isDeleted: true, updatedAt: DateTime.now());

    await local.addMedicine(updated); 

    final cleanData = _cleanForHive(updated.toJson());

    await queue.add(
      SyncItem(
        id: updated.id,
        type: SyncType.delete,
        data: cleanData, 
        createdAt: DateTime.now(),
      ),
    );

    print("🗑 SOFT DELETE QUEUED: ${updated.id}");
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
}
