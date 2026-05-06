import 'package:flutter/material.dart';

class StepCaregiver extends StatefulWidget {

  final Function(String?, String?) onNext;
  final VoidCallback onBack;

  const StepCaregiver({super.key, required this.onNext, required this.onBack});

  @override
  State<StepCaregiver> createState() => _StepCaregiverState();
}

class _StepCaregiverState extends State<StepCaregiver> {
  
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  String? error;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  void handleNext() {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (name.isEmpty && phone.isEmpty) {
      widget.onNext(null, null);
      return;
    }

    if (name.isEmpty || phone.isEmpty) {
      setState(() => error = "Fill both fields or skip");
      return;
    }

    setState(() => error = null);

    widget.onNext(name, phone);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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

          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Next", style: TextStyle(color: Colors.white)),
            ),
          ),

          TextButton(
            onPressed: () => widget.onNext(null, null),
            child: const Text("Skip for now"),
          ),
        ],
      ),
    );
  }
}
