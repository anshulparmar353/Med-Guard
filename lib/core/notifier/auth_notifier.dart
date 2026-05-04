import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_state.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;
  late final StreamSubscription _subscription;

  bool _isSplashDone = false;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _userId;
  bool _isAppStarting = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isSplashDone => _isSplashDone;
  String? get userId => _userId;
  bool get isAppStarting => _isAppStarting;

  AuthNotifier(this._authBloc) {
    update(_authBloc.state);

    _subscription = _authBloc.stream.listen(update);
  }

  void triggerRouterRefresh() {
    notifyListeners();
  }

  void setAuth(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void completeSplash() {
    _isSplashDone = true;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  void update(AuthState state) {
    if (state is AuthAuthenticated) {
      _isAuthenticated = true;
      _userId = state.user.id;
      _isLoading = false;
      _isSplashDone = true;
      _isAppStarting = false;
    } else if (state is AuthUnauthenticated) {
      _isAuthenticated = false;
      _userId = null;
      _isLoading = false;
      _isSplashDone = true;
      _isAppStarting = false;
    } else if (state is AuthLoading) {
      _isLoading = true;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
