import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_event.dart';

class UpdateMedicinePage extends StatefulWidget {
  final Medicine medicine;

  const UpdateMedicinePage({super.key, required this.medicine});

  @override
  State<UpdateMedicinePage> createState() => _UpdateMedicinePageState();
}

class _UpdateMedicinePageState extends State<UpdateMedicinePage> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;

  List<DateTime> _times = [];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.medicine.name);
    _dosageController = TextEditingController(text: widget.medicine.dosage);
    _times = [...widget.medicine.times];
  }

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

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? "PM" : "AM";
    return "$hour:${date.minute.toString().padLeft(2, '0')} $period";
  }

  void _update() {
    final updated = Medicine(
      id: widget.medicine.id, // 🔥 SAME ID
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      times: _times,
      updateAt: DateTime.now(),
      isDeleted: false, // ✅ FIXED
    );

    context.read<PillboxBloc>().add(UpdateMedicineWithRescheduleEvent(updated));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Medicine")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(onPressed: _pickTime, child: const Text("Add Time")),

            Expanded(
              child: ListView.builder(
                itemCount: _times.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    title: Text(_formatTime(_times[i])),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _times.removeAt(i);
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(onPressed: _update, child: const Text("Update")),
          ],
        ),
      ),
    );
  }
}
