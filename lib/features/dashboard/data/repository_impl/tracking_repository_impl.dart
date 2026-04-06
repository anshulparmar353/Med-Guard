import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

import '../../domain/entities/dose_log.dart';
import '../datasources/tracking_local_datasource.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource local;

  TrackingRepositoryImpl(this.local);

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

    final list = local.getAll().where((d) {
      return d.scheduledTime.year == now.year &&
          d.scheduledTime.month == now.month &&
          d.scheduledTime.day == now.day;
    }).toList();

    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<DoseLog>> getInRange(
      DateTime start, DateTime end) async {
    final list = await local.getInRange(start, end);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> markTaken(String id) async {
    await local.markTaken(id);
  }

  @override
  Future<void> markSkipped(String id) async {
    await local.markSkipped(id);
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