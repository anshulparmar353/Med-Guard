import 'package:hive/hive.dart';
import 'package:med_guard/features/sync/domain/entities/sync_type.dart';

@HiveType(typeId: 3)
class SyncItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final SyncType type;

  @HiveField(2)
  final Map<String, dynamic> data;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  int retryCount;

  SyncItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });
}
