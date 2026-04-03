import 'package:go_router/go_router.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/features/auth/presentation/pages/home_page.dart';
import 'package:med_guard/features/auth/presentation/pages/login_page.dart';
import 'package:med_guard/features/auth/presentation/pages/splash_page.dart';

part 'app_routes.dart';

class AppGoRouter {
  static GoRouter createRouter(AuthNotifier authNotifier) {
    return GoRouter(
      initialLocation: AppRoutes.splashScreen,

      refreshListenable: authNotifier,

      redirect: (context, state) {
        final loggedIn = authNotifier.isAuthenticated;
        final isLoggingIn = state.matchedLocation == AppRoutes.loginScreen;

        if (authNotifier.isLoading) return AppRoutes.splashScreen;

        // Not logged in → force login
        if (!loggedIn && !isLoggingIn) {
          return AppRoutes.loginScreen;
        }

        // Already logged in → prevent going back to login
        if (loggedIn && isLoggingIn) {
          return AppRoutes.homeScreen;
        }

        return null;
      },

      routes: [
        /// Splash
        GoRoute(
          path: AppRoutes.splashScreen,
          builder: (context, state) => SplashPage(),
        ),

        /// Login
        GoRoute(
          path: AppRoutes.loginScreen,
          builder: (context, state) => LoginPage(),
        ),

        /// Protected Home
        GoRoute(
          path: AppRoutes.homeScreen,
          builder: (context, state) => HomePage(),
        ),
      ],
    );
  }
}
