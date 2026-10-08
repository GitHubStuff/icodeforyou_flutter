// packages/ping_pong/test/src/arena_config_test.dart
import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong/src/arena_config.dart';
import 'package:ping_pong/src/ball_spec.dart';

void main() {
  const specs = [
    BallSpec(radius: 10, speed: 50),
    BallSpec(radius: 20, speed: 30),
  ];

  const config = ArenaConfig(
    bounds: Size(300, 200),
    specs: specs,
    spawnInterval: Duration(seconds: 1),
    retryCap: 25,
    motionless: false,
    recycle: true,
  );

  /// A copy of [config] with one field replaced.
  ArenaConfig variant({
    Size? bounds,
    List<BallSpec>? specs,
    Duration? spawnInterval,
    int? retryCap,
    bool? motionless,
    bool? recycle,
  }) => ArenaConfig(
    bounds: bounds ?? config.bounds,
    specs: specs ?? config.specs,
    spawnInterval: spawnInterval ?? config.spawnInterval,
    retryCap: retryCap ?? config.retryCap,
    motionless: motionless ?? config.motionless,
    recycle: recycle ?? config.recycle,
  );

  group('ArenaConfig', () {
    test('exposes its fields', () {
      expect(config.bounds, const Size(300, 200));
      expect(config.specs, specs);
      expect(config.spawnInterval, const Duration(seconds: 1));
      expect(config.retryCap, 25);
      expect(config.motionless, isFalse);
      expect(config.recycle, isTrue);
    });

    test('is equal to a config with the same values', () {
      final same = variant();

      expect(config, equals(same));
      expect(config.hashCode, equals(same.hashCode));
    });

    test('compares specs by value, not identity', () {
      final rebuilt = variant(
        specs: [
          for (final spec in specs)
            BallSpec(radius: spec.radius, speed: spec.speed),
        ],
      );

      expect(config, equals(rebuilt));
    });

    test('differs when bounds differ', () {
      expect(config, isNot(equals(variant(bounds: const Size(200, 300)))));
    });

    test('differs when specs differ', () {
      expect(
        config,
        isNot(equals(variant(specs: const [BallSpec(radius: 10, speed: 50)]))),
      );
    });

    test('differs when spec order differs', () {
      expect(
        config,
        isNot(
          equals(
            variant(
              specs: const [
                BallSpec(radius: 20, speed: 30),
                BallSpec(radius: 10, speed: 50),
              ],
            ),
          ),
        ),
      );
    });

    test('differs when spawn interval differs', () {
      expect(
        config,
        isNot(equals(variant(spawnInterval: const Duration(seconds: 2)))),
      );
    });

    test('differs when retry cap differs', () {
      expect(config, isNot(equals(variant(retryCap: 10))));
    });

    test('differs when motionless differs', () {
      expect(config, isNot(equals(variant(motionless: true))));
    });

    test('differs when recycle differs', () {
      expect(config, isNot(equals(variant(recycle: false))));
    });

    test('props lists every field in declaration order', () {
      expect(
        config.props,
        [
          const Size(300, 200),
          specs,
          const Duration(seconds: 1),
          25,
          false,
          true,
        ],
      );
    });

    test('rejects a zero retry cap', () {
      expect(() => variant(retryCap: 0), throwsAssertionError);
    });

    test('rejects a negative retry cap', () {
      expect(() => variant(retryCap: -1), throwsAssertionError);
    });
  });
}
