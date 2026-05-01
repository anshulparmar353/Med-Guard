import 'package:med_guard/core/helper/dose_id_helper.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_local_datasource.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/pillbox/data/datasources/medicine_local_datasource.dart';

class DailyDoseGenerator {
  final MedicineLocalDataSource medicineLocal;
  final TrackingLocalDataSource doseLocal;

  DailyDoseGenerator({required this.medicineLocal, required this.doseLocal});

  Future<void> generateTodayDoses() async {
    print("🔥 GENERATOR RUNNING");

    final medicines = medicineLocal.getMedicines();
    final existingDoses = await doseLocal.getAllDoses();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    print("📦 MED COUNT: ${medicines.length}");
    print("📦 EXISTING DOSES: ${existingDoses.length}");

    for (final d in existingDoses) {
      final isToday =
          d.scheduledTime.year == now.year &&
          d.scheduledTime.month == now.month &&
          d.scheduledTime.day == now.day;

      if (!isToday) continue;

      final stillValid = medicines.any((med) {
        if (med.id != d.medicineId) return false;

        return med.times.any(
          (t) =>
              t.hour == d.scheduledTime.hour &&
              t.minute == d.scheduledTime.minute,
        );
      });

      if (!stillValid) {
        await doseLocal.deleteByMedicineId(d.id);
        print("🗑 REMOVED OLD DOSE: ${d.id}");
      }
    }

    for (final med in medicines) {
      if (!med.isDaily) continue;

      print("💊 MED: ${med.name}");

      for (final time in med.times) {
        final scheduled = DateTime(
          startOfDay.year,
          startOfDay.month,
          startOfDay.day,
          time.hour,
          time.minute,
        );

        final doseId = DoseIdHelper.generate(med.id, scheduled);

        final existing = await doseLocal.getById(doseId);

        final notificationId = doseId.hashCode;

        if (existing != null) {
          await doseLocal.update(
            existing.copyWith(
              medicineName: med.name,
              scheduledTime: scheduled,
              updatedAt: DateTime.now(),

              status: existing.status,
            ),
          );

          print("♻️ UPDATED DOSE: $doseId");
          continue;
        }

        final status = scheduled.isBefore(now) ? "missed" : "pending";

        final dose = DoseLogModel(
          id: doseId,
          medicineId: med.id,
          medicineName: med.name,
          scheduledTime: scheduled,
          status: status,
          updatedAt: DateTime.now(),
          notificationId: notificationId,
        );

        await doseLocal.addDoseIfNotExists(dose);

        print("🆕 CREATED DOSE: $doseId");
      }
    }

    print("✅ GENERATION COMPLETE");
  }
}
