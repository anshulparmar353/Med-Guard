import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/sync/domain/repository/sync_repository.dart';

class SyncMedicines {
  final SyncRepository repository;

  SyncMedicines(this.repository);

  Future<void> call(List<Medicine> medicines) {
    return repository.syncMedicines(medicines);
  }
}