class Medicine {
  final String id;
  final String name;
  final String dosage;
  final List<DateTime> times;
  final DateTime updateAt;
  final bool isDeleted;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.updateAt,
    required this.isDeleted,
  });
}
