import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';
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
  final AuthRepository authRepository;
  final SyncService syncService;

  DashboardBloc({
    required this.getDashboardData,
    required this.getWeeklyAdherence,
    required this.markDoseTaken,
    required this.markDoseSkipped,
    required this.refreshDailyDoses,
    required this.authRepository,
    required this.syncService,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<MarkDoseTakenEvent>(_onMarkTaken);
    on<MarkDoseSkippedEvent>(_onMarkSkipped);
    on<AppResumed>(_onAppResume);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<GenerateAndLoadDashboardEvent>(_onGenerateAndLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    print("🔥 DASHBOARD RELOADING");

    emit(DashboardLoading());

    final data = await getDashboardData();
    final weekly = await getWeeklyAdherence();

    print("🔥 DATA COUNT: ${data.todayDoses.length}");

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

  Future<void> _onMarkTaken(
    MarkDoseTakenEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) return;

    try {
      await markDoseTaken(event.doseId);

      final user = await authRepository.getCurrentUser();

      if (user != null) {
        await syncService.sync(user.id);
      }

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

      final user = await authRepository.getCurrentUser();
      if (user != null) {
        await syncService.sync(user.id);
      }

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
    print("🔥 GENERATING DOSES");

    await refreshDailyDoses.call();

    print("✅ DOSES GENERATED");
  }

  Future<void> _onGenerateAndLoadDashboard(
    GenerateAndLoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    print("🔥 GENERATE + LOAD START");

    emit(DashboardLoading());

    // 🔥 STEP 1: generate doses FIRST
    await refreshDailyDoses();

    print("✅ DOSES GENERATED");

    // 🔥 STEP 2: THEN load dashboard
    final data = await getDashboardData();
    final weekly = await getWeeklyAdherence();

    print("🔥 FINAL DATA COUNT: ${data.todayDoses.length}");

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
