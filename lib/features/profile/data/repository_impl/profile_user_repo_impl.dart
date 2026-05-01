import 'dart:async';

import 'package:med_guard/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:med_guard/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:med_guard/features/profile/data/models/profile_user_model.dart';
import 'package:med_guard/features/profile/domain/entities/profile_user.dart';
import 'package:med_guard/features/profile/domain/repository/profile_user_repository.dart';

class ProfileRepositoryImpl implements ProfileUserRepository {
  final ProfileLocalDataSource local;
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl(this.local, this.remote);

  @override
  Future<void> saveProfileUser(ProfileUser user) async {
    final model = ProfileUserModel.fromEntity(user);

    await local.saveUser(model);

    unawaited(remote.uploadProfile(model));
  }

  @override
  Future<ProfileUser?> getProfileUser(String userId) async {
    final localUser = local.getUser(userId);

    if (localUser != null) {
      return localUser.toEntity();
    }

    final remoteUser = await remote.fetchProfile(userId);

    if (remoteUser != null) {
      await local.saveUser(remoteUser);
      return remoteUser.toEntity();
    }

    return null;
  }

  @override
  Stream<ProfileUser?> watchProfileUser(String userId) {
    return local.watchUser(userId).map((m) => m?.toEntity());
  }

  @override
  Future<void> clearProfile(String userId) {
    return local.clearUser(userId);
  }
}
