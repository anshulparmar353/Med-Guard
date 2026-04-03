import 'package:bloc/bloc.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';
import 'package:med_guard/features/auth/domain/usecases/login_usecase.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final AuthRepository repository;

  AuthBloc(this.loginUseCase, this.repository)
      : super(AuthInitial()) {

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final user = await loginUseCase(event.email, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      final user = await repository.getCachedUser();

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      await repository.logout();
      emit(AuthUnauthenticated());
    });
  }
}