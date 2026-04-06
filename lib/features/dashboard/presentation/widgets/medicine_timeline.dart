import 'package:flutter/material.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_log.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/time_line_tile.dart';

class MedicineTimeline extends StatelessWidget {
  const MedicineTimeline({super.key, required this.doses});

  final List<DoseLog> doses;

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? "PM" : "AM";
    return "$hour:${date.minute.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    if (doses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: const [
              Icon(Icons.medication_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                "No medicines today",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              Text(
                "You're all set 👍",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    /// ✅ FIX: use scheduledTime
    final sorted = [...doses]
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final dose = sorted[index];

        return TimeLineTile(
          time: _formatTime(dose.scheduledTime), // ✅ FIX
          name: dose.medicineName,
          status: dose.status, // ✅ FIX
          dose: dose,
        );
      },
    );
  }
}
