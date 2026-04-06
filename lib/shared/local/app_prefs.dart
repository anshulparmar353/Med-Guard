import 'package:hive/hive.dart';

class AppPrefs {
  final Box box;

  AppPrefs(this.box);

  static const _key = "last_refresh_date";

  DateTime? getLastRefreshDate() {
    final value = box.get(_key);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> setLastRefreshDate(DateTime date) async {
    await box.put(_key, date.toIso8601String());
  }
}