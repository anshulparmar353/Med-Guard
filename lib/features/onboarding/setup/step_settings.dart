import 'package:flutter/material.dart';

class StepSettings extends StatefulWidget {
  final Function(bool) onFinish;
  final VoidCallback onBack;

  const StepSettings({super.key, required this.onFinish, required this.onBack});

  @override
  State<StepSettings> createState() => _StepSettingsState();
}

class _StepSettingsState extends State<StepSettings> {
  bool emergency = false;
  bool notifications = true;
  bool sounds = true;

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
            const Icon(Icons.shield, size: 50, color: Colors.blue),

            const SizedBox(height: 10),

            const Text(
              "Emergency Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Enable quick help when needed",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            _tile(
              title: "Enable Emergency SOS",
              value: emergency,
              onChanged: (v) => setState(() => emergency = v),
            ),

            _tile(
              title: "Notifications",
              value: notifications,
              onChanged: (v) => setState(() => notifications = v),
            ),

            _tile(
              title: "Reminder Sounds",
              value: sounds,
              onChanged: (v) => setState(() => sounds = v),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onFinish(emergency),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Finish Setup",style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title),
      ),
    );
  }
}
