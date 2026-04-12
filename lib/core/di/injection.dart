import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/core/services/missed_dose_service.dart';
import 'package:med_guard/core/services/notification_service.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/core/storage/secure_token_storage.dart';
import 'package:med_guard/core/sync/app_lifecycle_sync.dart';
import 'package:med_guard/core/sync/sync_manager.dart';
import 'package:med_guard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:med_guard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:med_guard/features/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';
import 'package:med_guard/features/auth/domain/usecases/login_usecase.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_local_datasource.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_remote_datasource.dart';
import 'package:med_guard/features/dashboard/data/repository_impl/tracking_repository_impl.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/dashboard/domain/usecases/create_dose.dart';
import 'package:med_guard/features/dashboard/domain/usecases/get_range_doses.dart';
import 'package:med_guard/features/dashboard/domain/usecases/get_today_doses.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_missed.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_skipped.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_taken.dart';
import 'package:med_guard/features/pillbox/domain/usecases/replace_all_medicine.dart';
import 'package:med_guard/features/reminder/data/datasources/reminder_local_datasource.dart';
import 'package:med_guard/features/sync/domain/usecases/download_medicine.dart';
import 'package:med_guard/features/sync/domain/usecases/sync_medicine.dart';

final getIt = GetIt.instance;

void init() {
  // Sync
  getIt.registerLazySingleton(() => SyncManager());

  // applifecyclesync
  getIt.registerLazySingleton(() => AppLifecycleSync(getIt(), getIt()));

  // router
  getIt.registerLazySingleton<GoRouter>(
    () => AppGoRouter.createRouter(getIt<AuthNotifier>()),
  );

  // Notification
  getIt.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  getIt.registerLazySingleton(() => NotificationService());
  getIt.registerLazySingleton(() => ReminderLocalDataSource());

  // Auth

  getIt.registerLazySingleton<Box<Map>>(() => Hive.box<Map>('authBox'));

  getIt.registerLazySingleton(() => FlutterSecureStorage());
  getIt.registerLazySingleton(() => SecureTokenStorage(getIt()));

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt(), local: getIt()),
  );

  getIt.registerFactory(() => AuthBloc(getIt(), getIt()));

  getIt.registerLazySingleton(() => LoginUseCase(getIt()));

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt(), local: getIt()),
  );

  getIt.registerLazySingleton(() => AuthRemoteDataSource());
  getIt.registerLazySingleton(() => AuthLocalDataSource(getIt()));

  // Sync
  getIt.registerLazySingleton(
    () => SyncService(
      queue: getIt(),
      remote: getIt(),
      local: getIt(),
      trackingRemote: getIt(),
      trackingLocal: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => DownloadMedicine(getIt()));
  getIt.registerLazySingleton(() => SyncMedicines(getIt()));

  // Pillbox
  getIt.registerLazySingleton(() => ReplaceAllMedicines(getIt()));

  // dashboard
  getIt.registerLazySingleton(() => TrackingLocalDataSource(getIt()));
  getIt.registerLazySingleton(
    () => TrackingRemoteDataSource(FirebaseFirestore.instance),
  );
  getIt.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(getIt(), getIt()),
  );

  getIt.registerLazySingleton(() => CreateDose(getIt()));
  getIt.registerLazySingleton(() => MarkDoseTaken(getIt()));
  getIt.registerLazySingleton(() => MarkDoseSkipped(getIt()));
  getIt.registerLazySingleton(() => GetTodayDoses(getIt()));
  getIt.registerLazySingleton(() => GetRangeDoses(getIt()));

  // MarkDoseMissed
  getIt.registerLazySingleton(() => MarkDoseMissed(getIt()));

  getIt.registerLazySingleton(
    () => MissedDoseService(local: getIt(), markMissed: getIt()),
  );
}
