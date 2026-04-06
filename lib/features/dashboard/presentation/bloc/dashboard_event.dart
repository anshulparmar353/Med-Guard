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

class RefreshDashboard extends DashboardEvent {}