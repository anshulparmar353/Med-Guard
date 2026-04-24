import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/features/dashboard/domain/usecases/refresh_daily_doses.dart';
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
  final RefreshDailyDoses refreshDailyDoses;

  DashboardBloc({
    required this.getDashboardData,
    required this.getWeeklyAdherence,
    required this.markDoseTaken,
    required this.markDoseSkipped,
    required this.refreshDailyDoses,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<MarkDoseTakenEvent>(_onMarkTaken);
    on<MarkDoseSkippedEvent>(_onMarkSkipped);
    on<AppResumed>(_onAppResume);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

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

  Future<void> _onMarkTaken(
    MarkDoseTakenEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) return;

    try {
      await markDoseTaken(event.doseId);

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
      emit(DashboardError("Failed to mark dose"));
    }
  }

  Future<void> _onAppResume(
    AppResumed event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboard());
  }

  Future<void> _onMarkSkipped(
    MarkDoseSkippedEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) return;

    try {
      await markDoseSkipped(event.doseId);

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
      emit(DashboardError("Failed to skip dose"));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

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
  }
}
