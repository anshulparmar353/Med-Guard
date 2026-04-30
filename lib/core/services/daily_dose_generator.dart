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

    print("📦 TOTAL MEDICINES: ${medicines.length}");

    final now = DateTime.now();

    final startOfDay = DateTime(now.year, now.month, now.day);

    for (final med in medicines) {
      print(
        "💊 MED: ${med.name}, isDaily: ${med.isDaily}, times: ${med.times}",
      );

      if (!med.isDaily) continue;

      for (final time in med.times) {
        final scheduled = DateTime(
          startOfDay.year,
          startOfDay.month,
          startOfDay.day,
          time.hour,
          time.minute,
        );

        print("⏱ CHECK TIME: $scheduled | now: $now");

        final doseId = DoseIdHelper.generate(med.id, scheduled);
        
        final exists = await doseLocal.getById(doseId);

        if (exists != null) {
          print("⚠️ DOSE EXISTS: $doseId");
          continue;
        }

        final notificationId = doseId.hashCode;

        if (scheduled.isBefore(now)) {
          await doseLocal.addDoseIfNotExists(
            DoseLogModel(
              id: doseId,
              medicineId: med.id,
              medicineName: med.name,
              scheduledTime: scheduled,
              status: "missed",
              updatedAt: now,
              notificationId: notificationId,
            ),
          );

          print("❌ MISSED DOSE CREATED: $doseId");
          continue;
        }

        final dose = DoseLogModel(
          id: doseId,
          medicineId: med.id,
          medicineName: med.name,
          scheduledTime: scheduled,
          status: "pending",
          updatedAt: scheduled,
          notificationId: notificationId,
        );

        print("🆕 TRY ADD DOSE: $doseId");

        await doseLocal.addDoseIfNotExists(dose);

        print("📦 DOSE CREATED: $doseId");
      }
    }
  }
}
