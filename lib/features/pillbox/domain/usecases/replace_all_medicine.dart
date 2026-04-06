import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';

class ReplaceAllMedicines {
  final MedicineRepository repository;

  ReplaceAllMedicines(this.repository);

  Future<void> call(List<Medicine> medicines) {
    return repository.replaceAllMedicines(medicines);
  }
}
