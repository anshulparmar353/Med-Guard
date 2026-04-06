import 'package:flutter/material.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/big_button.dart';

class PrimaryAction extends StatelessWidget {
  const PrimaryAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BigButton(
          icon: Icons.add,
          label: "Add Medicine",
          color: Colors.blue,
          onTap: () {
            () {};
          },
        ),
        const SizedBox(height: 12),
        BigButton(
          icon: Icons.alarm,
          label: "Set Reminder",
          color: Colors.green,
          onTap: () {
            () {};
          },
        ),
      ],
    );
  }
}
