import 'package:med_guard/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class GetDashboardData {
  final TrackingRepository repo;

  GetDashboardData(this.repo);

  Future<DashboardData> call() async {
    final today = await repo.getTodayDoses();

    final now = DateTime.now();

    int taken = 0;
    int missed = 0;
    int skipped = 0;

    for (final d in today) {
      if (d.status == DoseStatus.taken) {
        taken++;
      } else if (d.status == DoseStatus.skipped) {
        skipped++;
      } else if (d.scheduledTime.isBefore(now)) {
        missed++;
      }
    }

    final total = taken + missed;
    final adherence = total == 0 ? 0.0 : taken / total;

    return DashboardData(
      taken: taken,
      missed: missed,
      skipped: skipped,
      adherence: adherence,
      todayDoses: today,
    );
  }
}
