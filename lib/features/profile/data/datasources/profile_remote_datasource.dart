import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_user_model.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSource(this.firestore);

  Future<void> uploadProfile(ProfileUserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).set({
        ...user.toJson(),

        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ FIREBASE UPLOAD ERROR: $e");
      rethrow;
    }
  }

  Future<ProfileUserModel?> fetchProfile(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      if (data["updatedAt"] is Timestamp) {
        data["updatedAt"] = (data["updatedAt"] as Timestamp).toDate();
      } else {
        data["updatedAt"] = DateTime.now();
      }

      return ProfileUserModel.fromJson(data);
    } catch (e) {
      print("❌ FIREBASE FETCH ERROR: $e");
      return null;
    }
  }
}
