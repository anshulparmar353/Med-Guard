import 'package:med_guard/features/dashboard/domain/entities/dose_log.dart';

class DashboardData {
  final double adherence;
  final int taken;
  final int missed;
  final int skipped;
  final List<DoseLog> todayDoses;

  DashboardData({
    required this.adherence,
    required this.taken,
    required this.missed,
    required this.todayDoses,
    required this.skipped,
  });
}
