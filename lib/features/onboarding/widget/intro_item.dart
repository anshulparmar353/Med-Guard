import 'package:flutter/material.dart';

class IntroItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String image;
  final VoidCallback onTap;
  final VoidCallback? onSkip;

  const IntroItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.image,
    required this.onTap,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [

            Expanded(
              flex: 5,
              child: Center(child: Image.asset(image, fit: BoxFit.contain)),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (onSkip != null)
                  TextButton(onPressed: onSkip, child: const Text("Skip")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
