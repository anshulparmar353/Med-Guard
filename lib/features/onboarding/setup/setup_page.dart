import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/features/onboarding/setup/step_basic_info.dart';
import 'package:med_guard/features/onboarding/setup/step_caregiver.dart';
import 'package:med_guard/features/onboarding/setup/step_settings.dart';
import 'package:med_guard/features/onboarding/widget/step_indicator.dart';
import 'package:med_guard/features/profile/domain/entities/profile_user.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_event.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int step = 0;

  String name = "";
  int age = 0;
  String? phone;
  bool emergency = false;

  void next() {
    if (step < 2) {
      setState(() => step++);
    } else {
      finish();
    }
  }

  void back() {
    if (step > 0) setState(() => step--);
  }

  void finish() {
    final userId = context.read<ProfileBloc>().userId;

    context.read<ProfileBloc>().add(
      SaveProfile(
        ProfileUser(
          id: userId,
          name: name,
          age: age,
          caregiverPhone: phone,
          emergencyEnabled: emergency,
          updatedAt: DateTime.now(),
        ),
      ),
    );

    context.go(AppRoutes.dashboardScreen);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (step) {
      case 0:
        child = StepBasic(
          onNext: (n, a) {
            name = n;
            age = a;
            next();
          },
        );
        break;

      case 1:
        child = StepCaregiver(
          onNext: (p) {
            phone = p;
            next();
          },
          onBack: back,
        );
        break;

      case 2:
      default:
        child = StepSettings(
          onFinish: (e) {
            emergency = e;
            next();
          },
          onBack: back,
        );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: StepIndicator(step: step),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
