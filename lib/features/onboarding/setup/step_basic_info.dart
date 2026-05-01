import 'package:flutter/material.dart';

class StepBasic extends StatefulWidget {
  final Function(String, int) onNext;

  const StepBasic({super.key, required this.onNext});

  @override
  State<StepBasic> createState() => _StepBasicState();
}

class _StepBasicState extends State<StepBasic> {
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              "Tell us\nabout you",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "We'll personalize your reminders",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Name
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: "Enter your name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Age
            TextField(
              controller: ageCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter your age",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onNext(nameCtrl.text, int.tryParse(ageCtrl.text) ?? 0);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
