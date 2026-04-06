// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.taken, required this.missed});

  final int taken;
  final int missed;

  @override
  Widget build(BuildContext context) {
    final int total = taken + missed;
    final bool isGood = missed == 0;

    final double progress = total == 0 ? 0 : taken / total;

    final String title = total == 0
        ? "No medicines today"
        : isGood
        ? "Great job! 👍"
        : "Keep going";

    final String subtitle = total == 0
        ? "You're all set for today"
        : isGood
        ? "All medicines taken"
        : "You took $taken of $total medicines";

    final Color bgColor = isGood ? Colors.green.shade50 : Colors.red.shade50;

    final Color accentColor = isGood ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Top Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isGood ? Icons.check : Icons.warning,
                  size: 30,
                  color: accentColor,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20, // 🔥 bigger
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🔹 Progress Section
          if (total > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Progress", style: TextStyle(fontSize: 16)),
                Text(
                  "${(progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10, // 🔥 thicker
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
