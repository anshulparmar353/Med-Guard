import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:med_guard/core/services/sync_service.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _controller.stream;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService(this._connectivity);

  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    final hasNet = await hasInternet();

    _controller.add(_isOnline(results) && hasNet);

    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final hasNet = await hasInternet();
      final isOnline = _isOnline(results) && hasNet;

      print("🌐 INTERNET STATUS: $isOnline");
      _controller.add(isOnline);
    });
  }

  void startSync(SyncService syncService, String userId) {
    connectionStream.listen((isOnline) async {
      if (isOnline) {
        print("🌐 INTERNET RESTORED → SYNC TRIGGERED");
        await syncService.sync(userId);
      }
    });
  }

  Future<bool> hasInternet() async {
    return InternetConnectionChecker().hasConnection;
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
