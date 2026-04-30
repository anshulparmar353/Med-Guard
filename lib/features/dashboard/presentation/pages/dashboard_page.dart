import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_log.dart';
import 'package:med_guard/features/dashboard/domain/entities/dose_status.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:med_guard/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/action_card.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/medicine_card.dart';
import 'package:med_guard/features/dashboard/presentation/widgets/status_card.dart';
import 'package:med_guard/shared/widget/error_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        print("UI STATE: $state");

        if (state is DashboardLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DashboardError) {
          return Scaffold(
            body: ErrorState(
              message: state.message,
              onRetry: () {
                context.read<DashboardBloc>().add(LoadDashboard());
              },
            ),
          );
        }

        if (state is DashboardLoaded) {
          final doses = state.todayDoses;

          List<DoseLog> filterByRange(List<DoseLog> list, int start, int end) {
            return list
                .where(
                  (d) =>
                      d.scheduledTime.hour >= start &&
                      d.scheduledTime.hour < end,
                )
                .toList()
              ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
          }

          final morning = filterByRange(doses, 5, 12);
          final afternoon = filterByRange(doses, 12, 17);
          final evening = filterByRange(doses, 17, 21);
          final night =
              doses
                  .where(
                    (d) =>
                        d.scheduledTime.hour >= 21 || d.scheduledTime.hour < 5,
                  )
                  .toList()
                ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

          final taken = doses.where((d) => d.status == DoseStatus.taken).length;

          final pending = doses
              .where((d) => d.status == DoseStatus.pending)
              .length;

          final missed = doses
              .where((d) => d.status == DoseStatus.missed)
              .length;

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const DashboardHeader(),

                  const SizedBox(height: 20),

                  const Text(
                    "Quick Access",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          color: Colors.white,
                          icon: Icons.medication,
                          label: "Add Medicine",
                          onTap: () {
                            context.push(AppRoutes.addMedicine);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionCard(
                          color: Colors.white,
                          icon: Icons.access_time,
                          label: "Set Reminder",
                          onTap: () {
                            context.push(AppRoutes.addMedicine);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          color: Colors.white,
                          icon: Icons.camera_alt,
                          label: "Scan Prescription",
                          onTap: () {
                            context.push(AppRoutes.scanner);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionCard(
                          color: Colors.red,
                          icon: Icons.warning_rounded,
                          label: "Emergency",
                          textColor: Colors.white,
                          onTap: () {
                            context.push(AppRoutes.emergencyScreen);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Medicines",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd').format(DateTime.now()),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.pillbox);
                        },
                        child: const Text("View All"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: StatusCard(
                          label: "Taken",
                          count: taken,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatusCard(
                          label: "Pending",
                          count: pending,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatusCard(
                          label: "Missed",
                          count: missed,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildSection(context, "MORNING", morning),
                  _buildSection(context, "AFTERNOON", afternoon),
                  _buildSection(context, "EVENING", evening),
                  _buildSection(context, "NIGHT", night),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: Text("Dashboard")));
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<DoseLog> doses,
  ) {
    if (doses.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),

        ...doses.map((d) => MedicineCard(d: d)),
      ],
    );
  }
}
