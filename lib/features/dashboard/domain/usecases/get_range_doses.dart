import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class GetRangeDoses {
  final TrackingRepository repo;

  GetRangeDoses(this.repo);

  Future call(DateTime start, DateTime end) {
    return repo.getInRange(start, end);
  }
}