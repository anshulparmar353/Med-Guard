import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_state.dart';
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
  final _notesController = TextEditingController();

  final List<DateTime> _times = [];

  String selectedType = "Tablet";
  DateTime? startDate;
  DateTime? endDate;
  bool remindersEnabled = true;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null) return;

    final now = DateTime.now();

    final newTime = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    final exists = _times.any(
      (t) => t.hour == newTime.hour && t.minute == newTime.minute,
    );

    if (exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Time already added")));
      return;
    }

    setState(() => _times.add(newTime));
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        startDate = picked;
      } else {
        endDate = picked;
      }
    });
  }

  String _formatTime(DateTime t) {
    final hour = t.hour > 12 ? t.hour - 12 : t.hour;
    final period = t.hour >= 12 ? "PM" : "AM";
    return "$hour:${t.minute.toString().padLeft(2, '0')} $period";
  }

  void _save() {
    if (_nameController.text.isEmpty ||
        _dosageController.text.isEmpty ||
        _times.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all required fields")));
      return;
    }

    final medicine = Medicine(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      times: _times,

      updatedAt: DateTime.now(),

      isDeleted: false,
      isDaily: true,

      startDate: startDate,
      endDate: endDate,
    );

    print("ADD BUTTON CLICKED");

    context.read<PillboxBloc>().add(AddMedicineWithScheduleEvent(medicine));

    context.go(AppRoutes.dashboardScreen);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PillboxBloc, PillboxState>(
      listener: (context, state) {
        print("STATE: $state");
        if (state is PillboxLoaded && state.fromAdd) {
          print("✅ MEDICINE ADDED");

          context.go(AppRoutes.dashboardScreen);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      "Add Medicine",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _inputField("Medicine Name", _nameController, Icons.medication),

                const SizedBox(height: 12),

                _inputField("Dosage", _dosageController, Icons.local_hospital),

                const SizedBox(height: 20),

                const Text("Medicine Type *"),
                const SizedBox(height: 10),
                _typeSelector(),

                const SizedBox(height: 20),

                const Text("Medication Times *"),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: _fakeInput("Add Time", Icons.access_time)),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.add, size: 30),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: _times
                      .map(
                        (t) => Chip(
                          label: Text(_formatTime(t)),
                          onDeleted: () {
                            setState(() => _times.remove(t));
                          },
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 20),

                _dateField("Start Date", startDate, true),
                const SizedBox(height: 10),
                _dateField("End Date (Optional)", endDate, false),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Enable Reminders"),
                      Switch(
                        value: remindersEnabled,
                        onChanged: (v) => setState(() => remindersEnabled = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Notes (Optional)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Save Medicine",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _fakeInput(String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Text(hint, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _dateField(String title, DateTime? date, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(isStart),
      child: _fakeInput(
        date == null ? title : DateFormat('dd MMM yy').format(date),
        Icons.calendar_today,
      ),
    );
  }

  Widget _typeSelector() {
    final types = ["Tablet", "Capsule", "Syrup", "Injection"];

    return Column(
      children: types.map((type) {
        final selected = type == selectedType;

        return GestureDetector(
          onTap: () => setState(() => selectedType = type),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? Colors.blue.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.medication,
                  color: selected ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(type),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
