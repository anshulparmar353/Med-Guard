import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/core/di/injection.dart';
import 'package:med_guard/core/notifier/auth_notifier.dart';
import 'package:med_guard/features/profile/domain/usecases/get_profile_user_usecase.dart';
import 'package:med_guard/features/profile/domain/usecases/save_profile_user_usecase.dart';
import 'package:med_guard/features/profile/domain/usecases/watch_profile_user_usecase.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_event.dart';
import 'package:med_guard/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUserUseCase getUser;
  final SaveProfileUserUseCase saveUser;
  final WatchProfileUserUseCase watchUser;

  final String userId;

  ProfileBloc(this.getUser, this.saveUser, this.watchUser, this.userId)
    : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());

      print("🔥 PROFILE LOADING FOR: $userId");

      final user = await getUser(userId);
      emit(ProfileLoaded(user));

      getIt<AuthNotifier>().refresh();

      await emit.forEach(
        watchUser(userId),
        onData: (user) {
          print("🔥 PROFILE STREAM UPDATE");

          getIt<AuthNotifier>().refresh();

          return ProfileLoaded(user);
        },
      );
    });

    on<SaveProfile>((event, emit) async {
      emit(ProfileSaving());

      await saveUser(event.user);

      emit(ProfileLoaded(event.user));

      getIt<AuthNotifier>().refresh();
    });

    add(LoadProfile());
  }
}
