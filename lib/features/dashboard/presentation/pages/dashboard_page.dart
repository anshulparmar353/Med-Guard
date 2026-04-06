import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/emergency_button.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/medicine_timeline.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/primary_action.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/section_title.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/status_card.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/weekly_adherence_card.dart';
import 'package:med_guard/shared/widget/empty_state.dart';
import 'package:med_guard/shared/widget/error_widget.dart';
import 'package:med_guard/shared/widget/loading_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const LoadingWidget(message: "Loading your medicines...");
            }

            if (state is DashboardError) {
              return ErrorState(
                message: state.message,
                onRetry: () {
                  context.read<DashboardBloc>().add(LoadDashboard());
                },
              );
            }

            if (state is DashboardLoaded) {
              if (state.todayDoses.isEmpty && state.taken == 0) {
                return EmptyState(
                  title: "No medicines yet",
                  subtitle: "Start by adding your medicines",
                  actionLabel: "Add Medicine",
                  onAction: () {},
                );
              }
              return Column(
                children: [
                  DashboardHeader(
                    userName: "Anshul",
                    totalMeds: state.todayDoses.length,
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusCard(taken: state.taken, missed: state.missed),
                          const SizedBox(height: 20),

                          const PrimaryAction(),
                          const SizedBox(height: 20),

                          WeeklyAdherenceCard(data: state.weekly),
                          SizedBox(height: 20),

                          const SectionTitle(title: "Today's Medicines"),
                          const SizedBox(height: 10),

                          MedicineTimeline(doses: state.todayDoses),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  const EmergencyButton(),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
