import 'package:flutter/material.dart';

class StepCaregiver extends StatelessWidget {
  final Function(String?) onNext;
  final VoidCallback onBack;

  const StepCaregiver({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add, size: 40, color: Colors.green),

            const SizedBox(height: 10),

            const Text(
              "Add Emergency Contact",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "We can notify them if needed",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Your emergency contact will be notified in case of missed medications or health alerts.",
                style: TextStyle(fontSize: 12),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: "Contact Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    onNext(phoneCtrl.text.isEmpty ? null : phoneCtrl.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            TextButton(
              onPressed: () => onNext(null),
              child: const Text("Skip for now"),
            ),
          ],
        ),
      ),
    );
  }
}
