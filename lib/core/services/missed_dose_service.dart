import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_missed.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_local_datasource.dart';

class MissedDoseService {
  final TrackingLocalDataSource local;
  final MarkDoseMissed markMissed;

  MissedDoseService({
    required this.local,
    required this.markMissed,
  });

  static const Duration gracePeriod = Duration(minutes: 30);

  Future<void> checkAndMarkMissed() async {
    final now = DateTime.now();

    final doses = await local.getAllDoses();

    for (final dose in doses) {
      if (dose.status != DoseStatus.pending.name) continue;

      final deadline = dose.scheduledTime.add(gracePeriod);

      if (now.isAfter(deadline)) {
        await markMissed(dose.id);
      }
    }
  }
}