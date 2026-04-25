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

  late List<DateTime> _times;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.medicine.name);
    _dosageController = TextEditingController(text: widget.medicine.dosage);

    _times = List.from(widget.medicine.times);
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

  String _formatTime(DateTime t) {
    final hour = t.hour > 12 ? t.hour - 12 : t.hour;
    final period = t.hour >= 12 ? "PM" : "AM";
    return "$hour:${t.minute.toString().padLeft(2, '0')} $period";
  }

  void _update() {
    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();

    if (name.isEmpty || dosage.isEmpty || _times.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all details")));
      return;
    }

    final updatedMedicine = Medicine(
      id: widget.medicine.id,
      name: name,
      dosage: dosage,
      times: _times,
      updateAt: DateTime.now(),
      isDeleted: false,
    );

    context.read<PillboxBloc>().add(
      UpdateMedicineWithRescheduleEvent(updatedMedicine),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Medicine"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Edit Medicine",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: "Medicine Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(18),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _dosageController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: "Dosage",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(18),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Reminder Times",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, size: 28),
                  label: const Text("Add Time", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 16),

              if (_times.isEmpty)
                const Center(child: Text("No time added"))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Update Medicine",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
