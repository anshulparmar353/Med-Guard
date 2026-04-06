import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/sync/domain/repository/sync_repository.dart';

class DownloadMedicine {
  final SyncRepository repository;

  DownloadMedicine(this.repository);

  Future<List<Medicine>> call() {
    return repository.downloadMedicine();
  }
}
