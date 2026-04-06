import 'package:flutter/material.dart';
import '../../domain/entities/medicine.dart';

class MedicineTile extends StatelessWidget {
  const MedicineTile({
    super.key,
    required this.medicine,
    required this.onDelete,
    this.onTap,
  });

  final Medicine medicine;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  String _formatTime(DateTime t) {
    final hour = t.hour > 12 ? t.hour - 12 : t.hour;
    final period = t.hour >= 12 ? "PM" : "AM";
    return "$hour:${t.minute.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medication, size: 28, color: Colors.blue),
            ),

            const SizedBox(width: 16),

            // 🔹 Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 Name
                  Text(
                    medicine.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 🔹 Dosage
                  Text(
                    medicine.dosage,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),

                  const SizedBox(height: 10),

                  // 🔥 Time Chips (BIG IMPROVEMENT)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: medicine.times.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formatTime(t),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // 🔹 Delete (LESS AGGRESSIVE)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 26,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
