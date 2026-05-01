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

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isSplashDone => _isSplashDone;
  String? get userId => _userId;

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

  void update(AuthState state) {
    bool changed = false;

    if (state is AuthAuthenticated) {
      if (!_isAuthenticated || _userId != state.user.id) {
        _isAuthenticated = true;
        _userId = state.user.id;
        changed = true;
      }
      _isLoading = false;
    } else if (state is AuthUnauthenticated) {
      if (_isAuthenticated) {
        _isAuthenticated = false;
        _userId = null;
        changed = true;
      }
      _isLoading = false;
    } else if (state is AuthLoading) {
      _isLoading = true;
    }

    if (changed) notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
