import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class GetTodayDoses {
  final TrackingRepository repo;

  GetTodayDoses(this.repo);

  Future call() => repo.getTodayDoses();
}