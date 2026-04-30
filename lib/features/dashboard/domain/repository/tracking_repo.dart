import '../entities/dose_log.dart';

abstract class TrackingRepository {
  Stream<List<DoseLog>> watchTodayDoses();

  Future<void> markTaken(String id);

  Future<List<DoseLog>> getTodayDoses();

  Future<List<DoseLog>> getDosesInRange(DateTime start, DateTime end);

  Future<void> markSkipped(String id);

  Future<void> markMissed(String id);

  Future<List<DoseLog>> getByMedicineId(String medicineId);

  Future<void> deleteByMedicineId(String medicineId);
}
