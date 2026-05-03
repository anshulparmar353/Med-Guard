import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:med_guard/core/routes/app_go_router.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_state.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_event.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_state.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDarkMode = false;

  bool notificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPermission();
  }

  Future<void> _loadPermission() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        notificationEnabled = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String email = "";
    if (authState is AuthAuthenticated) {
      email = authState.user.email;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileLoaded) {
              final user = state.user;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.blue,
                      child: user?.name.isNotEmpty == true
                          ? Text(
                              user!.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      user?.name.isNotEmpty == true
                          ? user!.name
                          : "Set your name",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      email.isNotEmpty ? email : "No email",
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    if (user == null)
                      Column(
                        children: [
                          const Text("No profile found"),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              context.push(AppRoutes.editProfileScreen);
                            },
                            child: const Text("Create Profile"),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _tile(
                            icon: Icons.person_outline,
                            color: Colors.blue,
                            title: "Edit Profile",
                            onTap: () async {
                              final result = await context.push(
                                AppRoutes.editProfileScreen,
                              );

                              if (!mounted) return;

                              if (result == true) {
                                context.read<ProfileBloc>().add(LoadProfile());
                              }
                            },
                          ),

                          const Divider(height: 1),

                          _tile(
                            icon: Icons.notifications_none,
                            color: Colors.green,
                            title: notificationEnabled
                                ? "Notifications (On)"
                                : "Notifications (Off)",
                            onTap: openNotificationSettings,
                          ),

                          const Divider(height: 1),

                          _tile(
                            icon: Icons.logout,
                            color: Colors.red,
                            title: "Logout",
                            textColor: Colors.red,
                            onTap: () {
                              context.read<AuthBloc>().add(LogoutRequested());
                            },
                          ),

                          const Divider(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Future<void> openNotificationSettings() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      if (!mounted) return;

      final open = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Notifications Enabled"),
          content: const Text(
            "Notifications are already enabled.\nDo you want to manage settings?",
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () => context.pop(true),
              child: const Text(
                "Open Settings",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (open == true) {
        AppSettings.openAppSettings();
      }
    } else {
      final result = await Permission.notification.request();

      if (!result.isGranted) {
        AppSettings.openAppSettings();
      }
    }
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _iconCircle(icon, color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? Colors.black,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }
}
