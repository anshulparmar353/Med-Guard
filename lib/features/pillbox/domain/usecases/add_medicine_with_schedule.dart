import 'package:med_guard/features/dashboard/domain/usecases/create_dose.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/add_medicine.dart';
import 'package:med_guard/features/reminder/domain/entities/reminder.dart';
import 'package:med_guard/features/reminder/domain/usecases/schedule_reminder.dart';

class AddMedicineWithSchedule {
  final AddMedicine addMedicine;
  final CreateDose createDose;
  final ScheduleReminder scheduleReminder;

  AddMedicineWithSchedule(
    this.addMedicine,
    this.createDose,
    this.scheduleReminder,
  );

  Future<void> call(Medicine medicine) async {
    await addMedicine(medicine);

    await createDose.call(
      medicineId: medicine.id,
      medicineName: medicine.name,
      scheduledTime: DateTime.now(),
    );

    for (final time in medicine.times) {
      await scheduleReminder(
        Reminder(
          id: "${medicine.id}_${time.hour}_${time.minute}".hashCode,
          medicineName: medicine.name,
          time: time,
        ),
      );
    }
  }
}
