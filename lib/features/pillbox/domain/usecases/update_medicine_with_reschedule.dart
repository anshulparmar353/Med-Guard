import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/dashboard/domain/usecases/create_dose.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/reminder/domain/entities/reminder.dart';
import 'package:med_guard/features/reminder/domain/usecases/cancel_reminder.dart';
import 'package:med_guard/features/reminder/domain/usecases/schedule_reminder.dart';

class UpdateMedicineWithReschedule {
  final MedicineRepository medicineRepository;
  final TrackingRepository trackingRepository;
  final ScheduleReminder scheduleReminder;
  final CancelReminder cancelReminder;
  final CreateDose createDose;

  UpdateMedicineWithReschedule({
    required this.medicineRepository,
    required this.trackingRepository,
    required this.scheduleReminder,
    required this.cancelReminder,
    required this.createDose,
  });

  Future<void> call(Medicine medicine) async {
    // 🔥 1. Get old doses
    final oldDoses = await trackingRepository.getByMedicineId(medicine.id);

    // 🔥 2. Cancel old reminders
    for (final dose in oldDoses) {
      await cancelReminder(dose.notificationId); // ✅ FIXED
    }

    // 🔥 3. Delete old dose logs
    await trackingRepository.deleteByMedicineId(medicine.id);

    // 🔥 4. Update medicine
    await medicineRepository.addMedicine(medicine);

    // 🔥 5. Generate new doses + reminders
    for (final time in medicine.times) {
      // Combine date + time (important)
      final now = DateTime.now();

      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Create dose
      final dose = await createDose.call(
        medicineId: medicine.id,
        medicineName: medicine.name,
        scheduledTime: scheduledTime,
      );

      // Schedule reminder
      await scheduleReminder(
        Reminder(
          id: dose.notificationId,
          medicineName: medicine.name,
          time: scheduledTime,
        ),
      );
    }
  }
}
