import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';

class MedicineCard extends StatelessWidget {
  final dynamic d;

  const MedicineCard({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final isTaken = d.status == DoseStatus.taken;

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
            backgroundColor: isTaken
                ? Colors.green.shade100
                : Colors.orange.shade100,
            child: Icon(
              isTaken ? Icons.check : Icons.access_time,
              color: isTaken ? Colors.green : Colors.orange,
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTaken ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isTaken ? "Taken" : "Pending",
              style: TextStyle(color: isTaken ? Colors.green : Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
