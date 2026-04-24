import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/sync/data/datasources/sync_queue_local_DB.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';

import '../../domain/entities/dose_log.dart';
import '../datasources/tracking_local_datasource.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource local;
  final SyncQueueLocalDataSource synclocal;

  TrackingRepositoryImpl(this.local, this.synclocal);

  @override
  Future<DoseLog> createDose({
    required String medicineId,
    required String medicineName,
    required DateTime scheduledTime,
  }) async {
    final model = await local.createDose(
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,
    );
    return model.toEntity();
  }

  @override
  Future<List<DoseLog>> getTodayDoses() async {
    final now = DateTime.now();

    final doses = await local.getAllDoses(); 

    final list = doses.where((d) {
      return d.scheduledTime.year == now.year &&
          d.scheduledTime.month == now.month &&
          d.scheduledTime.day == now.day;
    }).toList();

    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<DoseLog>> getInRange(DateTime start, DateTime end) async {
    final list = await local.getInRange(start, end);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> markTaken(String id) async {
    final dose = await local.getById(id);
    if (dose == null) return;

    // ❗ Idempotency
    if (dose.status == "taken") return;

    final updated = dose.copyWith(
      status: "taken",
      takenAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await local.update(updated);

    await synclocal.add(
      SyncItem(
        id: updated.id, 
        type: SyncType.updateDose,
        data: updated.toJson(),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> markSkipped(String id) async {
    final dose = await local.getById(id);
    if (dose == null) return;

    if (dose.status == "skipped") return;

    final updated = dose.copyWith(status: "skipped", updatedAt: DateTime.now());

    await local.update(updated);

    await synclocal.add(
      SyncItem(
        id: updated.id,
        type: SyncType.updateDose,
        data: updated.toJson(),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<DoseLog>> getByMedicineId(String medicineId) async {
    final list = await local.getByMedicineId(medicineId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> deleteByMedicineId(String medicineId) async {
    await local.deleteByMedicineId(medicineId);
  }

  @override
  Future<void> markMissed(String id) async {
    final dose = await local.getById(id);
    if (dose == null) return;

    if (dose.status != DoseStatus.pending.name) return;

    final now = DateTime.now();

    final updated = dose.copyWith(
      status: DoseStatus.missed.name,
      updatedAt: now,
    );

    await local.update(updated);

    await synclocal.add(
      SyncItem(
        id: updated.id,
        type: SyncType.updateDose,
        data: updated.toJson(),
        createdAt: now,
      ),
    );

  }
}
