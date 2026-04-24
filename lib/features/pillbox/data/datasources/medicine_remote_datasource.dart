import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineRemoteDataSource {
  final FirebaseFirestore firestore;

  MedicineRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return firestore.collection('users').doc(userId).collection('medicines');
  }

  Future<void> uploadMedicine(String userId, Map<String, dynamic> data) async {
    print("Uploading to Firebase: $data");
    await _ref(userId).doc(data['id']).set(data, SetOptions(merge: true));
  }

  Future<void> deleteMedicine(String userId, String id) async {
    await _ref(
      userId,
    ).doc(id).update({"isDeleted": true, "updatedAt": Timestamp.now()});
  }

  Future<List<Object?>> fetchMedicines(
    String userId,
    DateTime? lastSyncedAt,
  ) async {
    Query query = _ref(userId);

    if (lastSyncedAt != null) {
      query = query.where(
        'updatedAt',
        isGreaterThan: Timestamp.fromDate(lastSyncedAt),
      );
    }

    final snapshot = await query.get();

    return snapshot.docs.map((e) => e.data()).toList();
  }

  // Future<void> deleteMedicine(String userId, String id) async {
  //   await firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('medicines')
  //       .doc(id)
  //       .delete();
  // }
}
