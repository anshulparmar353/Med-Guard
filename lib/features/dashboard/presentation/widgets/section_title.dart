import 'package:flutter/material.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_log.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/medicine_card.dart';

class SectionTitle extends StatelessWidget {
  final BuildContext context;
  final String title;
  final List<DoseLog> doses;

  const SectionTitle({
    super.key,
    required this.context,
    required this.title,
    required this.doses,
  });

  @override
  Widget build(BuildContext context) {
    if (doses.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),

        ...doses.map((dose) => MedicineCard(d: dose)),

        const SizedBox(height: 20),
      ],
    );
  }
}
