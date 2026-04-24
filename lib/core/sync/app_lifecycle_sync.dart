import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:med_guard/core/services/missed_dose_service.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';

class AppLifecycleSync with WidgetsBindingObserver {
  final SyncService syncService;
  final MissedDoseService missedDoseService;
  final DashboardBloc dashboardBloc;

  String? _userId;

  AppLifecycleSync(
    this.syncService,
    this.missedDoseService,
    this.dashboardBloc,
  );

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void setUser(String userId) {
    _userId = userId;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _userId != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      dashboardBloc.add(AppResumed());

      if (userId != null) {
        syncService.sync(userId);
      }
      missedDoseService.checkAndMarkMissed();
    }
  }

  Future<void> initialSync() async {
    if (_userId != null) {
      await syncService.sync(_userId!);
    }
  }
}
