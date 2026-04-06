import 'package:med_guard/features/pillbox/data/models/medicine_model.dart';

class ConflictResolver {
  static List<MedicineModel> resolve({
    required List<MedicineModel> local,
    required List<MedicineModel> remote,
  }) {
    final Map<String, MedicineModel> result = {}; // ✅ FIXED TYPE

    // 🔹 Add local first
    for (final med in local) {
      result[med.id] = med;
    }

    // 🔹 Compare with remote
    for (final remoteItem in remote) {
      final localItem = result[remoteItem.id];

      if (localItem == null ||
          remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
        result[remoteItem.id] = remoteItem;
      }
    }

    return result.values.toList();
  }
}
