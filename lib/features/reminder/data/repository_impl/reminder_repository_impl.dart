import 'package:med_guard/features/reminder/data/datasources/reminder_local_datasource.dart';
import 'package:med_guard/features/reminder/domain/entities/reminder.dart';
import 'package:med_guard/features/reminder/domain/repository/reminder_repo.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource local;

  ReminderRepositoryImpl(this.local);

  @override
  Future<void> scheduleReminder(Reminder reminder) {
    return local.schedule(reminder);
  }

  @override
  Future<void> cancelReminder(int id) {
    return local.cancel(id);
  }
}