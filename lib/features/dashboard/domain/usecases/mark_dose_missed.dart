import '../repository/tracking_repo.dart';

class MarkDoseMissed {
  final TrackingRepository repo;

  MarkDoseMissed(this.repo);

  Future<void> call(String id) async {
    await repo.markMissed(id);
  }
}