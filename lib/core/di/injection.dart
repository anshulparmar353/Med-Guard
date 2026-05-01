import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/core/services/connectivity_service.dart';
import 'package:med_guard/core/services/daily_dose_generator.dart';
import 'package:med_guard/core/services/missed_dose_service.dart';
import 'package:med_guard/core/services/notification_action_handler.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/core/storage/secure_token_storage.dart';
import 'package:med_guard/core/sync/app_lifecycle_sync.dart';
import 'package:med_guard/core/sync/sync_manager.dart';

import 'package:med_guard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:med_guard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';
import 'package:med_guard/features/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';
import 'package:med_guard/features/auth/domain/usecases/login_usecase.dart';
import 'package:med_guard/features/auth/domain/usecases/logout_usecase.dart';
import 'package:med_guard/features/auth/domain/usecases/signup_usecase.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:med_guard/features/dashboard/data/datasources/tracking_local_datasource.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_remote_datasource.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/dashboard/data/repository_impl/tracking_repository_impl.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/dashboard/domain/usecases/get_dashboard_data.dart';
import 'package:med_guard/features/dashboard/domain/usecases/get_weekly_adherence.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_missed.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_skipped.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_taken.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'package:med_guard/features/pillbox/data/datasources/medicine_local_datasource.dart';
import 'package:med_guard/features/pillbox/data/datasources/medicine_remote_datasource.dart';
import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';
import 'package:med_guard/features/pillbox/data/repository_impl/medicine_repository_impl.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/pillbox/domain/usecases/add_medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/add_medicine_with_schedule.dart';
import 'package:med_guard/features/pillbox/domain/usecases/delete_medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/delete_medicine_with_cleanup.dart';
import 'package:med_guard/features/pillbox/domain/usecases/get_medicines.dart';
import 'package:med_guard/features/pillbox/domain/usecases/replace_all_medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/update_medicine_with_reschedule.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:med_guard/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:med_guard/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:med_guard/features/profile/data/models/profile_user_model.dart';
import 'package:med_guard/features/profile/data/repository_impl/profile_user_repo_impl.dart';
import 'package:med_guard/features/profile/domain/repository/profile_user_repository.dart';
import 'package:med_guard/features/profile/domain/usecases/clear_profile_usecase.dart';
import 'package:med_guard/features/profile/domain/usecases/get_profile_user_usecase.dart';
import 'package:med_guard/features/profile/domain/usecases/save_profile_user_usecase.dart';
import 'package:med_guard/features/profile/domain/usecases/watch_profile_user_usecase.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_bloc.dart';

import 'package:med_guard/features/reminder/data/datasources/reminder_local_datasource.dart';
import 'package:med_guard/features/reminder/data/repository_impl/reminder_repository_impl.dart';
import 'package:med_guard/features/reminder/domain/repository/reminder_repo.dart';
import 'package:med_guard/features/reminder/domain/usecases/cancel_reminder.dart';
import 'package:med_guard/features/reminder/domain/usecases/schedule_reminder.dart';
import 'package:med_guard/features/sync/data/datasources/firebase_datasource.dart';

