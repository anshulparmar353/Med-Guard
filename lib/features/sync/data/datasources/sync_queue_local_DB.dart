// ignore_for_file: file_names

import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';

class SyncQueueLocalDataSource {
  final Box<SyncItem> box;

  SyncQueueLocalDataSource(this.box);

  Future<void> add(SyncItem item) async {
    print("ADDING TO QUEUE");
    await box.put(item.id, item);
  }

  List<SyncItem> getAll() {
    final items = box.values.toList();

    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return items;
  }

  Future<void> remove(String id) async {
    await box.delete(id);
  }

  Future<void> incrementRetry(String id) async {
    final item = box.get(id);
    if (item != null) {
      item.retryCount += 1;
      await item.save();
    }
  }

  Future<void> clear() async {
    await box.clear();
  }
}
