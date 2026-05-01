import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/features/onboarding/widget/intro_item.dart';
import 'package:med_guard/features/onboarding/widget/step_indicator.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final controller = PageController();
  int index = 0;

  void next() {
    if (index < 2) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      context.go(AppRoutes.setup);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: StepIndicator(step: index),
            ),

            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (i) => setState(() => index = i),
                children: [
                  IntroItem(
                    title: "Welcome to Med Guard",
                    subtitle: "Manage medications & wellness",
                    buttonText: "Next",
                    onTap: next,
                    onSkip: () => context.go(AppRoutes.setup),
                  ),
                  IntroItem(
                    title: "Stay Protected",
                    subtitle: "Get timely reminders",
                    buttonText: "Next",
                    onTap: next,
                    onSkip: () => context.go(AppRoutes.setup),
                  ),
                  IntroItem(
                    title: "Never Miss a Dose",
                    subtitle: "Enable notifications",
                    buttonText: "Get Started",
                    onTap: next,
                    onSkip: () => context.go(AppRoutes.setup),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
