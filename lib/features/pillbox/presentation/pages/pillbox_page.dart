import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_event.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_state.dart';
import 'package:med_guard/features/pillbox/presentation/pages/add_medicine_page.dart';
import 'package:med_guard/shared/widget/error_widget.dart';
import 'package:med_guard/shared/widget/loading_widget.dart';
import 'package:med_guard/shared/widget/empty_state.dart';

class PillboxPage extends StatelessWidget {
  const PillboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Medicines")),
      body: BlocBuilder<PillboxBloc, PillboxState>(
        builder: (context, state) {
          if (state is PillboxLoading) {
            return const LoadingWidget(message: "Loading medicines...");
          }

          if (state is PillboxError) {
            return ErrorState(
              message: state.message,
              onRetry: () {
                context.read<PillboxBloc>().add(LoadMedicines());
              },
            );
          }

          if (state is PillboxLoaded) {
            if (state.medicines.isEmpty) {
              return EmptyState(
                title: "No medicines added",
                subtitle: "Add your first medicine to get started",
                icon: Icons.medication_outlined,
                actionLabel: "Add Medicine",
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddMedicinePage()),
                  );
                },
              );
            }

            return ListView.builder(
              itemCount: state.medicines.length,
              itemBuilder: (_, i) {
                final med = state.medicines[i];

                return ListTile(
                  title: Text(med.name),
                  subtitle: Text(med.dosage),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
