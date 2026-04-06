import 'package:med_guard/features/reminder/domain/entities/reminder.dart';
import 'package:med_guard/features/reminder/domain/repository/reminder_repo.dart';

class ScheduleReminder {
  final ReminderRepository repository;

  ScheduleReminder(this.repository);

  Future<void> call(Reminder reminder) {
    return repository.scheduleReminder(reminder);
  }
}