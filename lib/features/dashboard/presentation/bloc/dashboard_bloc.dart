import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_data.dart';
import '../../domain/usecases/get_weekly_adherence.dart';
import '../../domain/usecases/mark_dose_taken.dart';
import '../../domain/usecases/mark_dose_skipped.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;
  final GetWeeklyAdherence getWeeklyAdherence;
  final MarkDoseTaken markDoseTaken;
  final MarkDoseSkipped markDoseSkipped;

  DashboardBloc({
    required this.getDashboardData,
    required this.getWeeklyAdherence,
    required this.markDoseTaken,
    required this.markDoseSkipped,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<MarkDoseTakenEvent>(_onMarkTaken);
    on<MarkDoseSkippedEvent>(_onMarkSkipped);
  }

  /// 🔹 Load Dashboard (Initial / Refresh)
  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Avoid flicker if already loaded
    if (state is! DashboardLoaded) {
      emit(DashboardLoading());
    }

    try {
      final data = await getDashboardData();
      final weekly = await getWeeklyAdherence();

      emit(
        DashboardLoaded(
          adherence: data.adherence,
          taken: data.taken,
          missed: data.missed,
          skipped: data.skipped,
          todayDoses: data.todayDoses,
          weekly: weekly,
        ),
      );
    } catch (e) {
      emit(DashboardError("Failed to load dashboard"));
    }
  }

  /// 🔹 Mark Dose as Taken (Optimized Update)
  Future<void> _onMarkTaken(
    MarkDoseTakenEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) return;

    final current = state as DashboardLoaded;

    try {
      await markDoseTaken(event.doseId);

      final updated = await getDashboardData();

      emit(
        DashboardLoaded(
          adherence: updated.adherence,
          taken: updated.taken,
          missed: updated.missed,
          skipped: updated.skipped,
          todayDoses: updated.todayDoses,
          weekly: current.weekly, // reuse weekly
        ),
      );
    } catch (e) {
      emit(DashboardError("Failed to mark dose"));
    }
  }

  /// 🔹 Mark Dose as Skipped (Optimized Update)
  Future<void> _onMarkSkipped(
    MarkDoseSkippedEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) return;

    final current = state as DashboardLoaded;

    try {
      await markDoseSkipped(event.doseId);

      final updated = await getDashboardData();

      emit(
        DashboardLoaded(
          adherence: updated.adherence,
          taken: updated.taken,
          missed: updated.missed,
          skipped: updated.skipped,
          todayDoses: updated.todayDoses,
          weekly: current.weekly, // reuse weekly
        ),
      );
    } catch (e) {
      emit(DashboardError("Failed to skip dose"));
    }
  }
}