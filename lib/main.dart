import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/core/notification/notification_service.dart';
import 'package:med_guard/core/sync/app_lifecycle_sync.dart';
import 'package:med_guard/core/theme/app_theme.dart';
import 'package:med_guard/features/auth/data/models/user_model.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  tz.initializeTimeZones();

  await Hive.initFlutter();

  await Hive.openBox<UserModel>('authBox');
  await Hive.openBox<MedicineModel>('medicines');

  init();

  final lifecyclesync = sl<AppLifecycleSync>();

  lifecyclesync.init();

  await NotificationService.init();

  final authBloc = sl<AuthBloc>();
  final authNotifier = AuthNotifier(authBloc);
  final router = AppGoRouter.createRouter(authNotifier);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => authBloc),

        BlocProvider(create: (_) => sl<PillboxBloc>()),

        BlocProvider(create: (_) => sl<DashboardBloc>()),
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
