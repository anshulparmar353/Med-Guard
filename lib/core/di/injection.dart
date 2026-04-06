import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/core/notification/notification_service.dart';
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
import 'package:med_guard/features/dashboard/data/repository_impl/tracking_repository_impl.dart';
import 'package:med_guard/features/dashboard/domain/repository/tracking_repo.dart';
import 'package:med_guard/features/dashboard/domain/usecases/create_dose.dart';
import 'package:med_guard/features/dashboard/domain/usecases/get_range_doses.dart';
import 'package:med_guard/features/dashboard/domain/usecases/get_today_doses.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_skipped.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_taken.dart';
import 'package:med_guard/features/pillbox/domain/usecases/replace_all_medicine.dart';
import 'package:med_guard/features/reminder/data/datasources/reminder_local_datasource.dart';
import 'package:med_guard/features/sync/domain/usecases/download_medicine.dart';
import 'package:med_guard/features/sync/domain/usecases/sync_medicine.dart';

final sl = GetIt.instance;

void init() {
  // Sync
  sl.registerLazySingleton(() => SyncManager());

  // applifecyclesync
  sl.registerLazySingleton(() => AppLifecycleSync(sl()));

  //router
  sl.registerLazySingleton<GoRouter>(
    () => AppGoRouter.createRouter(sl<AuthNotifier>()),
  );

  ///Notification
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => ReminderLocalDataSource());

  /// Auth

  sl.registerLazySingleton<Box<Map>>(() => Hive.box<Map>('authBox'));

  sl.registerLazySingleton(() => FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureTokenStorage(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl()),
  );

  sl.registerFactory(() => AuthBloc(sl(), sl()));

  sl.registerLazySingleton(() => LoginUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl()),
  );

  sl.registerLazySingleton(() => AuthRemoteDataSource());
  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));

  // 🔹 Sync
  sl.registerLazySingleton(() => DownloadMedicine(sl()));
  sl.registerLazySingleton(() => SyncMedicines(sl()));

  // 🔹 Pillbox
  sl.registerLazySingleton(() => ReplaceAllMedicines(sl()));

  // dashboard
  sl.registerLazySingleton(() => TrackingLocalDataSource(sl()));
  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => CreateDose(sl()));
  sl.registerLazySingleton(() => MarkDoseTaken(sl()));
  sl.registerLazySingleton(() => MarkDoseSkipped(sl()));
  sl.registerLazySingleton(() => GetTodayDoses(sl()));
  sl.registerLazySingleton(() => GetRangeDoses(sl()));
}
