import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_guard/core/handler/remainder_action_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static NotificationActionHandler? _handler;

  static void setHandler(NotificationActionHandler handler) {
    _handler = handler;
  }

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    const androidChannel = AndroidNotificationChannel(
      'med_channel',
      'Medicine Reminder',
      description: 'Reminders to take medicines',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onActionTap,
    );
  }

  /// 🔥 HANDLE ACTION BUTTONS
  static Future<void> _onActionTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;

    final parts = payload.split('|');
    if (parts.length < 2) return;

    final notificationId = int.tryParse(parts[0]);
    final doseId = parts[1];

    if (notificationId == null) return;

    switch (response.actionId) {
      case 'TAKEN':
        if (_handler != null) {
          await _handler!.onAction(doseId, "TAKEN");
          await _notifications.cancel(id: notificationId);
        }
        break;

      case 'SKIP':
        if (_handler != null) {
          await _handler!.onAction(doseId, "SKIP");
          await _notifications.cancel(id: notificationId);
        }
        break;

      case 'SNOOZE':
        await _notifications.cancel(id: notificationId);

        await snooze(
          id: notificationId,
          title: "Reminder",
          body: "Time to take medicine",
          payload: payload,
        );
        break;

      default:
        // App opened from notification
        break;
    }
  }

  /// 🔔 Schedule notification
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String payload, // doseId
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
    );

    // If time already passed → schedule next day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel',
          'Medicine Reminder',
          importance: Importance.max,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction('TAKEN', 'Taken'),
            AndroidNotificationAction('SKIP', 'Skip'),
            AndroidNotificationAction('SNOOZE', 'Snooze'),
          ],
        ),
      ),
      payload: "$id|$payload", // 🔥 IMPORTANT FORMAT
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // daily repeat
    );
  }

  /// ⏰ Snooze notification
  static Future<void> snooze({
    required int id,
    required String title,
    required String body,
    required String payload,
    int minutes = 10,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final newTime = now.add(Duration(minutes: minutes));

    final parts = payload.split('|');
    if (parts.length < 2) return;

    final notificationId = int.tryParse(parts[0]);
    if (notificationId == null) return;

    await _notifications.zonedSchedule(
      id: notificationId,
      title: title,
      body: "$body (Snoozed)",
      scheduledDate: newTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel',
          'Medicine Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await _notifications.cancel(id: id);
  }

  /// ❌ Cancel notification
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id: id);
  }
}
