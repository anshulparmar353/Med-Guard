import 'package:med_guard/features/dashboard/domain/entities/daily_adherence.dart';

class WeeklyAdherence {
  final List<DailyAdherence> days;

  WeeklyAdherence({required this.days});

  factory WeeklyAdherence.empty() {
    return WeeklyAdherence(days: List.generate(7, (_) => DailyAdherence(0, 0)));
  }

  int get taken => days.fold(0, (s, d) => s + d.taken);
  int get missed => days.fold(0, (s, d) => s + d.missed);

  double get percentage {
    final totalTaken = taken;
    final totalMissed = missed;

    if (totalTaken + totalMissed == 0) return 0;
    return (totalTaken / (totalTaken + totalMissed)) * 100;
  }
}
