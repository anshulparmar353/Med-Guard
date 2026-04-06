import 'package:flutter/material.dart';
import '../../domain/entities/weekly_adherence.dart';

class WeeklyAdherenceCard extends StatelessWidget {
  const WeeklyAdherenceCard({super.key, required this.data});

  final WeeklyAdherence data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This Week",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Text("✔ Taken: ${data.taken}", style: const TextStyle(fontSize: 16)),
          Text("❌ Missed: ${data.missed}", style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 10),

          Text(
            "Adherence: ${data.percentage.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}