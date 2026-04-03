import 'package:flutter/widgets.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_state.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthBloc authBloc;

  bool isAuthenticated = false;

  bool isLoading = true;

  AuthNotifier(this.authBloc) {
    authBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        isAuthenticated = true;
        isLoading = false;
      } else if (state is AuthUnauthenticated) {
        isAuthenticated = false;
        isLoading = false;
      }
      notifyListeners();
    });
  }
}
