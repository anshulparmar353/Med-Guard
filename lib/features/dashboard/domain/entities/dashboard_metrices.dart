
class DashboardMetrics {
  final int taken;
  final int missed;
  final int skipped;

  DashboardMetrics({
    required this.taken,
    required this.missed,
    required this.skipped,
  });

  double get adherence {
    final total = taken + missed;
    if (total == 0) return 0;
    return taken / total;
  }
}
