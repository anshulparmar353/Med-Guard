import 'package:hive/hive.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';

class TrackingLocalDataSource {
  final Box<DoseLogModel> box;

  TrackingLocalDataSource(this.box);

  Future<DoseLogModel> createDose({
    required String medicineId,
    required String medicineName,
    required DateTime scheduledTime,
  }) async {
    final id = "$medicineId-${scheduledTime.toIso8601String()}";

    final existing = box.get(id);
    if (existing != null) return existing;

    final dose = DoseLogModel(
      id: id,
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,
      status: "pending",
      updatedAt: DateTime.now(),
      notificationId: id.hashCode & 0x7fffffff,
    );

    await box.put(id, dose);
    return dose;
  }

  List<DoseLogModel> getAll() => box.values.toList();

  Future<List<DoseLogModel>> getInRange(DateTime start, DateTime end) async {
    return box.values.where((d) {
      return !d.scheduledTime.isBefore(start) && !d.scheduledTime.isAfter(end);
    }).toList();
  }

  Future<void> markTaken(String id) async {
    final dose = box.get(id);
    if (dose != null) {
      dose.status = "taken";
      dose.takenAt = DateTime.now();
      dose.updatedAt = DateTime.now();
      await dose.save();
    }
  }

  Future<void> markSkipped(String id) async {
    final dose = box.get(id);
    if (dose != null) {
      dose.status = "skipped";
      dose.updatedAt = DateTime.now();
      await dose.save();
    }
  }

  Future<List<DoseLogModel>> getByMedicineId(String medicineId) async {
    return box.values.where((d) => d.medicineId == medicineId).toList();
  }

  Future<void> deleteByMedicineId(String medicineId) async {
    final keys = box.keys.where((k) {
      final d = box.get(k);
      return d?.medicineId == medicineId;
    }).toList();

    await box.deleteAll(keys);
  }
}
