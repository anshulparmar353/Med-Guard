import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_event.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_state.dart';

class PillboxPage extends StatefulWidget {
  const PillboxPage({super.key});

  @override
  State<PillboxPage> createState() => _PillboxPageState();
}

class _PillboxPageState extends State<PillboxPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PillboxBloc>().add(LoadMedicines());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Medicines"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          context.push(AppRoutes.addMedicine);
        },
        child: const Icon(Icons.add),
      ),

      body: BlocBuilder<PillboxBloc, PillboxState>(
        builder: (context, state) {
          print("PILLBOX STATE: $state");

          if (state is PillboxLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PillboxError) {
            return Center(child: Text(state.message));
          }

          if (state is PillboxLoaded) {
            if (state.medicines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No medicines added",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.addMedicine);
                      },
                      child: const Text("Add Medicine"),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.medicines.length,
              itemBuilder: (_, i) {
                final med = state.medicines[i];
                return _medicineCard(context, med);
              },
            );
          }

          return const Center(child: Text("Loading..."));
        },
      ),
    );
  }

  Widget _medicineCard(BuildContext context, Medicine med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: Colors.blue),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dosages: ${med.dosage}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "edit") {
                context.push(AppRoutes.updateMedicine, extra: med);
              } else if (value == "delete") {
                _confirmDelete(context, med);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "edit", child: Text("Edit")),
              const PopupMenuItem(value: "delete", child: Text("Delete")),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Medicine med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Medicine"),
        content: Text("Delete ${med.name}?"),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<PillboxBloc>().add(
                DeleteMedicineWithCleanupEvent(
                  medicineId: med.id,
                  times: med.times,
                  start: med.startDate ?? DateTime.now(),
                  end:
                      med.endDate ??
                      DateTime.now().add(const Duration(days: 7)),
                ),
              );
              context.pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
