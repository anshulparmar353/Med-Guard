import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';

class FirebaseDatasource {
  final _db = FirebaseFirestore.instance;

  Future<void> uploadMedicines(String userId, List<Medicine> medicines) async {
    final ref = _db.collection('users').doc(userId);

    final data = medicines.map((m) {
      return {
        'id': m.id,
        'name': m.name,
        'dosage': m.dosage,
        'times': m.times.map((t) => t.toIso8601String()).toList(),
        'updatedAt': m.updatedAt.toIso8601String(), // ✅ FIXED
      };
    }).toList();

    await ref.set({'medicines': data}, SetOptions(merge: true));
  }

  Future<List<MedicineModel>> downloadMedicines(String userId) async {
    final ref = _db.collection('users').doc(userId);

    final doc = await ref.get();

    if (!doc.exists) return [];

    final data = doc.data();
    if (data == null || data['medicines'] == null) return [];

    final List meds = data['medicines'];

    return meds.map((m) {
      return MedicineModel(
        id: m['id'],
        name: m['name'],
        dosage: m['dosage'],
        times: (m['times'] as List).map((t) => DateTime.parse(t)).toList(),
        updatedAt: DateTime.parse(m['updatedAt']), 
        isDeleted: m['isDeleted'],
        isDaily: m['isDaily'],
      );
    }).toList();
  }
}
