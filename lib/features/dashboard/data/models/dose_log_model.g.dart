// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoseLogModelAdapter extends TypeAdapter<DoseLogModel> {
  @override
  final int typeId = 1;

  @override
  DoseLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoseLogModel(
      id: fields[0] as String,
      medicineId: fields[1] as String,
      medicineName: fields[2] as String,
      scheduledTime: fields[3] as DateTime,
      takenAt: fields[4] as DateTime?,
      status: fields[5] as String,
      updatedAt: fields[6] as DateTime,
      notificationId: fields[8] as int,
      isDeleted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DoseLogModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineId)
      ..writeByte(2)
      ..write(obj.medicineName)
      ..writeByte(3)
      ..write(obj.scheduledTime)
      ..writeByte(4)
      ..write(obj.takenAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
