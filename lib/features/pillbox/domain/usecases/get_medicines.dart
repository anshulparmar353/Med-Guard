import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';

class GetMedicines {
  final MedicineRepository repo;

  GetMedicines(this.repo);

  Future<List<Medicine>> call() {
    return repo.getMedicines();
  }
}
  