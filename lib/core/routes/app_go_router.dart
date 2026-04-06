import 'package:go_router/go_router.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/features/auth/presentation/pages/login_page.dart';
import 'package:med_guard/features/auth/presentation/pages/splash_page.dart';
import 'package:med_guard/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/presentation/pages/add_medicine_page.dart';
import 'package:med_guard/features/pillbox/presentation/pages/pillbox_page.dart';
import 'package:med_guard/features/pillbox/presentation/pages/update_medicine_page.dart';

part 'app_routes.dart';

class AppGoRouter {
  static GoRouter createRouter(AuthNotifier authNotifier) {
    return GoRouter(
      initialLocation: AppRoutes.splashScreen,

      refreshListenable: authNotifier,

      redirect: (context, state) {
        final loggedIn = authNotifier.isAuthenticated;
        final isLoading = authNotifier.isLoading;

        final isLogin = state.matchedLocation == AppRoutes.loginScreen;
        final isSplash = state.matchedLocation == AppRoutes.splashScreen;

        final isPublicRoute = isLogin || isSplash;

        if (isLoading) {
          return isSplash ? null : AppRoutes.splashScreen;
        }

        if (!loggedIn && !isPublicRoute) {
          return AppRoutes.loginScreen;
        }

        if (loggedIn && isLogin) {
          return AppRoutes.dashboardScreen;
        }

        return null;
      },

      routes: [
        GoRoute(
          path: AppRoutes.splashScreen,
          builder: (context, state) => SplashPage(),
        ),

        GoRoute(
          path: AppRoutes.loginScreen,
          builder: (context, state) => LoginPage(),
        ),

        GoRoute(
          path: AppRoutes.dashboardScreen,
          builder: (context, state) => DashboardPage(),
        ),

        GoRoute(
          path: AppRoutes.pillbox,
          builder: (context, state) => const PillboxPage(),
        ),

        GoRoute(
          path: AppRoutes.addMedicine,
          builder: (context, state) => const AddMedicinePage(),
        ),

        GoRoute(
          path: AppRoutes.updateMedicine,
          builder: (context, state) {
            final medicine = state.extra;

            if (medicine is! Medicine) {
              return const DashboardPage();
            }

            return UpdateMedicinePage(medicine: medicine);
          },
        ),
      ],
    );
  }
}
