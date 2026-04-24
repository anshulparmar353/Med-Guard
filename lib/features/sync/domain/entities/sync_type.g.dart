// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncTypeAdapter extends TypeAdapter<SyncType> {
  @override
  final int typeId = 6;

  @override
  SyncType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncType.add;
      case 1:
        return SyncType.update;
      case 2:
        return SyncType.delete;
      case 3:
        return SyncType.updateDose;
      default:
        return SyncType.add;
    }
  }

  @override
  void write(BinaryWriter writer, SyncType obj) {
    switch (obj) {
      case SyncType.add:
        writer.writeByte(0);
        break;
      case SyncType.update:
        writer.writeByte(1);
        break;
      case SyncType.delete:
        writer.writeByte(2);
        break;
      case SyncType.updateDose:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
