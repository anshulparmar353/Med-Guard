import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:med_guard/core/storage/secure_token_storage.dart';
import 'package:med_guard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:med_guard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:med_guard/features/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';
import 'package:med_guard/features/auth/domain/usecases/login_usecase.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

void init() {

  sl.registerLazySingleton<Box<Map>>(() => Hive.box<Map>('authBox'));

  sl.registerLazySingleton(() => FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureTokenStorage(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl(), secure: sl()),
  );

  // External
  sl.registerLazySingleton(() => Dio());

  // Bloc
  sl.registerFactory(() => AuthBloc(sl(), sl()));

  // Usecases
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl(), secure: s1()),
  );

  // Data sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));
}
