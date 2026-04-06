import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/sync/data/datasources/sync_queue_local_DB.dart';
import 'package:med_guard/features/sync/data/models/sync_model.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';

import '../../domain/entities/medicine.dart';
import '../datasources/medicine_local_datasource.dart';
import '../models/medicine_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineLocalDataSource local;
  final SyncQueueLocalDataSource queue;

  MedicineRepositoryImpl(this.local, this.queue);

  @override
  Future<void> addMedicine(Medicine medicine) async {
    final model = MedicineModel.fromEntity(medicine);

    await local.addMedicine(model);

    await queue.add(
      SyncItem(
        id: model.id,
        type: SyncType.add,
        data: model.toJson(),
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deleteMedicine(String id) async {
    await local.deleteMedicine(id);

    await queue.add(
      SyncItem(
        id: id,
        type: SyncType.delete,
        data: {'id': id},
        timestamp: DateTime.now(),
      ),
    );
  }

  

  @override
  Future<void> replaceAllMedicines(List<Medicine> medicines) async {
    for (final med in medicines) {
      final model = MedicineModel.fromEntity(med);

      await local.addMedicine(model);

      await queue.add(
        SyncItem(
          id: model.id,
          type: SyncType.add,
          data: model.toJson(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// ✅ FIXED HERE
  @override
  Future<List<Medicine>> getMedicines() async {
    final data = local.getMedicines(); // ✅ await
    return data.map((m) => m.toEntity()).toList(); // ✅ convert
  }

}
