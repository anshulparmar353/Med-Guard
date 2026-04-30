class Medicine {
  final String id;
  final String name;
  final String dosage;
  final List<DateTime> times;

  final DateTime updatedAt; // ✅ NOT updateAt

  final bool isDeleted;
  final bool isDaily;

  final DateTime? startDate;
  final DateTime? endDate;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.updatedAt,
    required this.isDeleted,
    required this.isDaily,
    this.startDate,
    this.endDate,
  });
}
