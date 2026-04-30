import 'package:med_guard/core/services/notification_service.dart';
import 'package:med_guard/features/reminder/domain/entities/reminder.dart';

class ReminderLocalDataSource {
  const ReminderLocalDataSource();

  Future<void> schedule(Reminder reminder) {
    return NotificationService.schedule(
      id: reminder.id,
      title: "Time to take medicine",
      body: reminder.medicineName,
      time: reminder.time,
      payload: reminder.payload,
    );
  }

  Future<void> cancel(int id) {
    return NotificationService.cancel(id);
  }
}
