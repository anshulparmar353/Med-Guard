import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_taken.dart';
import 'package:med_guard/features/dashboard/domain/usecases/mark_dose_skipped.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';

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

  static void handle(String actionId, String doseId, BuildContext context) {
    final bloc = context.read<DashboardBloc>();

    if (actionId == 'TAKEN') {
      bloc.add(MarkDoseTakenEvent(doseId));
    }

    if (actionId == 'SKIP') {
      bloc.add(MarkDoseSkippedEvent(doseId));
    }
  }
}
