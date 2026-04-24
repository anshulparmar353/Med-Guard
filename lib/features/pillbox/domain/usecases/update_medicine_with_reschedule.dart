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

    final oldDoses = await trackingRepository.getByMedicineId(medicine.id);

    for (final dose in oldDoses) {
      await cancelReminder(dose.notificationId); 
    }

    await trackingRepository.deleteByMedicineId(medicine.id);

    await medicineRepository.addMedicine(medicine);

    for (final time in medicine.times) {

      final now = DateTime.now();

      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      final dose = await createDose.call(
        medicineId: medicine.id,
        medicineName: medicine.name,
        scheduledTime: scheduledTime,
      );

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
