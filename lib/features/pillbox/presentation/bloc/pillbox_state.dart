import '../../domain/entities/medicine.dart';

abstract class PillboxState {}

class PillboxInitial extends PillboxState {}

class PillboxLoading extends PillboxState {}

class PillboxLoaded extends PillboxState {
  final List<Medicine> medicines;

  PillboxLoaded(this.medicines);
}

class PillboxError extends PillboxState {
  final String message;

  PillboxError(this.message);
}