import 'package:flutter/widgets.dart';
import 'package:med_guard/core/services/sync_service.dart';

class AppLifecycleSync with WidgetsBindingObserver {
  final SyncService syncService;

  String? _userId;

  AppLifecycleSync(this.syncService);

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
    }
  }

  Future<void> initialSync() async {
    if (_userId != null) {
      await syncService.sync(_userId!); // ✅ correct
    }
  }
}
