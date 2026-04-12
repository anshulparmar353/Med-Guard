import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class MarkDoseTaken {
  final TrackingRepository repo;

  MarkDoseTaken(this.repo);

  Future<void> call(String id) async {
    await repo.markTaken(id);
  }
}