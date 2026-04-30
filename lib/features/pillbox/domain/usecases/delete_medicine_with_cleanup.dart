import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/reminder/domain/usecases/cancel_reminder.dart';

class DeleteMedicineWithCleanup {
  final MedicineRepository medicineRepository;
  final CancelReminder cancelReminder;
  final TrackingRepository trackingRepository;

  DeleteMedicineWithCleanup({
    required this.medicineRepository,
    required this.cancelReminder,
    required this.trackingRepository,
  });

  Future<void> call(String medicineId) async {
    final doses = await trackingRepository.getByMedicineId(medicineId);

    for (final dose in doses) {
      if (dose.notificationId != null) {
        await cancelReminder(dose.notificationId!);
      }
    }

    await trackingRepository.deleteByMedicineId(medicineId);

    await medicineRepository.deleteMedicine(medicineId);
  }
}
