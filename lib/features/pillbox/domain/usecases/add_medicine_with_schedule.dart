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

    final doseLocal = getIt<TrackingLocalDataSource>();

    for (final time in medicine.times.toSet()) {

      final scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
        time.second,
      );

      if (scheduled.isBefore(now)) {
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
