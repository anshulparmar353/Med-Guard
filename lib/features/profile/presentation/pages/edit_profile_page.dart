import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_guard/features/profile/domain/entities/profile_user.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_event.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool notificationsEnabled = true;
  bool emergencyEnabled = false;

  File? selectedImage;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final caregiverNameController = TextEditingController();
  final caregiverPhoneController = TextEditingController();

  String gender = "Male";

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  Future<void> pickFromGallery() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> pickFromCamera() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _prefill(ProfileUser? user) {
    if (user == null) return;

    nameController.text = user.name;
    ageController.text = user.age.toString();
    caregiverPhoneController.text = user.caregiverPhone ?? "";
    emergencyEnabled = user.emergencyEnabled;
  }

  void _save() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name is required")));
      return;
    }

    final user = ProfileUser(
      id: DateTime.now().toString(), // or auth user id later
      name: nameController.text.trim(),
      age: int.tryParse(ageController.text) ?? 0,
      caregiverPhone: caregiverPhoneController.text.trim(),
      emergencyEnabled: emergencyEnabled,
      updatedAt: DateTime.now(),
    );

    context.read<ProfileBloc>().add(SaveProfile(user));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Edit Profile"), centerTitle: true),

      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded) {
            _prefill(state.user);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 👤 PROFILE IMAGE
                Center(
                  child: GestureDetector(
                    onTap: showImageOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : const AssetImage("assets/profile.webp")
                                    as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue,
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle("Personal Information"),

                _inputField("Full Name", nameController, Icons.person),
                _inputField("Email", emailController, Icons.email),
                _inputField("Phone Number", phoneController, Icons.phone),

                const SizedBox(height: 16),

                _sectionTitle("Important for reminders"),

                _inputField("Age", ageController, null),
                _dropdownField("Gender", gender),

                const SizedBox(height: 16),

                /// 🚨 EMERGENCY SECTION
                Row(
                  children: const [
                    Icon(Icons.contact_emergency, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Emergency Contact",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _inputField(
                  "Contact Name",
                  caregiverNameController,
                  Icons.person,
                ),
                _inputField(
                  "Contact Phone",
                  caregiverPhoneController,
                  Icons.phone,
                ),

                SwitchListTile(
                  value: emergencyEnabled,
                  onChanged: (val) => setState(() => emergencyEnabled = val),
                  title: const Text("Enable Emergency Alerts"),
                ),

                const SizedBox(height: 16),

                _sectionTitle("Preferences"),

                SwitchListTile(
                  value: notificationsEnabled,
                  onChanged: (val) =>
                      setState(() => notificationsEnabled = val),
                  title: const Text("Enable Notifications"),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _save,
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData? icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        items: [
          "Male",
          "Female",
          "Other",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) => setState(() => gender = val!),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
