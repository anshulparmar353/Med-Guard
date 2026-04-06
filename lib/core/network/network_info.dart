import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity connectivity;

  NetworkInfo(this.connectivity);

  Stream<bool> get onConnected async* {
    await for (final result in connectivity.onConnectivityChanged) {
      yield !result.contains(ConnectivityResult.none);
    }
  }
}
