// packages/extensions/test/iterable/iterable_ext_test.dart

import 'package:extensions/iterable/iterable_ext.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal node type for exercising [IterableExt.checkForCycles].
typedef _Node = ({String id, List<String> needs});

void main() {
  group('IterableExt.checkForCycles', () {
    void check(List<_Node> nodes) => nodes.checkForCycles(
      idOf: (node) => node.id,
      dependenciesOf: (node) => node.needs,
    );

    test('returns normally for an acyclic chain', () {
      expect(
        () => check([
          (id: 'a', needs: ['b']),
          (id: 'b', needs: ['c']),
          (id: 'c', needs: <String>[]),
        ]),
        returnsNormally,
      );
    });

    test('returns normally for a diamond via the visited short-circuit', () {
      expect(
        () => check([
          (id: 'a', needs: ['b', 'c']),
          (id: 'b', needs: ['d']),
          (id: 'c', needs: ['d']),
          (id: 'd', needs: <String>[]),
        ]),
        returnsNormally,
      );
    });

    test('throws a StateError naming the cycle path', () {
      expect(
        () => check([
          (id: 'a', needs: ['b']),
          (id: 'b', needs: ['c']),
          (id: 'c', needs: ['a']),
        ]),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Circular dependency detected: a -> b -> c -> a',
          ),
        ),
      );
    });

    test('throws a StateError for a self-dependency', () {
      expect(
        () => check([
          (id: 'a', needs: ['a']),
        ]),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Circular dependency detected: a -> a',
          ),
        ),
      );
    });

    test('throws a StateError naming an unknown dependency', () {
      expect(
        () => check([
          (id: 'a', needs: ['ghost']),
        ]),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Unknown dependency "ghost" during cycle check.',
          ),
        ),
      );
    });

    test('later element wins when two elements share an identifier', () {
      // The first `a` depends on a missing node; the second overwrites it in
      // the lookup map, so the check passes.
      expect(
        () => check([
          (id: 'a', needs: ['ghost']),
          (id: 'a', needs: <String>[]),
        ]),
        returnsNormally,
      );
    });
  });
}
