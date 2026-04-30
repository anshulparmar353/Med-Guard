import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/services/daily_dose_generator.dart';
import 'package:med_guard/features/pillbox/data/datasources/medicine_local_datasource.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/add_medicine.dart';
import 'package:med_guard/features/reminder/domain/entities/reminder.dart';
import 'package:med_guard/features/reminder/domain/usecases/schedule_reminder.dart';

class AddMedicineWithSchedule {
  final AddMedicine addMedicine;
  final ScheduleReminder scheduleReminder;

  AddMedicineWithSchedule(this.addMedicine, this.scheduleReminder);

  Future<void> call(Medicine medicine) async {
    await addMedicine(medicine);

    await getIt<DailyDoseGenerator>().generateTodayDoses();

    final meds = getIt<MedicineLocalDataSource>().getMedicines();
    print("📦 AFTER SAVE CHECK: ${meds.length}");

    final now = DateTime.now();

    final start = medicine.startDate ?? DateTime(now.year, now.month, now.day);
    final end = medicine.endDate ?? start.add(const Duration(days: 7));

    for (
      DateTime day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))
    ) {
      for (final time in medicine.times.toSet()) {
        final scheduled = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        );

        if (_isSameDay(day, now) && scheduled.isBefore(now)) {
          continue;
        }

        final doseId = "${medicine.id}-${scheduled.toIso8601String()}";

        final notificationId = doseId.hashCode;

        await scheduleReminder(
          Reminder(
            id: notificationId,
            medicineName: medicine.name,
            time: scheduled,
            payload: doseId,  
          ),
        );

        print("⏰ SCHEDULED: $scheduled");
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
