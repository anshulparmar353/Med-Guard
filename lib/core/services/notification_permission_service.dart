import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  static Future<void> request() async {
    final status = await Permission.notification.status;

    if (status.isGranted) return;

    if (status.isDenied) {
      final result = await Permission.notification.request();

      if (result.isPermanentlyDenied) {
        await openAppSettings();
      }
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}