import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingRemoteDataSource {
  final FirebaseFirestore firestore;

  TrackingRemoteDataSource(this.firestore);

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return firestore.collection('users').doc(userId).collection('dose_logs');
  }

  Future<void> uploadDose(String userId, Map<String, dynamic> data) async {
    await _ref(userId).doc(data['id']).set(data, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchDoses(
    String userId,
    DateTime? lastSync,
  ) async {
    Query<Map<String, dynamic>> query = _ref(userId);

    if (lastSync != null) {
      query = query.where(
        'updatedAt',
        isGreaterThan: Timestamp.fromDate(lastSync),
      );
    }

    final snapshot = await query.get();

    return snapshot.docs.map((e) => e.data()).toList(); 
  }
}
