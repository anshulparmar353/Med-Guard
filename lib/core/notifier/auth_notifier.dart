import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_state.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthBloc authBloc;
  late final StreamSubscription _subscription;

  bool isAuthenticated = false;
  bool isLoading = true;

  AuthNotifier(this.authBloc) {
    _update(authBloc.state);

    _subscription = authBloc.stream.listen(_update);
  }

  void _update(AuthState state) {
    if (state is AuthAuthenticated) {
      isAuthenticated = true;
      isLoading = false;
    } else if (state is AuthUnauthenticated) {
      isAuthenticated = false;
      isLoading = false;
    } else if (state is AuthLoading) {
      isLoading = true;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel(); // 🔥 FIX
    super.dispose();
  }
}
