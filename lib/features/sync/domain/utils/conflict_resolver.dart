class ConflictResolver {
  static List<T> resolve<T extends dynamic>({
    required List<T> local,
    required List<T> remote,
    required String Function(T) getId,
    required DateTime Function(T) getUpdatedAt,
  }) {
    final Map<String, T> map = {};

    for (final item in local) {
      map[getId(item)] = item;
    }

    for (final item in remote) {
      final id = getId(item);
      final localItem = map[id];

      if (localItem == null) {
        map[id] = item;
      } else {
        if (getUpdatedAt(item).isAfter(getUpdatedAt(localItem))) {
          map[id] = item;
        }
      }
    }

    return map.values.toList();
  }
}
