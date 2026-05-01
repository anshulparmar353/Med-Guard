import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Med Guard Emergency",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Emergency Assistance",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                "Tap the SOS button for immediate help",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              Center(
                child: GestureDetector(
                  onLongPress: () => _triggerSOS(),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SOS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Press for Help",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _actionCard(
                color: Colors.red,
                icon: Icons.call,
                title: "Call Ambulance",
                subtitle: "Emergency: 108",
                onTap: () => callNumber("6232075318"),
              ),

              const SizedBox(height: 16),

              _actionCard(
                color: Colors.black,
                icon: Icons.contacts,
                title: "Emergency Contacts",
                subtitle: "Call your saved contacts",
                onTap: () {},
              ),

              const SizedBox(height: 16),

              _actionCard(
                color: Colors.black,
                icon: Icons.location_on,
                title: "Nearby Hospitals",
                subtitle: "Find closest medical centers",
                onTap: () async {
                  final url = Uri.parse(
                    "https://www.google.com/maps/search/hospitals+near+me/",
                  );
                  await launchUrl(url);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _triggerSOS() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      HapticFeedback.heavyImpact();

      final confirm = await _confirmSOS();
      if (!confirm) return;

      final profileState = context.read<ProfileBloc>().state;

      if (profileState is! ProfileLoaded) {
        _showError("Profile not loaded");
        return;
      }

      final phone = profileState.user?.caregiverPhone;

      if (phone == null || phone.isEmpty) {
        _showError("Add caregiver number in profile");
        return;
      }

      final locStatus = await Permission.location.request();

      if (locStatus.isPermanentlyDenied) {
        _showError("Enable location from settings");
        await openAppSettings();
        return;
      }

      String location = "Location unavailable";

      if (locStatus.isGranted) {
        try {
          location = await getLocationLink();
        } catch (_) {}
      }

      final message =
          "🚨 EMERGENCY ALERT\nUser needs help!\nLocation: $location";

      await sendSMS(phone, message);

      final call = await _askCall();

      if (call == true) {
        await callNumber(phone);
      }

      _showSuccess("Emergency alert initiated");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<bool?> _askCall() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Call Caregiver"),
        content: const Text("Do you want to call now?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Call"),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmSOS() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Emergency SOS"),
            content: const Text("Send alert to caregiver?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  "Send",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> callNumber(String number) async {
    final Uri url = Uri.parse("tel:$number");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<String> getLocationLink() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return "https://maps.google.com/?q=${position.latitude},${position.longitude}";
  }

  Future<void> sendSMS(String phone, String message) async {
    final Uri uri = Uri.parse(
      "sms:$phone?body=${Uri.encodeComponent(message)}",
    );

    await launchUrl(uri);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _actionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color == Colors.red
              ? Colors.red.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color == Colors.red ? Colors.red : Colors.grey.shade300,
          ),
          boxShadow: [
            if (color != Colors.red)
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white),
            ),

            const SizedBox(width: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
