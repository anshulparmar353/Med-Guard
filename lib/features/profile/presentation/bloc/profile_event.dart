import 'package:med_guard/features/profile/domain/entities/profile_user.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class SaveProfile extends ProfileEvent {
  final ProfileUser user;

  SaveProfile(this.user);
}

class ProfileUpdated extends ProfileEvent {
  final ProfileUser user;

  ProfileUpdated(this.user);
}
