import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';

class NotificationActionHandler {
  final DashboardBloc dashboardBloc;

  NotificationActionHandler(this.dashboardBloc);

  Future<void> onAction(String doseId, String action) async {
    print("🔔 ACTION: $action → $doseId");

    if (action == "TAKEN") {
      dashboardBloc.add(MarkDoseTakenEvent(doseId));
    } else if (action == "SKIP") {
      dashboardBloc.add(MarkDoseSkippedEvent(doseId));
    }

    // 🔥 ALWAYS refresh dashboard after action
    dashboardBloc.add(LoadDashboard());
  }
}
