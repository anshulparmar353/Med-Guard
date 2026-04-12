import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_taken.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_skipped.dart';

class NotificationActionHandler {
  final MarkDoseTaken markDoseTaken;
  final MarkDoseSkipped markDoseSkipped;

  NotificationActionHandler({
    required this.markDoseTaken,
    required this.markDoseSkipped,
  });

  Future<void> onAction(String doseId, String action) async {
    if (action == "TAKEN") {
      await markDoseTaken(doseId);
    } else if (action == "SKIP") {
      await markDoseSkipped(doseId);
    }
  }
}