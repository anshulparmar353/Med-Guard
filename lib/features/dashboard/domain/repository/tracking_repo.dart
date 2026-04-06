import '../entities/dose_log.dart';

abstract class TrackingRepository {
  Future<DoseLog> createDose({
    required String medicineId,
    required String medicineName,
    required DateTime scheduledTime,
  });

  Future<List<DoseLog>> getTodayDoses();

  Future<List<DoseLog>> getInRange(DateTime start, DateTime end);

  Future<void> markTaken(String id);

  Future<void> markSkipped(String id);

  Future<List<DoseLog>> getByMedicineId(String medicineId);

  Future<void> deleteByMedicineId(String medicineId);
}