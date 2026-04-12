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

  Future<List<DoseLogModel>> getAllDoses() async {
    return box.values.toList();
  }

  Future<List<DoseLogModel>> getInRange(DateTime start, DateTime end) async {
    return box.values.where((d) {
      return !d.scheduledTime.isBefore(start) && !d.scheduledTime.isAfter(end);
    }).toList();
  }

  Future<void> markTaken(String id) async {
    final dose = box.get(id);
    if (dose != null) {
      final updated = dose.copyWith(
        status: "taken",
        takenAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await box.put(updated.id, updated);
    }
  }

  Future<void> markSkipped(String id) async {
    final dose = box.get(id);
    if (dose != null) {
      final updated = dose.copyWith(
        status: "skipped",
        updatedAt: DateTime.now(),
      );

      await box.put(updated.id, updated);
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

  Future<DoseLogModel?> getById(String id) async {
    return box.get(id);
  }

  Future<void> update(DoseLogModel model) async {
    await box.put(model.id, model);
  }

  Future<void> replaceAllDoses(List<DoseLogModel> doses) async {
    await box.clear();
    for (final d in doses) {
      await box.put(d.id, d);
    }
  }
}
