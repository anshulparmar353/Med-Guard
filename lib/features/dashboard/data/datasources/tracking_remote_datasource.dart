import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingRemoteDataSource {
  final FirebaseFirestore firestore;

  TrackingRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return firestore.collection('users').doc(userId).collection('dose_logs');
  }

  Future<void> uploadDose(String userId, Map<String, dynamic> data) async {
    await _ref(userId).doc(data['id']).set({
      ...data,
      "isDeleted": data["isDeleted"] ?? false,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchDoses(
    String userId,
    DateTime? lastSync,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _ref(userId);

      if (lastSync != null) {
        query = query
            .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSync))
            .orderBy('updatedAt');
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((e) {
            final data = e.data();

            if (data["updatedAt"] is Timestamp) {
              data["updatedAt"] = (data["updatedAt"] as Timestamp).toDate();
            } else {
              data["updatedAt"] = DateTime.now();
            }

            return data;
          })
          .where((d) => d["isDeleted"] != true)
          .toList();
    } catch (e) {
      print("❌ Fetch dose error: $e");
      return [];
    }
  }

  Future<void> deleteDose(String userId, String id) async {
    await _ref(userId).doc(id).set({
      "id": id,
      "isDeleted": true,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
