// ignore_for_file: public_member_api_docs

extension IterableExt<T> on Iterable<T> {
  void checkForCycles({
    required String Function(T item) idOf,
    required Iterable<String> Function(T item) dependenciesOf,
  }) {
    final Map<String, T> byId = <String, T>{
      for (final item in this) idOf(item): item,
    };

    final Set<String> visiting = <String>{};
    final Set<String> visited = <String>{};

    void visit(String id, List<String> path) {
      if (visited.contains(id)) return;

      if (visiting.contains(id)) {
        final int start = path.indexOf(id);
        final cycle = <String>[
          ...path.sublist(start),
          id,
        ].join(' -> ');
        throw StateError('Circular dependency detected: $cycle');
      }

      final T? item = byId[id];
      if (item == null) {
        throw StateError('Unknown dependency "$id" during cycle check.');
      }

      visiting.add(id);
      path.add(id);

      for (final dependency in dependenciesOf(item)) {
        visit(dependency, path);
      }

      path.removeLast();
      visiting.remove(id);
      visited.add(id);
    }

    for (final item in this) {
      visit(idOf(item), <String>[]);
    }
  }
}
