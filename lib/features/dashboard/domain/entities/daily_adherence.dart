class DailyAdherence {
  DailyAdherence(this.missed, this.taken);
  final int taken;
  final int missed;

  double get percentage => (taken + missed) == 0 ? 0 : taken / (taken + missed);
}
