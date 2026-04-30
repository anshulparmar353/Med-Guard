import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';

abstract class PillboxEvent {}

class LoadMedicines extends PillboxEvent {}

class AddMedicineWithScheduleEvent extends PillboxEvent {
  final Medicine medicine;

  AddMedicineWithScheduleEvent(this.medicine);
}

class UpdateMedicineWithRescheduleEvent extends PillboxEvent {
  final Medicine medicine;

  UpdateMedicineWithRescheduleEvent(this.medicine);
}

class DeleteMedicineWithCleanupEvent extends PillboxEvent {
  final String medicineId;
  final List<DateTime> times;
  final DateTime start;
  final DateTime end;

  DeleteMedicineWithCleanupEvent({
    required this.medicineId,
    required this.times,
    required this.start,
    required this.end,
  });
}
