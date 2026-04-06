import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';

class AddMedicine {
  final MedicineRepository repo;

  AddMedicine(this.repo);

  Future<void> call(Medicine medicine) {
    return repo.addMedicine(medicine);
  }
}