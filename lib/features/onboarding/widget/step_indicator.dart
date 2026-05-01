import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == step;
        final isDone = index < step;

        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isDone
                  ? Colors.blue
                  : isActive
                  ? Colors.blue
                  : Colors.grey.shade300,
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
            ),
            if (index != 2)
              Container(
                width: 40,
                height: 2,
                color: index < step ? Colors.blue : Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }
}
