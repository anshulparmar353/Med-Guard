import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _controller.stream;

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityService(this._connectivity) {
    _init();
  }

  Future<void> _init() async {
    // Initial state
    final results = await _connectivity.checkConnectivity();
    _controller.add(_isOnline(results));

    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(_isOnline(results));
    });
  }

  /// 🔥 Real internet check
  Future<bool> hasInternet() async {
    return await InternetConnectionChecker().hasConnection;
  }

  /// 🔥 FIXED: Accept 
  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  } 

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