import 'package:med_guard/features/sync/data/datasources/sync_queue_local_DB.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';
import 'package:med_guard/features/sync/data/repository_impl/sync_repository_impl.dart';
import 'package:med_guard/features/sync/domain/repository/sync_repository.dart';
import 'package:med_guard/features/sync/domain/usecases/download_medicine.dart';
import 'package:med_guard/features/sync/domain/usecases/sync_medicine.dart';
import 'package:med_guard/utils/auth_helper.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Firebase
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  getIt.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  getIt.registerLazySingleton(() => FlutterSecureStorage());

  getIt.registerLazySingleton<FirebaseDatasource>(() => FirebaseDatasource());

  // Auth Helper
  getIt.registerLazySingleton(() => AuthHelper(getIt()));

  // ================= CORE =================

  getIt.registerLazySingleton(() => SyncManager());

  getIt.registerLazySingleton(() => ReminderLocalDataSource());

  getIt.registerLazySingleton(() => SecureTokenStorage(getIt()));

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(getIt<Connectivity>()),
  );
  // ================= HIVE BOXES =================

  getIt.registerLazySingleton<Box<UserModel>>(
    () => Hive.box<UserModel>('authBox'),
  );

  getIt.registerLazySingleton<Box<MedicineModel>>(
    () => Hive.box<MedicineModel>('medicines'),
  );

  getIt.registerLazySingleton<Box<SyncItem>>(
    () => Hive.box<SyncItem>('syncQueueBox'),
  );

  getIt.registerLazySingleton<Box<DoseLogModel>>(
    () => Hive.box<DoseLogModel>('dosesBox'),
  );

  getIt.registerLazySingleton<Box<ProfileUserModel>>(
    () => Hive.box<ProfileUserModel>('profileBox'),
  );

  // ================= AUTH =================

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(getIt<Box<UserModel>>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      local: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignupUsecase>(
    () => SignupUsecase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      getIt<LoginUseCase>(),
      getIt<SignupUsecase>(),
      getIt<LogoutUseCase>(),
      getIt<AuthRepository>(),
      getIt<SyncService>(),
      getIt<ConnectivityService>(),
      getIt<MedicineRepository>(),
    ),
  );

  getIt.registerLazySingleton<AuthNotifier>(
    () => AuthNotifier(getIt<AuthBloc>()),
  );

  getIt.registerLazySingleton<GoRouter>(
    () => AppGoRouter.createRouter(getIt<AuthNotifier>()),
  );

  // ================= SYNC =================

  getIt.registerLazySingleton<SyncQueueLocalDataSource>(
    () => SyncQueueLocalDataSource(getIt<Box<SyncItem>>()),
  );

  getIt.registerLazySingleton(
    () => MedicineRemoteDataSource(FirebaseFirestore.instance),
  );

  getIt.registerLazySingleton(
    () => MedicineLocalDataSource(getIt<Box<MedicineModel>>()),
  );

  getIt.registerLazySingleton(
    () => TrackingRemoteDataSource(FirebaseFirestore.instance),
  );

  getIt.registerLazySingleton<TrackingLocalDataSource>(
    () => TrackingLocalDataSource(getIt<Box<DoseLogModel>>()),
  );

  getIt.registerLazySingleton<DailyDoseGenerator>(
    () => DailyDoseGenerator(medicineLocal: getIt(), doseLocal: getIt()),
  );

  getIt.registerLazySingleton(
    () => SyncService(
      queue: getIt<SyncQueueLocalDataSource>(),
      remote: getIt<MedicineRemoteDataSource>(),
      local: getIt<MedicineLocalDataSource>(),
      trackingRemote: getIt<TrackingRemoteDataSource>(),
      trackingLocal: getIt<TrackingLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => AppLifecycleSync(getIt(), getIt(), getIt(), getIt()),
  );

  getIt.registerLazySingleton(() => SyncMedicines(getIt()));
  getIt.registerLazySingleton(() => DownloadMedicine(getIt()));

  // ================= PILLBOX =================

  getIt.registerLazySingleton(() => ReplaceAllMedicines(getIt()));

  getIt.registerLazySingleton<GetMedicines>(() => GetMedicines(getIt()));

  getIt.registerLazySingleton<AddMedicine>(() => AddMedicine(getIt()));

  getIt.registerLazySingleton<UpdateMedicineWithReschedule>(
    () => UpdateMedicineWithReschedule(
      medicineRepository: getIt(),
      cancelReminder: getIt(),
      scheduleReminder: getIt(),
    ),
  );

  getIt.registerLazySingleton<DeleteMedicineWithCleanup>(
    () => DeleteMedicineWithCleanup(
      medicineRepository: getIt(),
      cancelReminder: getIt(),
      trackingRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton<AddMedicineWithSchedule>(
    () => AddMedicineWithSchedule(getIt(), getIt()),
  );

  getIt.registerLazySingleton<DeleteMedicine>(() => DeleteMedicine(getIt()));

  getIt.registerLazySingleton<MedicineRepository>(
    () => MedicineRepositoryImpl(
      local: getIt<MedicineLocalDataSource>(),
      queue: getIt<SyncQueueLocalDataSource>(),
      syncService: getIt<SyncService>(),
    ),
  );

  getIt.registerFactory(
    () => PillboxBloc(
      getMedicines: getIt(),
      addMedicineWithSchedule: getIt(),
      deleteMedicineWithCleanup: getIt(),
      updateMedicineWithReschedule: getIt(),
      syncMedicines: getIt(),
      syncManager: getIt(),
    ),
  );

  // ================= Remainder =================

  getIt.registerLazySingleton<ScheduleReminder>(
    () => ScheduleReminder(getIt()),
  );

  getIt.registerLazySingleton<CancelReminder>(() => CancelReminder(getIt()));

  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(getIt()),
  );

  // ================= DASHBOARD =================

  getIt.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      getIt<TrackingLocalDataSource>(),
      getIt<SyncQueueLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(() => GetDashboardData(getIt()));
  getIt.registerLazySingleton(() => MarkDoseTaken(getIt()));
  getIt.registerLazySingleton(() => MarkDoseSkipped(getIt()));
  getIt.registerLazySingleton(() => MarkDoseMissed(getIt()));
  getIt.registerLazySingleton(() => GetWeeklyAdherence(getIt()));

  getIt.registerLazySingleton(
    () => MissedDoseService(
      getIt<TrackingLocalDataSource>(),
      getIt<TrackingRemoteDataSource>(),
      getIt<SyncQueueLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton(
    () => DashboardBloc(
      getWeeklyAdherence: getIt(),
      markDoseTaken: getIt(),
      markDoseSkipped: getIt(),
      trackingRepository: getIt(),
      local: getIt(),
    ),
  );

  // ================= PILLBOX =================

  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSource(Hive.box<ProfileUserModel>('profileBox')),
  );

  getIt.registerLazySingleton(() => ProfileRemoteDataSource(getIt()));

  getIt.registerLazySingleton<ProfileUserRepository>(
    () => ProfileRepositoryImpl(getIt(), getIt()),
  );

  getIt.registerLazySingleton(() => GetProfileUserUseCase(getIt()));
  getIt.registerLazySingleton(() => SaveProfileUserUseCase(getIt()));
  getIt.registerLazySingleton(() => WatchProfileUserUseCase(getIt()));
  getIt.registerLazySingleton(() => ClearProfileUseCase(getIt()));

  getIt.registerFactoryParam<ProfileBloc, String, void>(
    (userId, _) => ProfileBloc(getIt(), getIt(), getIt(), userId),
  );

  // ================= NOTIFICATION =================

  getIt.registerLazySingleton(
    () => NotificationActionHandler(
      getIt<MarkDoseTaken>(),
      getIt<MarkDoseSkipped>(),
    ),
  );
}
