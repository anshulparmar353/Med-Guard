part of 'app_go_router.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const splashScreen = "/";
  static const loginScreen = '/login-screen';
  static const signupScreen = '/signup-screen';
  static const forgotPasswordScreen = '/forgot-password-screen';

  static const dashboardScreen = '/dashboard-screen';
  static const profileScreen = '/profile-screen';

  static const pillbox = '/pill-box';
  static const addMedicine = '/add-medicine';
  static const updateMedicine = '/update-medicine';
  static const deleteMedicine = '/delete-medicine';
}
