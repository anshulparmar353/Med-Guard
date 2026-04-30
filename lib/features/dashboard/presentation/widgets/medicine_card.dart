import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_log.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';

class MedicineCard extends StatelessWidget {
  final DoseLog d;

  const MedicineCard({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final status = d.status;

    Color bgColor;
    IconData icon;
    Color iconColor;
    String label;

    switch (status) {
      case DoseStatus.taken:
        bgColor = Colors.green.shade100;
        icon = Icons.check;
        iconColor = Colors.green;
        label = "Taken";
        break;

      case DoseStatus.skipped:
        bgColor = Colors.grey.shade300;
        icon = Icons.close;
        iconColor = Colors.grey;
        label = "Skipped";
        break;

      case DoseStatus.missed:
        bgColor = Colors.red.shade100;
        icon = Icons.warning;
        iconColor = Colors.red;
        label = "Missed";
        break;

      default:
        bgColor = Colors.orange.shade100;
        icon = Icons.access_time;
        iconColor = Colors.orange;
        label = "Pending";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.medicineName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('hh:mm a').format(d.scheduledTime),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          if (status == DoseStatus.pending)
            Row(
              children: [
                _smallButton(
                  icon: Icons.check,
                  color: Colors.green,
                  onTap: () {
                    print("UI taken PASSING ID: ${d.id}");
                    context.read<DashboardBloc>().add(MarkDoseTakenEvent(d.id));
                  },
                ),
                const SizedBox(width: 6),
                _smallButton(
                  icon: Icons.close,
                  color: Colors.grey,
                  onTap: () {
                    print("UI skipped PASSING ID: ${d.id}");
                    context.read<DashboardBloc>().add(
                      MarkDoseSkippedEvent(d.id),
                    );
                  },
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(color: iconColor, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _smallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 25, color: color),
      ),
    );
  }
}
