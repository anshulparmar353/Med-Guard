import 'package:med_guard/features/dashboard/domain/entities/dose_log.dart';

abstract class DashboardEvent {}

class LoadDashboard extends DashboardEvent {}

class MarkDoseTakenEvent extends DashboardEvent {
  final String doseId;

  MarkDoseTakenEvent(this.doseId);
}

class MarkDoseSkippedEvent extends DashboardEvent {
  final String doseId;

  MarkDoseSkippedEvent(this.doseId);
}

class DoseStreamUpdated extends DashboardEvent {
  final List<DoseLog> doses;

  DoseStreamUpdated(this.doses);
}

