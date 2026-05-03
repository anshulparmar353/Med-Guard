import 'package:hive/hive.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';

class TrackingLocalDataSource {
  final Box<DoseLogModel> box;

  TrackingLocalDataSource(this.box);

  Stream<List<DoseLogModel>> watchTodayDoses() async* {
    yield _getTodayInitial();

    await for (final _ in box.watch()) {
      print("📡 HIVE EVENT");

      final now = DateTime.now();

      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final result = box.values.where((d) {
        return d.scheduledTime.isAfter(
              start.subtract(const Duration(milliseconds: 1)),
            ) &&
            d.scheduledTime.isBefore(end);
      }).toList();

      print("📊 STREAM SIZE: ${result.length}");

      yield result;
    }
  }

  List<DoseLogModel> _getTodayInitial() {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return box.values.where((d) {
      return d.scheduledTime.isAfter(
            start.subtract(const Duration(milliseconds: 1)),
          ) &&
          d.scheduledTime.isBefore(end);
    }).toList();
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
    print("🧠 markTaken CALLED → $id");

    final dose = box.get(id);

    print("🔍 DOSE FOUND: ${dose != null}");

    if (dose != null) {
      final updated = dose.copyWith(
        status: DoseStatus.taken.name,
        takenAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await box.put(updated.id, updated);

      print("✅ UPDATED IN HIVE: ${updated.id} → ${updated.status}");
    } else {
      print("❌ DOSE NOT FOUND IN HIVE");
    }
  }

  Future<void> markSkipped(String id) async {
    final dose = box.get(id);
    if (dose != null) {
      final updated = dose.copyWith(
        status: DoseStatus.skipped.name,
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

  Future<void> update(DoseLogModel dose) async {
    print("🟡 HIVE UPDATE: ${dose.id} → ${dose.status}");
    await box.put(dose.id, dose);
  }

  Future<void> replaceAllDoses(List<DoseLogModel> doses) async {
    await box.clear();

    final map = {for (final d in doses) d.id: d};

    await box.putAll(map);
  }

  Future<void> addDoseIfNotExists(DoseLogModel dose) async {
    final exists = box.containsKey(dose.id);

    if (box.containsKey(dose.id)) {
      print("🚫 DUPLICATE BLOCKED: ${dose.id}");
      return;
    }

    await box.put(dose.id, dose);

    print("📦 HIVE WRITE: ${dose.id}");
    print("📦 TOTAL COUNT: ${box.length}");

    if (!exists) {
      print("✅ NEW DOSE ADDED: ${dose.id}");
    } else {
      print("♻️ DOSE UPDATED: ${dose.id}");
    }
  }
}
