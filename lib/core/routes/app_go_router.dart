import 'package:go_router/go_router.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/features/auth/presentation/pages/forgotpassord_page.dart';
import 'package:med_guard/features/dashboard/presentation/pages/emergency_page.dart';
import 'package:med_guard/features/home/home_page.dart';
import 'package:med_guard/features/auth/presentation/pages/login_page.dart';
import 'package:med_guard/features/auth/presentation/pages/signup_page.dart';
import 'package:med_guard/features/auth/presentation/pages/splash_page.dart';
import 'package:med_guard/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:med_guard/features/home/scanner_page.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/presentation/pages/add_medicine_page.dart';
import 'package:med_guard/features/pillbox/presentation/pages/pillbox_page.dart';
import 'package:med_guard/features/pillbox/presentation/pages/update_medicine_page.dart';
import 'package:med_guard/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:med_guard/features/profile/presentation/pages/profile_page.dart';

part 'app_routes.dart';

class AppGoRouter {
  static GoRouter createRouter(AuthNotifier authNotifier) {
    return GoRouter(
      initialLocation: AppRoutes.splashScreen,

      refreshListenable: authNotifier,

      redirect: (context, state) {
        final loggedIn = authNotifier.isAuthenticated;
        final location = state.matchedLocation;

        final isLogin = location == AppRoutes.loginScreen;
        final isSignup = location == AppRoutes.signupScreen;
        final isForgot = location == AppRoutes.forgotScreen;
        final isSplash = location == AppRoutes.splashScreen;

        if (isSplash) {
          return loggedIn ? AppRoutes.dashboardScreen : AppRoutes.loginScreen;
        }

        if (!loggedIn) {
          return (isLogin || isSignup || isForgot)
              ? null
              : AppRoutes.loginScreen;
        }

        if (loggedIn && (isLogin || isSignup || isForgot)) {
          return AppRoutes.dashboardScreen;
        }

        return null;
      },

      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return HomePage(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.dashboardScreen,
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: AppRoutes.pillbox,
              builder: (context, state) => const PillboxPage(),
            ),
            GoRoute(
              path: AppRoutes.profileScreen,
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: AppRoutes.addMedicine,
              builder: (context, state) => const AddMedicinePage(),
            ),
            GoRoute(
              path: AppRoutes.scanner,
              builder: (context, state) => const ScannerPage(),
            ),
          ],
        ),

        GoRoute(
          path: AppRoutes.splashScreen,
          builder: (context, state) => SplashPage(),
        ),

        GoRoute(
          path: AppRoutes.loginScreen,
          builder: (context, state) => LoginPage(),
        ),

        GoRoute(
          path: AppRoutes.forgotScreen,
          builder: (context, state) => ForgotPasswordPage(),
        ),

        GoRoute(
          path: AppRoutes.signupScreen,
          builder: (context, state) => const SignupPage(),
        ),

        GoRoute(
          path: AppRoutes.emergencyScreen,
          builder: (context, state) => const EmergencyPage(),
        ),

        GoRoute(
          path: AppRoutes.editProfileScreen,
          builder: (context, state) => const EditProfilePage(),
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
