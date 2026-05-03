import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/helper/dose_id_helper.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_local_datasource.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/add_medicine.dart';
import 'package:med_guard/features/reminder/domain/entities/reminder.dart';
import 'package:med_guard/features/reminder/domain/usecases/schedule_reminder.dart';
import 'package:timezone/timezone.dart' as tz;

class AddMedicineWithSchedule {
  final AddMedicine addMedicine;
  final ScheduleReminder scheduleReminder;

  AddMedicineWithSchedule(this.addMedicine, this.scheduleReminder);

  Future<void> call(Medicine medicine) async {
    await addMedicine(medicine);

    final now = tz.TZDateTime.now(tz.local);

    final today = DateTime(now.year, now.month, now.day);

    final doseLocal = getIt<TrackingLocalDataSource>();

    for (final time in medicine.times.toSet()) {
      final scheduled = DateTime(
        today.year,
        today.month,
        today.day,
        time.hour,
        time.minute,
        0,
        0,
      );

      if (scheduled.isBefore(now.add(const Duration(seconds: 5)))) {
        continue;
      }

      final doseId = DoseIdHelper.generate(medicine.id, scheduled);

      final notificationId = doseId.codeUnits.fold(0, (a, b) => a + b);

      final existing = await doseLocal.getById(doseId);
      if (existing != null) {
        continue;
      }

      await scheduleReminder(
        Reminder(
          id: notificationId,
          medicineName: medicine.name,
          time: scheduled,
          payload: doseId,
        ),
      );

      await doseLocal.addDoseIfNotExists(
        DoseLogModel(
          id: doseId,
          medicineId: medicine.id,
          medicineName: medicine.name,
          scheduledTime: scheduled,
          status: "pending",
          updatedAt: DateTime.now(),
          notificationId: notificationId,
        ),
      );

      print("⏰ TODAY DOSE SCHEDULED: $scheduled");
    }
  }
}
