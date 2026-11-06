// packages/sequenced_animations/test/src/sequenced_animations_test.dart

import 'package:test/test.dart';

import '../../lib/sequenced_animations.dart' show SequencedAnimations;

void main() {
  group('SequencedAnimations', () {
    late SequencedAnimations sequencedAnimations;

    setUp(() {
      sequencedAnimations = SequencedAnimations();
    });

    test('can be instantiated', () {
      expect(sequencedAnimations, isA<SequencedAnimations>());
    });
  });
}
