import 'package:med_guard/features/dashboard/data/datasources/tracking_remote_datasource.dart';
import 'package:med_guard/features/dashboard/data/datasources/tracking_local_datasource.dart';
import 'package:med_guard/features/sync/data/datasources/sync_queue_local_DB.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';

class MissedDoseService {
  final TrackingLocalDataSource local;
  final TrackingRemoteDataSource remote; 
  final SyncQueueLocalDataSource queue;

  MissedDoseService(this.local, this.remote, this.queue);

  Future<void> checkAndMarkMissed() async {
    final now = DateTime.now();

    final doses = await local.getAllDoses();

    for (final d in doses) {
      final isPast = d.scheduledTime.isBefore(now);
      final isPending = d.status == "pending";

      if (isPast && isPending) {
        final updated = d.copyWith(status: "missed", updatedAt: DateTime.now());

        await local.update(updated);

        await queue.add(
          SyncItem(
            id: updated.id,
            type: SyncType.updateDose,
            data: updated.toLocalJson(),
            createdAt: DateTime.now(),
          ),
        );

        print("❌ MISSED DOSE MARKED: ${d.id}");
      }
    }
  }
}
