import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:med_guard/core/services/connectivity_service.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/features/auth/domain/repository/auth_repository.dart';
import 'package:med_guard/features/auth/domain/usecases/login_usecase.dart';
import 'package:med_guard/features/auth/domain/usecases/logout_usecase.dart';
import 'package:med_guard/features/auth/domain/usecases/signup_usecase.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:med_guard/features/auth/presentation/bloc/auth_state.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUsecase signupUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository repository;
  final SyncService syncService;
  final ConnectivityService connectivityService;
  final MedicineRepository medRepo;

  StreamSubscription? _connectionSub;

  AuthBloc(
    this.loginUseCase,
    this.signupUseCase,
    this.logoutUseCase,
    this.repository,
    this.syncService,
    this.connectivityService,
    this.medRepo,
  ) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      emit(AuthLoading());

      try {
        final user = await repository.getCurrentUser();

        if (user != null) {
          await syncService.sync(user.id);
          _bindAutoSync(user.id);

          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final user = await loginUseCase(event.email, event.password);

        await syncService.sync(user.id);

        _bindAutoSync(user.id);

        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError("Invalid email or password"));
        emit(AuthUnauthenticated());
      }
    });

    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        final user = await signupUseCase(event.email, event.password);

        await syncService.sync(user.id);

        _bindAutoSync(user.id);

        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError("Signup failed"));
        emit(AuthUnauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());

      final user = await repository.getCurrentUser();

      try {
        if (user != null) {
          await syncService.sync(user.id);
        }

        await logoutUseCase();

        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError("Logout failed"));
      }
    });
  }
  void _bindAutoSync(String userId) {
    _connectionSub = connectivityService.connectionStream.listen((isOnline) async {
      if (isOnline) {
        print("🌐 INTERNET RESTORED → AUTO SYNC");
        await syncService.sync(userId);
      }
    });
  }

  @override
  Future<void> close() {
    _connectionSub?.cancel();
    return super.close();
  }
}
