import 'package:med_guard/features/dashboard/domain/entities/daily_adherence.dart';
import 'package:med_guard/features/dashboard/domain/entities/weekly_adherence.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';

class GetWeeklyAdherence {
  final TrackingRepository repo;

  GetWeeklyAdherence(this.repo);

  Future<WeeklyAdherence> call() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));

    final logs = await repo.getInRange(start, now);

    final Map<String, List<dynamic>> grouped = {};

    for (final log in logs) {
      final key =
          "${log.scheduledTime.year}-${log.scheduledTime.month}-${log.scheduledTime.day}";

      grouped.putIfAbsent(key, () => []).add(log);
    }

    final List<DailyAdherence> daily = grouped.values.map((dayLogs) {
      int taken = 0;
      int missed = 0;

      for (final d in dayLogs) {
        if (d.status == "taken") {
          taken++;
        } else if (d.status == "skipped") {
          continue;
        } else if (d.scheduledTime.isBefore(now)) {
          missed++;
        }
      }

      return DailyAdherence(taken, missed);
    }).toList();

    return WeeklyAdherence(days: daily);
  }
}
