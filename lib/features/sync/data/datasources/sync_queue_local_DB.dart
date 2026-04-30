// ignore_for_file: file_names

import 'package:hive_flutter/adapters.dart';
import 'package:med_guard/features/sync/data/models/sync_item.dart';

class SyncQueueLocalDataSource {
  final Box<SyncItem> box;

  SyncQueueLocalDataSource(this.box);

  // ================= ADD =================

  Future<void> add(SyncItem item) async {
    print("📥 ADDING TO SYNC QUEUE: ${item.id}");
    await box.put(item.id, item);
  }

  // ================= GET ALL =================

  List<SyncItem> getAll() {
    final items = box.values.toList();

    // sort by createdAt (oldest first)
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return items;
  }

  // ================= REMOVE =================

  Future<void> remove(String id) async {
    print("🗑️ REMOVED FROM QUEUE: $id");
    await box.delete(id);
  }

  // ================= RETRY =================

  Future<void> incrementRetry(String id) async {
    final item = box.get(id);

    if (item != null) {
      final updated = SyncItem(
        id: item.id,
        type: item.type,
        data: item.data,
        createdAt: item.createdAt,
        retryCount: item.retryCount + 1,
      );

      await box.put(id, updated);

      print("🔁 RETRY COUNT INCREASED: ${updated.retryCount}");
    }
  }

  // ================= CLEAR =================

  Future<void> clear() async {
    await box.clear();
    print("🧹 SYNC QUEUE CLEARED");
  }
}
