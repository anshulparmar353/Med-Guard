import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';

class DeleteMedicine {
  final MedicineRepository repo;

  DeleteMedicine(this.repo);

  Future<void> call(String id) {
    return repo.deleteMedicine(id);
  }
}
