import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_event.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  final List<DateTime> _times = [];

  // 🔹 Pick Time
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    final now = DateTime.now();

    final time = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    setState(() {
      _times.add(time);
      _times.sort((a, b) => a.compareTo(b));
    });
  }

  String _formatTime(DateTime t) {
    final hour = t.hour > 12 ? t.hour - 12 : t.hour;
    final period = t.hour >= 12 ? "PM" : "AM";
    return "$hour:${t.minute.toString().padLeft(2, '0')} $period";
  }

  void _save() {
    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();

    if (name.isEmpty || dosage.isEmpty || _times.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final medicine = Medicine(
      id: const Uuid().v4(),
      name: name,
      dosage: dosage,
      times: _times,
      updateAt: DateTime.now(),
      isDeleted: false,
    );

    context.read<PillboxBloc>().add(AddMedicineWithScheduleEvent(medicine));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Medicine")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔹 Name
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  labelText: "Medicine Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Dosage
              TextField(
                controller: _dosageController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  labelText: "Dosage (e.g. 1 tablet)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Add Time Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: const Text("Add Time", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Time List
              Expanded(
                child: _times.isEmpty
                    ? const Center(
                        child: Text(
                          "No time added",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _times.length,
                        itemBuilder: (_, i) {
                          final t = _times[i];

                          return Card(
                            child: ListTile(
                              title: Text(_formatTime(t)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _times.removeAt(i);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // 🔹 Save Button
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text(
                    "Save Medicine",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
