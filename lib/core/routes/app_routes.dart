part of 'app_go_router.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const splashScreen = "/";
  static const loginScreen = '/login-screen';
  static const signupScreen = '/signup-screen';
  static const forgotScreen = '/forgot-password-screen';

  static const intro = '/intro';
  static const setup = '/setup';

  static const homeScreen = '/home-screen';
  static const dashboardScreen = '/dashboard-screen';
  static const pillbox = '/pill-box';
  static const addMedicine = '/add-medicine';
  static const scanner = '/scanner';

  static const profileScreen = '/profile-screen';
  static const editProfileScreen = '/edit-profile-screen';

  static const updateMedicine = '/update-medicine';
  static const deleteMedicine = '/delete-medicine';

  static const emergencyScreen = '/emergency-screen';
}
