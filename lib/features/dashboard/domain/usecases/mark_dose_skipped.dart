import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class MarkDoseSkipped {
  final TrackingRepository repo;

  MarkDoseSkipped(this.repo);

  Future call(String id) => repo.markSkipped(id);
}