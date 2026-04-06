import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:med_guard/core/sync/sync_manager.dart';
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
  final DeleteMedicine deleteMedicine;
  final DeleteMedicineWithCleanup deleteMedicineWithCleanup;
  final UpdateMedicineWithReschedule updateMedicineWithReschedule;
  final SyncMedicines syncMedicines;
  final SyncManager syncManager;

  PillboxBloc({
    required this.getMedicines,
    required this.addMedicineWithSchedule,
    required this.deleteMedicine,
    required this.deleteMedicineWithCleanup,
    required this.updateMedicineWithReschedule,
    required this.syncMedicines,
    required this.syncManager,
  }) : super(PillboxInitial()) {
    on<LoadMedicines>(_onLoad);
    on<AddMedicineWithScheduleEvent>(_onAddWithSchedule);
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
    try {
      await addMedicineWithSchedule(event.medicine); // 🔥 SINGLE ENTRY POINT

      syncManager.scheduleSync(() async {
        final meds = await getMedicines();
        await syncMedicines(meds);
      });

      add(LoadMedicines()); // refresh UI
    } catch (e) {
      emit(PillboxError("Failed to add medicine"));
    }
  }

  Future<void> _onDelete(
    DeleteMedicineEvent event,
    Emitter<PillboxState> emit,
  ) async {
    await deleteMedicine(event.id);

    syncManager.scheduleSync(() async {
      final meds = await getMedicines();
      await syncMedicines(meds);
    });

    add(LoadMedicines());
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

      add(LoadMedicines());
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

      add(LoadMedicines());
    } catch (e) {
      emit(PillboxError("Failed to update medicine"));
    }
  }
}
