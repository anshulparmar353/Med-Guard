import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/core/services/daily_dose_generator.dart';
import 'package:med_guard/core/services/notification_service.dart';
import 'package:med_guard/core/sync/app_lifecycle_sync.dart';
import 'package:med_guard/core/theme/app_theme.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(MedicineModelAdapter());
  Hive.registerAdapter(DoseLogModelAdapter());
  Hive.registerAdapter(SyncItemAdapter());
  Hive.registerAdapter(SyncTypeAdapter());

  await Hive.openBox<UserModel>('authBox');
  await Hive.openBox<MedicineModel>('medicines');
  await Hive.openBox<DoseLogModel>('dosesBox');
  await Hive.openBox<SyncItem>('syncQueueBox');

  await getIt.reset();
  await init();

  await NotificationService.init();

  final authBloc = getIt<AuthBloc>()..add(AppStarted());
  final authNotifier = getIt<AuthNotifier>();
  final router = getIt<GoRouter>();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: authNotifier)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider(
            create: (_) => getIt<DashboardBloc>()..add(LoadDashboard()),
          ),
          BlocProvider(create: (_) => getIt<PillboxBloc>()),
        ],
        child: MyApp(router: router),
      ),
    ),
  );

  _postAppInit();
}

void _postAppInit() {
  final lifecycleSync = getIt<AppLifecycleSync>();
  lifecycleSync.init();

  Future.microtask(() {
    unawaited(getIt<DailyDoseGenerator>().generateTodayDoses());
  });
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}