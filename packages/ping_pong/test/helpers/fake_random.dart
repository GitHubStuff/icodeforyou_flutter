// packages/ping_pong/test/helpers/fake_random.dart

import 'dart:collection' show Queue;
import 'dart:math' show Random;

/// A [Random] that returns a scripted sequence of doubles.
///
/// The physics only ever call [nextDouble], so the integer and boolean
/// members are deliberately unimplemented: a call to them is a bug.
class FakeRandom implements Random {
  /// Returns the given [doubles] in order, then throws.
  FakeRandom(Iterable<double> doubles) : _doubles = Queue.of(doubles);

  /// Returns [value] forever.
  FakeRandom.constant(double value) : _doubles = Queue(), _constant = value;

  final Queue<double> _doubles;
  double? _constant;

  /// How many doubles have been handed out so far.
  int calls = 0;

  @override
  double nextDouble() {
    calls++;
    final constant = _constant;
    if (constant != null) return constant;
    if (_doubles.isEmpty) {
      throw StateError('FakeRandom ran out of scripted doubles');
    }
    return _doubles.removeFirst();
  }

  @override
  bool nextBool() => throw UnimplementedError('nextBool is not scripted');

  @override
  int nextInt(int max) => throw UnimplementedError('nextInt is not scripted');
}
