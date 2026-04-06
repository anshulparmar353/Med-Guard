
import '../entities/medicine.dart';

abstract class MedicineRepository {
  Future<void> addMedicine(Medicine medicine);

  Future<List<Medicine>> getMedicines();

  Future<void> deleteMedicine(String id);

  Future<void> replaceAllMedicines(List<Medicine> medicine);
}
