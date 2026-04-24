import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:med_guard/core/services/sync_service.dart';
import 'package:med_guard/core/sync/sync_manager.dart';
import 'package:med_guard/features/pillbox/domain/entities/medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/add_medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/add_medicine_with_schedule.dart';
import 'package:med_guard/features/pillbox/domain/usecases/delete_medicine.dart';
import 'package:med_guard/features/pillbox/domain/usecases/delete_medicine_with_cleanup.dart';
import 'package:med_guard/features/pillbox/domain/usecases/get_medicines.dart';
import 'package:med_guard/features/pillbox/domain/usecases/update_medicine_with_reschedule.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_event.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_state.dart';
import 'package:med_guard/features/sync/domain/usecases/sync_medicine.dart';

class PillboxBloc extends Bloc<PillboxEvent, PillboxState> {
  final GetMedicines getMedicines;
  final AddMedicineWithSchedule addMedicineWithSchedule;
  final AddMedicine addMedicine;
  final DeleteMedicine deleteMedicine;
  final DeleteMedicineWithCleanup deleteMedicineWithCleanup;
  final UpdateMedicineWithReschedule updateMedicineWithReschedule;
  final SyncMedicines syncMedicines;
  final SyncService syncService;
  final SyncManager syncManager;

  PillboxBloc({
    required this.getMedicines,
    required this.addMedicineWithSchedule,
    required this.addMedicine,
    required this.deleteMedicine,
    required this.deleteMedicineWithCleanup,
    required this.updateMedicineWithReschedule,
    required this.syncMedicines,
    required this.syncService,
    required this.syncManager,
  }) : super(PillboxInitial()) {
    on<LoadMedicines>(_onLoad);
    on<AddMedicineWithScheduleEvent>(_onAddWithSchedule);
    on<AddMedicineEvent>(_onAddMedicine);
    on<DeleteMedicineEvent>(_onDelete);
    on<DeleteMedicineWithCleanupEvent>(_onDeleteWithCleanup);
    on<UpdateMedicineWithRescheduleEvent>(_onUpdateWithReschedule);
  }

  void _onLoad(LoadMedicines event, Emitter<PillboxState> emit) async {
    emit(PillboxLoading());

    final meds = await getMedicines();

    syncManager.scheduleSync(() async {
      await syncMedicines(meds);
    });

    emit(PillboxLoaded(meds));
  }

  Future<void> _onAddWithSchedule(
    AddMedicineWithScheduleEvent event,
    Emitter<PillboxState> emit,
  ) async {
    print("ADDING MEDICINE BLoc schedule: ${event.medicine.name}");

    try {
      await addMedicineWithSchedule(event.medicine);

      syncManager.scheduleSync(() async {
        final meds = await getMedicines();
        await syncMedicines(meds);
      });

      add(LoadMedicines());
    } catch (e) {
      emit(PillboxError("Failed to add medicine"));
    }
  }

  Future<void> _onAddMedicine(
    AddMedicineEvent event,
    Emitter<PillboxState> emit,
  ) async {
    print("ADDING MEDICINE BLoc");

    try {
      await addMedicine(event.medicine);

      syncManager.scheduleSync(() async {
        final meds = await getMedicines();
        await syncMedicines(meds);
      });

      final user = FirebaseAuth.instance.currentUser!.uid;

      if (user.isNotEmpty) {
        await syncService.sync(user);
      }

      final medicines = await getMedicines();

      emit(PillboxLoaded(medicines));
    } catch (e) {
      emit(PillboxError("Failed to add medicine"));
    }
  }

  Future<void> _onDelete(
    DeleteMedicineEvent event,
    Emitter<PillboxState> emit,
  ) async {
    final medicine = event.medicine;

    final updated = Medicine(
      id: medicine.id,
      name: medicine.name,
      dosage: medicine.dosage,
      times: medicine.times,
      updateAt: DateTime.now(),
      isDeleted: true,
    );

    await deleteMedicine(updated.id);

    syncManager.scheduleSync(() async {
      final meds = await getMedicines();
      await syncMedicines(meds);
    });

    final medicines = await getMedicines();
    emit(PillboxLoaded(medicines));
  }

  Future<void> _onDeleteWithCleanup(
    DeleteMedicineWithCleanupEvent event,
    Emitter<PillboxState> emit,
  ) async {
    try {
      await deleteMedicineWithCleanup(event.medicineId);

      syncManager.scheduleSync(() async {
        final meds = await getMedicines();
        await syncMedicines(meds);
      });

      final medicines = await getMedicines();
      emit(PillboxLoaded(medicines));
    } catch (e) {
      emit(PillboxError("Failed to delete medicine"));
    }
  }

  Future<void> _onUpdateWithReschedule(
    UpdateMedicineWithRescheduleEvent event,
    Emitter<PillboxState> emit,
  ) async {
    try {
      await updateMedicineWithReschedule(event.medicine);

      syncManager.scheduleSync(() async {
        final meds = await getMedicines();
        await syncMedicines(meds);
      });

      final medicines = await getMedicines();
      emit(PillboxLoaded(medicines));
    } catch (e) {
      emit(PillboxError("Failed to update medicine"));
    }
  }
}
