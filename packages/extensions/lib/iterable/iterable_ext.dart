// packages/extensions/lib/iterable/iterable_ext.dart

/// Convenience helpers on [Iterable] for treating its elements as nodes in a
/// dependency graph.
/// NOTE: Developed for Creating/Registering services that have dependencies.
///
extension IterableExt<T> on Iterable<T> {
  /// Verifies that the elements of this iterable form an acyclic dependency
  /// graph.
  ///
  /// Each element is treated as a node. [idOf] extracts the unique identifier
  /// for a node, and [dependenciesOf] returns the identifiers of the nodes it
  /// depends on. The graph is walked depth-first; a back edge to a node still
  /// on the current path indicates a cycle.
  ///
  /// Returns normally when no cycle exists. Otherwise it throws a [StateError]:
  /// - if a cycle is found, the message lists the offending path, e.g.
  ///   `Circular dependency detected: a -> b -> c -> a`;
  /// - if a dependency identifier has no matching element in this iterable, the
  ///   message names the missing identifier.
  ///
  /// Identifiers produced by [idOf] are assumed to be unique. When two elements
  /// share an identifier, the later element in iteration order wins, since the
  /// lookup map is built by overwriting earlier entries.
  ///
  /// ```dart
  /// final tasks = [
  ///   (id: 'a', needs: <String>['b']),
  ///   (id: 'b', needs: <String>['c']),
  ///   (id: 'c', needs: <String>[]),
  /// ];
  /// tasks.checkForCycles(
  ///   idOf: (task) => task.id,
  ///   dependenciesOf: (task) => task.needs,
  /// ); // Returns normally.
  /// ```
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
