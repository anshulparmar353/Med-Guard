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

  String? error;

  @override
  void initState() {
    super.initState();
    nameCtrl.addListener(_refresh);
    ageCtrl.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
    super.dispose();
  }

  bool get isValid {
    final name = nameCtrl.text.trim();
    final age = int.tryParse(ageCtrl.text);
    return name.isNotEmpty && age != null && age > 0;
  }

  void validateAndNext() {
    final name = nameCtrl.text.trim();
    final age = int.tryParse(ageCtrl.text);

    if (name.isEmpty) {
      setState(() => error = "Name is required");
      return;
    }

    if (age == null || age <= 0) {
      setState(() => error = "Enter a valid age");
      return;
    }

    setState(() => error = null);

    widget.onNext(name, age);
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

          TextField(
            controller: nameCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Enter your name",
              filled: true,
              fillColor: Colors.white,
              errorText: error == "Name is required" ? error : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: ageCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "Enter your age",
              filled: true,
              fillColor: Colors.white,
              errorText: error == "Enter a valid age" ? error : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isValid ? validateAndNext : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Next", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
