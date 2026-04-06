// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_log.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';

class TimeLineTile extends StatelessWidget {
  const TimeLineTile({
    super.key,
    required this.name,
    required this.time,
    required this.status,
    required this.dose,
  });

  final String time;
  final String name;
  final DoseStatus status;
  final DoseLog dose;

  @override
  Widget build(BuildContext context) {
    Color color;
    String statusText;

    switch (status) {
      case DoseStatus.taken:
        color = Colors.green;
        statusText = "Taken";
        break;
      case DoseStatus.missed:
        color = Colors.red;
        statusText = "Missed";
        break;
      case DoseStatus.pending:
        color = Colors.orange;
        statusText = "Pending";
        break;
      case DoseStatus.skipped:
        color = Colors.red;
        statusText = "Skipped";
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), // 🔥 soft background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Top Row (Name + Status Badge)
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20, // 🔥 bigger
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 🔹 Time
          Text(
            time,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),

          const SizedBox(height: 12),

          // 🔹 Action Button
          if (status == DoseStatus.pending)
            SizedBox(
              width: double.infinity,
              height: 50, // 🔥 bigger touch target
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  context.read<DashboardBloc>().add(
                    MarkDoseTakenEvent(dose.id),
                  );
                },
                child: const Text(
                  "Mark as Taken",
                  style: TextStyle(
                    fontSize: 18, // 🔥 bigger text
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
