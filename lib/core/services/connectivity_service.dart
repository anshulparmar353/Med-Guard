import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _controller = StreamController<bool>();

  Stream<bool> get connectionStream => _controller.stream;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = !result.contains(ConnectivityResult.none);
      _controller.add(isOnline);
    });
  }
}