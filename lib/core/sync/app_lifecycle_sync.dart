import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/services/daily_dose_generator.dart';
import 'package:med_guard/core/services/missed_dose_service.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';

class AppLifecycleSync with WidgetsBindingObserver {
  final SyncService syncService;
  final MissedDoseService missedDoseService;
  final DailyDoseGenerator generator;
  final DashboardBloc dashboardBloc;

  String? _userId;

  bool _isProcessing = false;

  AppLifecycleSync(
    this.syncService,
    this.missedDoseService,
    this.generator,
    this.dashboardBloc,
  );

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void setUser(String userId) {
    _userId = userId;
  }

  Future<void> syncFromBackground() async {
    final box = await Hive.openBox('app_flags');
    final needsRefresh = box.get('needs_refresh', defaultValue: false);

    if (!needsRefresh) return;

    print("⚡ SYNCING FROM BACKGROUND");

    final doseBox = Hive.box<DoseLogModel>('dosesBox');

    final doses = doseBox.values.map((e) => e.toEntity()).toList();

    getIt<DashboardBloc>().add(DoseStreamUpdated(doses));

    await box.put('needs_refresh', false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _userId != null) {
      syncFromBackground();

      if (_isProcessing) return;

      _isProcessing = true;

      final userId = FirebaseAuth.instance.currentUser?.uid;

      print("🔄 APP RESUMED → REFRESH DASHBOARD");

      Future.microtask(() async {
        try {
          await _runDailyGeneratorOnce();

          await missedDoseService.checkAndMarkMissed();

          if (userId != null) {
            syncService.sync(userId);
          }
        } catch (e) {
          print("❌ Lifecycle error: $e");
        } finally {
          _isProcessing = false;
        }
      });
    }
  }

  Future<void> _runDailyGeneratorOnce() async {
    final box = await Hive.openBox('app_meta');

    final todayKey = _todayKey();

    final lastRun = box.get('last_generator_run');

    if (lastRun == todayKey) {
      print("⚠️ Generator already ran today");
      return;
    }

    print("🚀 Running Daily Dose Generator");

    await generator.generateTodayDoses();

    await box.put('last_generator_run', todayKey);
  }

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> initialSync() async {
    if (_userId != null) {
      syncService.sync(_userId!);
    }
  }
}
