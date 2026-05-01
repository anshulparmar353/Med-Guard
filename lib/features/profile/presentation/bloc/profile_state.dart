import 'package:med_guard/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileUser? user;

  ProfileLoaded(this.user);
}

class ProfileSaving extends ProfileState {}
