import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/core/services/connectivity_service.dart';
import 'package:med_guard/core/services/missed_dose_service.dart';
import 'package:med_guard/core/services/notification_action_handler.dart';
import 'package:med_guard/core/services/notification_service.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/core/sync/app_lifecycle_sync.dart';
import 'package:med_guard/core/theme/app_theme.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:med_guard/features/pillbox/presentation/pages/pillbox_page.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  tz.initializeTimeZones();
  await Hive.initFlutter();

  // Hive adapters
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
  init();

  final connectivity = getIt<ConnectivityService>();
  final syncService = getIt<SyncService>();

  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null) {
    connectivity.initConnectivitySync(connectivity, syncService, userId);
  }

  final lifecycleSync = getIt<AppLifecycleSync>();
  lifecycleSync.init();

  await NotificationService.init();

  final handler = getIt<NotificationActionHandler>();
  NotificationService.setHandler(handler);

  // NotificationService.setHandler(
  //   NotificationActionHandler(
  //     markDoseTaken: (doseId) async {
  //       await getIt<MarkDoseTaken>()(doseId);
  //     },
  //     markDoseSkipped: (doseId) async {
  //       await getIt<MarkDoseSkipped>()(doseId);
  //     },
  //   ),
  // );

  final authBloc = getIt<AuthBloc>()..add(AppStarted());
  final authNotifier = AuthNotifier(authBloc);
  final router = AppGoRouter.createRouter(authNotifier);

  Timer.periodic(const Duration(minutes: 15), (_) {
    getIt<MissedDoseService>().checkAndMarkMissed();
  });

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(
          create: (_) => getIt<DashboardBloc>(),
          child: DashboardPage(),
        ),
        BlocProvider(create: (_) => getIt<PillboxBloc>(), child: PillboxPage()),
      ],
      child: MyApp(router: router),
    ),
  );
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
