import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_guard/core/services/notification_action_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static NotificationActionHandler? _handler;

  static final Set<String> _processedActions = {};

  static void setHandler(NotificationActionHandler handler) {
    _handler = handler;
  }

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

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

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await androidPlugin?.requestExactAlarmsPermission();

    print("Exact alarm permission: $granted");
  }

  static Future<void> _onActionTap(NotificationResponse response) async {
    final payload = response.payload;

    if (payload == null) return;

    final data = jsonDecode(payload);

    final int notificationId = data['notificationId'];
    final String doseId = data['doseId'];

    print("🔔 ACTION: ${response.actionId}");
    print("📦 PAYLOAD: $payload");
    print("🧾 DOSE ID: $doseId");

    final actionKey = "$doseId-${response.actionId}";

    if (_processedActions.contains(actionKey)) return;
    _processedActions.add(actionKey);

    switch (response.actionId) {
      case 'TAKEN':
        if (_handler != null) {
          await _handler!.onAction(doseId, "TAKEN");

          await Future.delayed(const Duration(milliseconds: 100));

          await _notifications.cancel(id: notificationId);
        }
        break;

      case 'SKIP':
        if (_handler != null) {
          await _handler!.onAction(doseId, "SKIP");

          await Future.delayed(const Duration(milliseconds: 100));

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
        break;
    }
  }

  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    final scheduledDate = tz.TZDateTime.from(time, tz.local);

    print("📅 NOW: $now");
    print("⏰ SCHEDULED FOR: $scheduledDate");

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
      payload: jsonEncode({"notificationId": id, "doseId": payload}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> snooze({
    required int id,
    required String title,
    required String body,
    required String payload,
    int minutes = 10,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final newTime = now.add(Duration(minutes: minutes));

    final data = jsonDecode(payload);
    final int notificationId = data['notificationId'];

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
          actions: [
            AndroidNotificationAction(
              'TAKEN',
              'Taken',
              showsUserInterface: true,
            ),
            AndroidNotificationAction('SKIP', 'Skip', showsUserInterface: true),
            AndroidNotificationAction(
              'SNOOZE',
              'Snooze',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await _notifications.cancel(id: id);
  }

  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    print("🔔 SHOW INSTANT CALLED");

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel',
          'Medicine Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode({"notificationId": id, "doseId": payload}),
    );
  }

  static int generateId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id: id);
  }
}
