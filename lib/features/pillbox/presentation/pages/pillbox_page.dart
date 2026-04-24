import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_bloc.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_state.dart';

class PillboxPage extends StatelessWidget {
  const PillboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PillboxBloc, PillboxState>(
        builder: (context, state) {
          if (state is PillboxLoaded) {
            return Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
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

                    ListView.builder(
                      itemCount: state.medicines.length,
                      itemBuilder: (_, i) {
                        final med = state.medicines[i];

                        return Card(
                          child: ListTile(
                            title: Text(med.name),
                            subtitle: Text(med.dosage),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
