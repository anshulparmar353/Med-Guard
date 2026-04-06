import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_taken.dart';

class NotificationActionHandler {
  final MarkDoseTaken markDoseTaken;

  NotificationActionHandler(this.markDoseTaken);

  Future<void> onAction(String doseId, String action) async {
    if (action == "TAKEN") {
      await markDoseTaken(doseId);
    }

    if (action == "SKIP") {
      // you can implement skip usecase
    }
  }
}