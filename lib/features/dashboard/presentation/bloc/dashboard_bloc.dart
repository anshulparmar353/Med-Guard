import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_local_datasource.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';
import 'package:med_guard/features/dashboard/domain/entities/weekly_adherence.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import '../../domain/usecases/get_weekly_adherence.dart';
import '../../domain/usecases/mark_dose_taken.dart';
import '../../domain/usecases/mark_dose_skipped.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetWeeklyAdherence getWeeklyAdherence;
  final MarkDoseTaken markDoseTaken;
  final MarkDoseSkipped markDoseSkipped;
  final TrackingRepository trackingRepository;
  final TrackingLocalDataSource local;

  StreamSubscription? _hiveSub;
  StreamSubscription? _repoSub;
  WeeklyAdherence? _cachedWeekly;

  DashboardBloc({
    required this.getWeeklyAdherence,
    required this.markDoseTaken,
    required this.markDoseSkipped,
    required this.trackingRepository,
    required this.local,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<MarkDoseTakenEvent>(_onMarkTaken);
    on<MarkDoseSkippedEvent>(_onMarkSkipped);
    on<DoseStreamUpdated>(_onDoseStreamUpdated);

    _listenToHive();

    add(LoadDashboard());
  }

  void _listenToHive() {
    final box = Hive.box<DoseLogModel>('dosesBox');

    _hiveSub = box.watch().listen((event) {
      print("📡 HIVE EVENT → ${event.key}");

      final doses = box.values.map((e) => e.toEntity()).toList();

      add(DoseStreamUpdated(doses));
    });
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    if (_repoSub != null) return;

    emit(DashboardLoading());

    final box = Hive.box<DoseLogModel>('dosesBox');

    final initial = box.values.map((e) => e.toEntity()).toList();

    add(DoseStreamUpdated(initial));

    // Optional: keep repo stream ONLY if syncing from server
    _repoSub = trackingRepository.watchTodayDoses().listen((doses) {
      add(DoseStreamUpdated(doses));
    });
  }

  Future<void> _onMarkTaken(
    MarkDoseTakenEvent event,
    Emitter<DashboardState> emit,
  ) async {
    await markDoseTaken(event.doseId);
  }

  Future<void> _onMarkSkipped(
    MarkDoseSkippedEvent event,
    Emitter<DashboardState> emit,
  ) async {
    await markDoseSkipped(event.doseId);
  }

  void _onDoseStreamUpdated(
    DoseStreamUpdated event,
    Emitter<DashboardState> emit,
  ) {
    print("🔵 UI UPDATE TRIGGERED");

    final now = DateTime.now();

    final todayDoses = event.doses;

    int taken = 0;
    int skipped = 0;
    int missed = 0;
    int pending = 0;

    for (final d in todayDoses) {
      print("👉 DOSE: ${d.id} | STATUS: ${d.status}");

      if (d.status == DoseStatus.taken) {
        taken++;
      } else if (d.status == DoseStatus.skipped) {
        skipped++;
      } else if (d.status == DoseStatus.pending) {
        if (d.scheduledTime.isBefore(now)) {
          missed++;
        } else {
          pending++;
        }
      } else if (d.status == DoseStatus.missed) {
        missed++;
      }
    }

    final total = todayDoses.length;
    final adherence = total == 0 ? 0.0 : (taken / total) * 100;

    emit(
      DashboardLoaded(
        adherence: adherence,
        taken: taken,
        missed: missed,
        skipped: skipped,
        pending: pending,
        todayDoses: todayDoses,
        weekly: _cachedWeekly ?? WeeklyAdherence.empty(),
      ),
    );
  }

  @override
  Future<void> close() {
    _hiveSub?.cancel();
    _repoSub?.cancel();
    return super.close();
  }
}
