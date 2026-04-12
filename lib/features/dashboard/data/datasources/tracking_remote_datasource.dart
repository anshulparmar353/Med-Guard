import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingRemoteDataSource {
  final FirebaseFirestore firestore;

  TrackingRemoteDataSource(this.firestore);

  Future<void> uploadDose(String userId, Map<String, dynamic> data) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('doses')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchDoses(
    String userId,
    DateTime? lastSync,
  ) async {
    Query query = firestore.collection('users').doc(userId).collection('doses');

    if (lastSync != null) {
      query = query.where('updatedAt', isGreaterThan: lastSync);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((e) => e.data() as Map<String, dynamic>).toList();
  }
}
