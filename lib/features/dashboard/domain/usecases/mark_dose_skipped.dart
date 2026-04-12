import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class MarkDoseSkipped {
  final TrackingRepository repo;

  MarkDoseSkipped(this.repo);

  Future<void> call(String id) async {
    await repo.markSkipped(id);
  }
}