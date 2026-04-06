import 'package:med_guard/features/reminder/domain/entities/reminder.dart';

abstract class ReminderRepository {
  Future<void> scheduleReminder(Reminder reminder);
  Future<void> cancelReminder(int id);
}
