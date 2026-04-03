import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<Map>('authBox');

  init();

  final authBloc = sl<AuthBloc>();
  final authNotifier = AuthNotifier(authBloc);

  final router = AppGoRouter.createRouter(authNotifier);

  runApp(
    BlocProvider.value(
      value: authBloc..add(CheckAuthStatus()),
      child: MyApp(router),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp(this.router, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
