import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';

abstract class SyncRepository {
  Future<void> syncMedicines(List<Medicine> medicines);
  Future<List<Medicine>> downloadMedicine();
}
