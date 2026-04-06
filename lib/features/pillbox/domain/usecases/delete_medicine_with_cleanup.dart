import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/reminder/domain/usecases/cancel_reminder.dart';

class DeleteMedicineWithCleanup {
  final MedicineRepository medicineRepository;
  final TrackingRepository trackingRepository;
  final CancelReminder cancelReminder;

  DeleteMedicineWithCleanup({
    required this.medicineRepository,
    required this.trackingRepository,
    required this.cancelReminder,
  });

  Future<void> call(String medicineId) async {
    // 🔥 1. Get related doses
    final doses = await trackingRepository.getByMedicineId(medicineId);

    // 🔥 2. Cancel reminders
    for (final dose in doses) {
      await cancelReminder.call(dose.notificationId);
    }

    // 🔥 3. Delete dose logs
    await trackingRepository.deleteByMedicineId(medicineId);

    // 🔥 4. Delete medicine
    await medicineRepository.deleteMedicine(medicineId);
  }
}