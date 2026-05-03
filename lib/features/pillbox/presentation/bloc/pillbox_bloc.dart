import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_guard/core/sync/sync_manager.dart';
import 'package:med_guard/features/pillbox/domain/repository/medicine_repository.dart';
import 'package:med_guard/features/pillbox/domain/usecases/add_medicine_with_schedule.dart';
import 'package:med_guard/features/pillbox/domain/usecases/delete_medicine_with_cleanup.dart';
import 'package:med_guard/features/pillbox/domain/usecases/get_medicines.dart';
import 'package:med_guard/features/pillbox/domain/usecases/update_medicine_with_reschedule.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_event.dart';
import 'package:med_guard/features/pillbox/presentation/bloc/pillbox_state.dart';
import 'package:med_guard/features/sync/domain/usecases/sync_medicine.dart';

class PillboxBloc extends Bloc<PillboxEvent, PillboxState> {
  final String userId;
  final GetMedicines getMedicines;
  final AddMedicineWithSchedule addMedicineWithSchedule;
  final DeleteMedicineWithCleanup deleteMedicineWithCleanup;
  final UpdateMedicineWithReschedule updateMedicineWithReschedule;
  final SyncMedicines syncMedicines;
  final SyncManager syncManager;
  final MedicineRepository medicineRepository;

  PillboxBloc({
    required this.userId,
    required this.getMedicines,
    required this.addMedicineWithSchedule,
    required this.deleteMedicineWithCleanup,
    required this.updateMedicineWithReschedule,
    required this.syncMedicines,
    required this.syncManager,
    required this.medicineRepository,
  }) : super(PillboxInitial()) {
    on<LoadMedicines>(_onLoad);
    on<AddMedicineWithScheduleEvent>(_onAdd);
    on<DeleteMedicineWithCleanupEvent>(_onDelete);
    on<UpdateMedicineWithRescheduleEvent>(_onUpdate);
  }

  Future<void> _onLoad(LoadMedicines event, Emitter<PillboxState> emit) async {
    emit(PillboxLoading());

    try {
      final meds = await getMedicines();
      emit(PillboxLoaded(meds));

      unawaited(_triggerSync());
    } catch (e) {
      emit(PillboxError("Failed to load medicines"));
    }
  }

  Future<void> _onAdd(
    AddMedicineWithScheduleEvent event,
    Emitter<PillboxState> emit,
  ) async {
    try {
      await addMedicineWithSchedule(event.medicine);

      await Future.delayed(const Duration(milliseconds: 200));

      final meds = await getMedicines();
      emit(PillboxLoaded(meds, fromAdd: true));

      _triggerSync();
    } catch (e) {
      emit(PillboxError("Failed to add medicine"));
    }
  }

  Future<void> _onDelete(
    DeleteMedicineWithCleanupEvent event,
    Emitter<PillboxState> emit,
  ) async {
    try {
      await deleteMedicineWithCleanup(userId, event.medicineId);
      
      final meds = await getMedicines();
      emit(PillboxLoaded(meds));

      _triggerSync();
    } catch (e) {
      emit(PillboxError("Failed to delete medicine"));
    }
  }

  Future<void> _onUpdate(
    UpdateMedicineWithRescheduleEvent event,
    Emitter<PillboxState> emit,
  ) async {
    try {
      await updateMedicineWithReschedule(event.medicine);

      final meds = await getMedicines();
      emit(PillboxLoaded(meds));

      _triggerSync();
    } catch (e) {
      emit(PillboxError("Failed to update medicine"));
    }
  }

  Future<void> _triggerSync() async {
    syncManager.scheduleSync(() async {
      final meds = await medicineRepository.getMedicines();
      await syncMedicines(meds);
    });
  }
}
