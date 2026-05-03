import 'package:hive/hive.dart';
import '../models/medicine_model.dart';

class MedicineLocalDataSource {
  final Box<MedicineModel> box;

  MedicineLocalDataSource(this.box);

  Future<void> addMedicine(MedicineModel med) async {
    print("📝 WRITING MEDICINE: ${med.id}");
    await box.put(med.id, med);
  }

  List<MedicineModel> getMedicines() {
    return box.values.where((m) => !m.isDeleted).toList();
  }

  Future<void> clearAll() async {
    await box.clear();
  }

  Future<void> replaceAll(List<MedicineModel> meds) async {
    final Map<String, MedicineModel> map = {for (var m in meds) m.id: m};

    await box.putAll(map);
  }
}
