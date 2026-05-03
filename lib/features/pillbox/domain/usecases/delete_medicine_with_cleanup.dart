import 'package:med_guard/features/dashboard/data/datasources/tracking_remote_datasource.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/reminder/domain/usecases/cancel_reminder.dart';

class DeleteMedicineWithCleanup {
  final MedicineRepository medicineRepository;
  final CancelReminder cancelReminder;
  final TrackingRepository trackingRepository;
  final TrackingRemoteDataSource remote;

  DeleteMedicineWithCleanup({
    required this.medicineRepository,
    required this.cancelReminder,
    required this.trackingRepository,
    required this.remote,
  });

  Future<void> call(String userId, String medicineId) async {
    final doses = await trackingRepository.getByMedicineId(medicineId);

    for (final dose in doses) {
      if (dose.notificationId != null) {
        await cancelReminder(dose.notificationId!);
      }
    }

    for (final dose in doses) {
      if (dose.medicineId == medicineId) {
        await remote.deleteDose(userId, dose.id);
      }
    }

    await trackingRepository.deleteByMedicineId(medicineId);

    await medicineRepository.deleteMedicine(medicineId);
  }
}
