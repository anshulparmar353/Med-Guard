import 'package:med_guard/features/reminder/domain/repository/reminder_repo.dart';

class CancelReminder {
  final ReminderRepository repository;

  CancelReminder(this.repository);

  Future<void> call(int id) {
    return repository.cancelReminder(id);
  }
}