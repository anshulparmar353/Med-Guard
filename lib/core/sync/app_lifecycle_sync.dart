import 'package:flutter/widgets.dart';
import 'package:med_guard/core/services/missed_dose_service.dart';
import 'package:med_guard/core/services/sync_service.dart';

class AppLifecycleSync with WidgetsBindingObserver {
  final SyncService syncService;
  final MissedDoseService missedDoseService;

  String? _userId;

  AppLifecycleSync(this.syncService, this.missedDoseService);

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void setUser(String userId) {
    _userId = userId;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _userId != null) {
      syncService.sync(_userId!); // ✅ correct
      missedDoseService.checkAndMarkMissed();
    }
  }

  Future<void> initialSync() async {
    if (_userId != null) {
      await syncService.sync(_userId!); // ✅ correct
    }
  }
}
