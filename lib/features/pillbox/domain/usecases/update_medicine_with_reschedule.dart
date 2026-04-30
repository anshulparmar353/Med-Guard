import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/reminder/domain/usecases/cancel_reminder.dart';
import 'package:med_guard/features/reminder/domain/usecases/schedule_reminder.dart';
import 'package:med_guard/features/reminder/domain/entities/reminder.dart';

class UpdateMedicineWithReschedule {
  final MedicineRepository medicineRepository;
  final CancelReminder cancelReminder;
  final ScheduleReminder scheduleReminder;

  UpdateMedicineWithReschedule({
    required this.medicineRepository,
    required this.cancelReminder,
    required this.scheduleReminder,
  });

  Future<void> call(Medicine medicine) async {
    final now = DateTime.now();

    final start = medicine.startDate ?? DateTime(now.year, now.month, now.day);
    final end = medicine.endDate ?? start.add(const Duration(days: 7));

    for (
      DateTime day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))
    ) {
      for (final time in medicine.times) {
        final scheduled = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        );

        final id = "${medicine.id}_${scheduled.toIso8601String()}".hashCode;

        await cancelReminder(id);
      }
    }

    // 🔥 STEP 2: UPDATE MEDICINE
    await medicineRepository.addMedicine(medicine);

    // 🔥 STEP 3: RESCHEDULE
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

        if (_isSameDay(day, now) && scheduled.isBefore(now)) continue;

        final doseId = "${medicine.id}-${scheduled.toIso8601String()}";

        final notificationId = doseId.hashCode;

        await scheduleReminder(
          Reminder(
            id: notificationId,
            payload: doseId,
            medicineName: medicine.name,
            time: scheduled,
          ),
        );
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
