import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(31, 128, 120, 120),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Good Evening,", style: TextStyle(color: Colors.black54)),
                SizedBox(height: 4),
                Text(
                  "Anshul",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Icon(Icons.notifications_none),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text("A", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
