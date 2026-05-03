import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:med_guard/core/services/notification_service.dart';
import 'package:med_guard/features/dashboard/data/models/dose_log_model.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_skipped.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_taken.dart';
import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';

class NotificationActionHandler {
  final MarkDoseTaken markTaken;
  final MarkDoseSkipped markSkipped;

  NotificationActionHandler(this.markTaken, this.markSkipped);

  Future<void> onAction(String doseId, String action) async {
    print("🔥 ACTION: $action → $doseId");

    if (action == "TAKEN") {
      await markTaken(doseId);
    } else if (action == "SKIP") {
      await markSkipped(doseId);
    } else {
      print("⚠️ UNKNOWN ACTION: $action");
    }

    await NotificationService.cancel(
      NotificationService.generateNotificationId(doseId),
    );

    print("✅ HIVE UPDATED → UI WILL AUTO UPDATE");
  }

  @pragma('vm:entry-point')
  static Future<void> handleBackgroundAction({
    required String doseId,
    required String action,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();

    Hive.registerAdapter(DoseLogModelAdapter());
    Hive.registerAdapter(MedicineModelAdapter());
    Hive.registerAdapter(SyncItemAdapter());

    final box = await Hive.openBox<DoseLogModel>('dosesBox');

    print("🔍 BG LOOKUP: $doseId");

    final dose = box.get(doseId);

    if (dose == null) {
      print("❌ BG DOSE NOT FOUND");
      return;
    }

    final updated = dose.copyWith(
      status: action == 'TAKEN' ? 'taken' : 'skipped',
      takenAt: action == 'TAKEN' ? DateTime.now() : dose.takenAt,
      updatedAt: DateTime.now(),
    );

    await box.put(doseId, updated);

    print("✅ BG UPDATED");
  }
}
