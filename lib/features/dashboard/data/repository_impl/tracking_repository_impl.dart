import 'dart:async';

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
  Stream<List<DoseLog>> watchTodayDoses() {
    return local.watchTodayDoses().map(
      (models) => models.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<List<DoseLog>> getDosesInRange(DateTime start, DateTime end) async {
    final all = await local.getAllDoses();

    final filtered = all.where(
      (d) => !d.scheduledTime.isBefore(start) && !d.scheduledTime.isAfter(end),
    );

    return filtered.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<DoseLog>> getTodayDoses() async {
    final all = await local.getAllDoses();

    final now = DateTime.now();

    return all
        .where(
          (d) =>
              d.scheduledTime.year == now.year &&
              d.scheduledTime.month == now.month &&
              d.scheduledTime.day == now.day,
        )
        .map((e) => e.toEntity())
        .toList();
  }

  @override
  Future<void> markTaken(String doseId) async {
    final dose = await local.getById(doseId);
    if (dose == null) return;

    final updated = dose.copyWith(
      status: DoseStatus.taken.name,
      takenAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await local.update(updated);

    unawaited(
      synclocal.add(
        SyncItem(
          id: updated.id,
          type: SyncType.updateDose,
          data: updated.toLocalJson(),
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<void> markSkipped(String doseId) async {
    final dose = await local.getById(doseId);
    if (dose == null) return;

    final updated = dose.copyWith(
      status: DoseStatus.skipped.name,
      updatedAt: DateTime.now(),
    );

    await local.update(updated);

    unawaited(
      synclocal.add(
        SyncItem(
          id: updated.id,
          type: SyncType.updateDose,
          data: updated.toLocalJson(),
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<void> markMissed(String id) async {
    final dose = await local.getById(id);
    if (dose == null) return;

    if (dose.status != DoseStatus.pending.name) return;

    final updated = dose.copyWith(
      status: DoseStatus.missed.name,
      updatedAt: DateTime.now(),
    );

    await local.update(updated);

    unawaited(
      synclocal.add(
        SyncItem(
          id: updated.id,
          type: SyncType.updateDose,
          data: updated.toLocalJson(),
          createdAt: DateTime.now(),
        ),
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
}
