import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/pillbox/domain/usecases/get_medicines.dart';

class RefreshDailyDoses {
  final GetMedicines getMedicines;
  final TrackingRepository trackingRepo;

  RefreshDailyDoses(this.getMedicines, this.trackingRepo);

  Future<void> call() async {
    final medicines = await getMedicines();

    final now = DateTime.now();

    for (final med in medicines) {
      for (final time in med.times) {
        final scheduled = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        await trackingRepo.createDose(
          medicineId: med.id,
          medicineName: med.name,
          scheduledTime: scheduled,
        );
      }
    }
  }
}