import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/services/notification_action_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    print("🚀 NOTIFICATION INIT");

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings: settings,

      onDidReceiveNotificationResponse: (response) async {
        print("🔥 FOREGROUND ACTION");

        print("📦 PAYLOAD RAW: ${response.payload}");

        final data = _parsePayload(response.payload);

        print("📦 PARSED DOSE ID: ${data?.doseId}");

        if (data == null) return;

        final action = response.actionId ?? "";

        print("👉 ACTION: $action → ${data.doseId}");

        final handler = getIt<NotificationActionHandler>();

        await handler.onAction(data.doseId, action);

        if (data.notificationId != null) {
          await _notifications.cancel(id: data.notificationId!);
        }
      },

      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  @pragma('vm:entry-point')
  static Future<void> notificationTapBackground(
    NotificationResponse response,
  ) async {
    print("🔥 BACKGROUND ACTION");

    final data = _parsePayload(response.payload);
    if (data == null) return;

    final action = response.actionId ?? "";

    await NotificationActionHandler.handleBackgroundAction(
      doseId: data.doseId,
      action: action,
    );

    if (data.notificationId != null) {
      await _notifications.cancel(id: data.notificationId!);
    }
  }

  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String payload,
    bool repeatDaily = false,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      0,
      0,
    );

    if (scheduled.isBefore(now)) {
      if (repeatDaily) {
        scheduled = scheduled.add(const Duration(days: 1));
      } else {
        print("⛔ Skipping past notification");
        return;
      }
    }

    print("📅 NOW: $now");
    print("⏰ TARGET: $scheduled");
    print("⏳ DIFF: ${scheduled.difference(now).inSeconds} sec");

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Med Guard',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          actions: [
            AndroidNotificationAction(
              'TAKEN',
              'Taken',
              showsUserInterface: true,
            ),
            AndroidNotificationAction('SKIP', 'Skip', showsUserInterface: true),
          ],
        ),
      ),
      payload: jsonEncode({"doseId": payload, "notificationId": id}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
    );
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id: id);
  }

  static int generateNotificationId(String doseId) {
    return doseId.hashCode & 0x7fffffff;
  }

  static _Payload? _parsePayload(String? payload) {
    if (payload == null) return null;

    try {
      final map = jsonDecode(payload);

      return _Payload(
        doseId: map['doseId'],
        notificationId: map['notificationId'],
      );
    } catch (e) {
      print("❌ Payload parse error: $e");
      return null;
    }
  }
}

class _Payload {
  final String doseId;
  final int? notificationId;

  _Payload({required this.doseId, this.notificationId});
}
