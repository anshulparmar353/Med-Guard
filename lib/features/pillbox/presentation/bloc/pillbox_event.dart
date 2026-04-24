
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';

abstract class PillboxEvent {}

class LoadMedicines extends PillboxEvent {}

class AddMedicineEvent extends PillboxEvent {
  final Medicine medicine;

  AddMedicineEvent(this.medicine);
}

class AddMedicineWithScheduleEvent extends PillboxEvent {
  final Medicine medicine;

  AddMedicineWithScheduleEvent(this.medicine);
}

class UpdateMedicineWithRescheduleEvent extends PillboxEvent {
  final Medicine medicine;

  UpdateMedicineWithRescheduleEvent(this.medicine);
}

class DeleteMedicineEvent extends PillboxEvent {
  final Medicine medicine;

  DeleteMedicineEvent(this.medicine);
}

class DeleteMedicineWithCleanupEvent extends PillboxEvent {
  final String medicineId;

  DeleteMedicineWithCleanupEvent(this.medicineId);
} 
