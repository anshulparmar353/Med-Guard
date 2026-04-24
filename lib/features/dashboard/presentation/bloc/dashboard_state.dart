import 'package:med_guard/features/dashboard/domain/entities/dose_log.dart';
import 'package:med_guard/features/dashboard/domain/entities/weekly_adherence.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double adherence;
  final int taken;
  final int missed;
  final int skipped;
  final List<DoseLog> todayDoses;
  final WeeklyAdherence weekly;

  DashboardLoaded({
    required this.adherence,
    required this.taken,
    required this.missed,
    required this.skipped,
    required this.todayDoses,
    required this.weekly,
  });
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}
