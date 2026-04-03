part  of 'app_go_router.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const splashScreen = "/";
  static const loginScreen = '/login-screen';
  static const signupScreen = '/signup-screen';
  static const forgotPasswordScreen = '/forgot-password-screen';

  static const homeScreen = '/home-screen';
  static const dashboardScreen = '/dashboard-screen';
  static const profileScreen = '/profile-screen';
}
