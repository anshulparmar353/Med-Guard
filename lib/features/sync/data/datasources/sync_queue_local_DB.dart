// ignore_for_file: file_names

import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/features/sync/data/models/sync_model.dart';

class SyncQueueLocalDataSource {
  final Box<SyncItem> box;

  SyncQueueLocalDataSource(this.box);

  Future<void> add(SyncItem item) async {
    await box.put(item.id, item);
  }

  List<SyncItem> getAll() => box.values.toList();

  Future<void> remove(String id) async {
    await box.delete(id);
  }

  Future<void> clear() async {
    await box.clear();
  }
}