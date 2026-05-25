// test/random_color_generator_test.dart

// ignore_for_file:

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:random_color_generator/random_color_generator.dart';

const _kN = 250;
const _kMinSaturation = 0.4;
const _kMaxSaturation = 0.8;
const _kMinLightness = 0.35;
const _kMaxLightness = 0.65;
const _kMaxAlpha = 255;

// HSL -> Color -> HSL roundtrip loses precision due to 8-bit RGB quantization.
// This epsilon absorbs that drift without masking real range violations.
const _kEpsilon = 0.005;

void main() {
  group('RandomColorGenerator.generate', () {
    test('returns a color with full alpha by default', () {
      final color = RandomColorGenerator.generate();
      final hsl = HSLColor.fromColor(color);
      expect(hsl.alpha, equals(1.0));
    });

    test('respects custom alpha value', () {
      const alpha = 128;
      final color = RandomColorGenerator.generate(alpha: alpha);
      final hsl = HSLColor.fromColor(color);
      expect(hsl.alpha, closeTo(alpha / _kMaxAlpha, 0.01));
    });

    test('saturation is within range across $_kN iterations', () {
      for (var i = 0; i < _kN; i++) {
        final hsl = HSLColor.fromColor(RandomColorGenerator.generate());
        expect(
          hsl.saturation,
          inInclusiveRange(
            _kMinSaturation - _kEpsilon,
            _kMaxSaturation + _kEpsilon,
          ),
          reason: 'iteration $i: saturation ${hsl.saturation} out of range',
        );
      }
    });

    test('lightness is within range across $_kN iterations', () {
      for (var i = 0; i < _kN; i++) {
        final hsl = HSLColor.fromColor(RandomColorGenerator.generate());
        expect(
          hsl.lightness,
          inInclusiveRange(
            _kMinLightness - _kEpsilon,
            _kMaxLightness + _kEpsilon,
          ),
          reason: 'iteration $i: lightness ${hsl.lightness} out of range',
        );
      }
    });

    test('hue is within 0-360 across $_kN iterations', () {
      for (var i = 0; i < _kN; i++) {
        final hsl = HSLColor.fromColor(RandomColorGenerator.generate());
        expect(
          hsl.hue,
          inInclusiveRange(0.0, 360.0),
          reason: 'iteration $i: hue ${hsl.hue} out of range',
        );
      }
    });
  });

  group('RandomColorGenerator.isGenerated', () {
    test('returns true for a color within generation range', () {
      final color = const HSLColor.fromAHSL(1.0, 180.0, 0.6, 0.5).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isTrue);
    });

    test('returns false when saturation is below minimum', () {
      final color = const HSLColor.fromAHSL(1.0, 180.0, 0.2, 0.5).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isFalse);
    });

    test('returns false when saturation is above maximum', () {
      final color = const HSLColor.fromAHSL(1.0, 180.0, 0.9, 0.5).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isFalse);
    });

    test('returns false when lightness is below minimum', () {
      final color = const HSLColor.fromAHSL(1.0, 180.0, 0.6, 0.1).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isFalse);
    });

    test('returns false when lightness is above maximum', () {
      final color = const HSLColor.fromAHSL(1.0, 180.0, 0.6, 0.9).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isFalse);
    });

    test('returns true at saturation lower boundary', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        90.0,
        _kMinSaturation,
        0.5,
      ).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isTrue);
    });

    test('returns true at saturation upper boundary', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        90.0,
        _kMaxSaturation,
        0.5,
      ).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isTrue);
    });

    test('returns true at lightness lower boundary', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        90.0,
        0.6,
        _kMinLightness,
      ).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isTrue);
    });

    test('returns true at lightness upper boundary', () {
      final color = const HSLColor.fromAHSL(
        1.0,
        90.0,
        0.6,
        _kMaxLightness,
      ).toColor();
      expect(RandomColorGenerator.isGenerated(color: color), isTrue);
    });

    test('returns true for all $_kN generated colors', () {
      for (var i = 0; i < _kN; i++) {
        final color = RandomColorGenerator.generate();
        expect(
          RandomColorGenerator.isGenerated(color: color),
          isTrue,
          reason: 'iteration $i: generated color failed isGenerated',
        );
      }
    });
  });

  group('RandomColorGenerator.toHex', () {
    test('returns correct hex for opaque red', () {
      expect(
        RandomColorGenerator.toHex(const Color(0xFFFF0000)),
        equals('#FFFF0000'),
      );
    });

    test('returns correct hex for opaque green', () {
      expect(
        RandomColorGenerator.toHex(const Color(0xFF00FF00)),
        equals('#FF00FF00'),
      );
    });

    test('returns correct hex for opaque blue', () {
      expect(
        RandomColorGenerator.toHex(const Color(0xFF0000FF)),
        equals('#FF0000FF'),
      );
    });

    test('returns correct hex for fully transparent black', () {
      expect(
        RandomColorGenerator.toHex(const Color(0x00000000)),
        equals('#00000000'),
      );
    });

    test('returns correct hex for semi-transparent white', () {
      expect(
        RandomColorGenerator.toHex(const Color(0x80FFFFFF)),
        equals('#80FFFFFF'),
      );
    });

    test('output is always uppercase', () {
      final hex = RandomColorGenerator.toHex(const Color(0xFFABCDEF));
      expect(hex, equals(hex.toUpperCase()));
    });

    test('output always starts with #', () {
      final hex = RandomColorGenerator.toHex(const Color(0xFFFF0000));
      expect(hex, startsWith('#'));
    });

    test('output is always 9 characters (#AARRGGBB)', () {
      final hex = RandomColorGenerator.toHex(const Color(0xFFFF0000));
      expect(hex.length, equals(9));
    });
  });

  group('RandomColorGenerator.fromHex', () {
    test('parses opaque red', () {
      expect(
        RandomColorGenerator.fromHex('#FFFF0000'),
        equals(const Color(0xFFFF0000)),
      );
    });

    test('parses opaque blue', () {
      expect(
        RandomColorGenerator.fromHex('#FF0000FF'),
        equals(const Color(0xFF0000FF)),
      );
    });

    test('parses fully transparent black', () {
      expect(
        RandomColorGenerator.fromHex('#00000000'),
        equals(const Color(0x00000000)),
      );
    });

    test('parses semi-transparent white', () {
      expect(
        RandomColorGenerator.fromHex('#80FFFFFF'),
        equals(const Color(0x80FFFFFF)),
      );
    });

    test('strips leading # before parsing', () {
      expect(
        () => RandomColorGenerator.fromHex('#FFAABBCC'),
        returnsNormally,
      );
    });
  });

  group('RandomColorGenerator toHex/fromHex roundtrip', () {
    test('roundtrip preserves opaque red', () {
      const color = Color(0xFFFF0000);
      expect(
        RandomColorGenerator.fromHex(RandomColorGenerator.toHex(color)),
        equals(color),
      );
    });

    test('roundtrip preserves semi-transparent green', () {
      const color = Color(0x8000FF00);
      expect(
        RandomColorGenerator.fromHex(RandomColorGenerator.toHex(color)),
        equals(color),
      );
    });

    test('roundtrip preserves $_kN generated colors', () {
      for (var i = 0; i < _kN; i++) {
        final color = RandomColorGenerator.generate();
        final roundtripped = RandomColorGenerator.fromHex(
          RandomColorGenerator.toHex(color),
        );
        expect(
          roundtripped,
          equals(color),
          reason: 'iteration $i: roundtrip failed',
        );
      }
    });
  });
}
