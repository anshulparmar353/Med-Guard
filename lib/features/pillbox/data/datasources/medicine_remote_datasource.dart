import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineRemoteDataSource {
  final FirebaseFirestore firestore;

  MedicineRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return firestore.collection('users').doc(userId).collection('medicines');
  }

  Future<void> uploadMedicine(String userId, Map<String, dynamic> data) async {
    try {
      await _ref(userId).doc(data['id']).set({
        ...data,

        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Uploaded medicine: ${data['id']}");
    } catch (e) {
      print("❌ Upload error: $e");
      rethrow;
    }
  }

  Future<void> deleteMedicine(String userId, String id) async {
    try {
      await _ref(userId).doc(id).set({
        "id": id,
        "isDeleted": true,

        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Delete error: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMedicines(
    String userId,
    DateTime? lastSyncedAt,
  ) async {
    try {
      Query<Map<String, dynamic>> query = _ref(userId);

      if (lastSyncedAt != null) {
        query = query
            .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSyncedAt))
            .orderBy('updatedAt'); 
      }

      final snapshot = await query.get();

      return snapshot.docs.map((e) {
        final data = e.data();

        if (data["updatedAt"] is Timestamp) {
          data["updatedAt"] = (data["updatedAt"] as Timestamp).toDate();
        }

        return data;
      }).toList();
    } catch (e) {
      print("❌ Fetch error: $e");
      return [];
    }
  }
}
