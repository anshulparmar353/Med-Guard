import 'package:med_guard/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class GetDashboardData {
  final TrackingRepository repo;

  GetDashboardData(this.repo);

  Future<DashboardData> call() async {
    
    final today = await repo.getTodayDoses();

    int taken = 0;
    int missed = 0;
    int skipped = 0; 

    final now = DateTime.now();

    for (final d in today) {
      if (d.status.name == "taken") {
        taken++;
      } else if (d.status.name == "skipped") {
        skipped++; // 
      } else if (d.scheduledTime.isBefore(now)) {
        missed++;
      }
    }

    final adherence = (taken + missed) == 0 ? 0.0 : taken / (taken + missed);

    return DashboardData(
      taken: taken,
      missed: missed,
      skipped: skipped, 
      adherence: adherence,
      todayDoses: today,
    );
  }
}
