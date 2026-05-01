class ProfileUser {
  final String id;
  final String name;
  final String? userPhone;
  final int age;
  final String? caregiverName;
  final String? caregiverPhone;
  final bool emergencyEnabled;
  final DateTime updatedAt;
  bool? onboardingCompleted;

  ProfileUser({
    required this.id,
    required this.name,
    required this.age,
    this.caregiverName,
    this.caregiverPhone,
    this.userPhone,
    this.onboardingCompleted,
    required this.emergencyEnabled,
    required this.updatedAt,
  });
}
