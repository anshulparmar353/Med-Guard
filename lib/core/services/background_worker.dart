import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';

const String medicineTask = "medicineReminderTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("🔁 BACKGROUND TASK TRIGGERED");

    if (task == medicineTask) {
      await NotificationService.showInstant(
        id: NotificationService.generateId(),
        title: "Medicine Reminder 💊",
        body: inputData?['body'] ?? "Take your medicine",
        payload: inputData?['doseId'] ?? "unknown",
      );
    }

    return Future.value(true);
  });
}