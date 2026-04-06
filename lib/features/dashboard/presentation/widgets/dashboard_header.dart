import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    required this.totalMeds,
  });

  final String userName;
  final int totalMeds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // 🔹 Left Side (Text)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Good Morning 👋",
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),

                const SizedBox(height: 6),

                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24, // 🔥 bigger name
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  totalMeds == 0
                      ? "No medicines today"
                      : "You have $totalMeds medicines today",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),

          // 🔹 Right Side (Profile Circle)
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : "A",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
