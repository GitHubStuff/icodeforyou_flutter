// extensions/test/iterable_ext/iterable_ext_test.dart
import 'package:extensions/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

class _Node {
  const _Node(this.id, this.deps);

  final String id;
  final List<String> deps;
}

String _idOf(_Node n) => n.id;

List<String> _depsOf(_Node n) => n.deps;

void main() {
  group('IterableExt.checkForCycles', () {
    test('completes silently for an empty iterable', () {
      expect(
        () => <_Node>[].checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
        returnsNormally,
      );
    });

    test('completes silently for a single node with no dependencies', () {
      const nodes = [_Node('a', [])];

      expect(
        () => nodes.checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
        returnsNormally,
      );
    });

    test('completes silently for a linear dependency chain', () {
      const nodes = [
        _Node('a', ['b']),
        _Node('b', ['c']),
        _Node('c', []),
      ];

      expect(
        () => nodes.checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
        returnsNormally,
      );
    });

    test('completes silently for a diamond (shared dependency, no cycle)', () {
      // a -> b -> d
      // a -> c -> d
      // 'd' is visited via 'b', then re-encountered via 'c' — this exercises
      // the `visited.contains(id)` early-return.
      const nodes = [
        _Node('a', ['b', 'c']),
        _Node('b', ['d']),
        _Node('c', ['d']),
        _Node('d', []),
      ];

      expect(
        () => nodes.checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
        returnsNormally,
      );
    });

    test('throws StateError on a self-referential cycle', () {
      const nodes = [
        _Node('a', ['a']),
      ];

      expect(
        () => nodes.checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('Circular dependency detected'), contains('a -> a')),
          ),
        ),
      );
    });

    test('throws StateError on a two-node cycle', () {
      const nodes = [
        _Node('a', ['b']),
        _Node('b', ['a']),
      ];

      expect(
        () => nodes.checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('Circular dependency detected'),
              contains('a -> b -> a'),
            ),
          ),
        ),
      );
    });

    test('throws StateError on a longer cycle, reporting the full path', () {
      const nodes = [
        _Node('a', ['b']),
        _Node('b', ['c']),
        _Node('c', ['a']),
      ];

      expect(
        () => nodes.checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('a -> b -> c -> a'),
          ),
        ),
      );
    });

    test(
      'reports the cycle starting at the first revisited id, '
      'not the entry point',
      () {
        // a -> b -> c -> b: the cycle is b -> c -> b, even though traversal
        // entered through 'a'. The path slice should start at 'b'.
        const nodes = [
          _Node('a', ['b']),
          _Node('b', ['c']),
          _Node('c', ['b']),
        ];

        expect(
          () => nodes.checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              allOf(contains('b -> c -> b'), isNot(contains('a -> b -> c'))),
            ),
          ),
        );
      },
    );

    test('throws StateError when a dependency id is unknown', () {
      const nodes = [
        _Node('a', ['ghost']),
      ];

      expect(
        () => nodes.checkForCycles(idOf: _idOf, dependenciesOf: _depsOf),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('Unknown dependency'), contains('ghost')),
          ),
        ),
      );
    });
  });
}
