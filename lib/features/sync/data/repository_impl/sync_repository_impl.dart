import 'package:firebase_auth/firebase_auth.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/sync/domain/repository/sync_repository.dart';
import '../datasources/firebase_datasource.dart';

class SyncRepositoryImpl implements SyncRepository {
  final FirebaseDatasource datasource;

  SyncRepositoryImpl(this.datasource);

  @override
  Future<void> syncMedicines(List<Medicine> medicines) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    await datasource.uploadMedicines(user.uid, medicines);
  }

  @override
  Future<List<Medicine>> downloadMedicine() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final models = await datasource.downloadMedicines(user.uid); // ✅ FIXED

    return models.map((m) => m.toEntity()).toList(); // ✅ FIXED
  }
}
