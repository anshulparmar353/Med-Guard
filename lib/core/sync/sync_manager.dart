import 'dart:async';

class SyncManager {
  Timer? _debounce;

  void scheduleSync(Future<void> Function() task) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(seconds: 2), () async {
      await task();
    });
  }
}
