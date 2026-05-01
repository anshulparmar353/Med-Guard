class ProfileUser {
  final String id; 
  final String name;
  final int age;
  final String? caregiverPhone;
  final bool emergencyEnabled;
  final DateTime updatedAt;

  ProfileUser({
    required this.id,
    required this.name,
    required this.age,
    this.caregiverPhone,
    this.emergencyEnabled = false,
    required this.updatedAt,
  });
}