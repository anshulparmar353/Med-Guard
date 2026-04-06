import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class CreateDose {
  final TrackingRepository repo;

  CreateDose(this.repo);

  Future call({
    required String medicineId,
    required String medicineName,
    required DateTime scheduledTime,
  }) {
    return repo.createDose(
      medicineId: medicineId,
      medicineName: medicineName,
      scheduledTime: scheduledTime,
    );
  }
}