import 'package:hive/hive.dart';

part 'sync_type.g.dart';

@HiveType(typeId: 6) 
enum SyncType {
  @HiveField(0)
  add,

  @HiveField(1)
  update,

  @HiveField(2)
  delete,

  @HiveField(3)
  updateDose,

}