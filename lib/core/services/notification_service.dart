import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    // ✅ FIX: named parameter
    await _notifications.initialize(settings: settings);
  }

  // 🔔 Instant Notification (for testing)
  Future<void> showInstantNotification() async {
    await _notifications.show(
      id: 0, 
      title: "Medicine Reminder",
      body: "Time to take your medicine",
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel',
          'Medicine Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ⏰ Schedule Notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();

    final scheduledDate = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    await _notifications.zonedSchedule(
      id: id, 
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel',
          'Medicine Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ❌ Cancel Notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(
      id: id,
    );
  }
}
