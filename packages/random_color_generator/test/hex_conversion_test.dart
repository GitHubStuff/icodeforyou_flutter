import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:random_color_generator/random_color_generator.dart';

void main() {
  group('RandomColorGenerator.toHex', () {
    test('returns uppercase hex string with # prefix', () {
      const color = Color(0xFFAABBCC);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, startsWith('#'));
      expect(hex, equals(hex.toUpperCase()));
    });

    test('converts fully opaque white correctly', () {
      const color = Color(0xFFFFFFFF);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, equals('#FFFFFFFF'));
    });

    test('converts fully opaque black correctly', () {
      const color = Color(0xFF000000);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, equals('#FF000000'));
    });

    test('converts fully transparent black correctly', () {
      const color = Color(0x00000000);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, equals('#00000000'));
    });

    test('converts red correctly', () {
      const color = Color(0xFFFF0000);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, equals('#FFFF0000'));
    });

    test('converts green correctly', () {
      const color = Color(0xFF00FF00);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, equals('#FF00FF00'));
    });

    test('converts blue correctly', () {
      const color = Color(0xFF0000FF);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, equals('#FF0000FF'));
    });

    test('converts semi-transparent color correctly', () {
      const color = Color(0x80FF8040);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, equals('#80FF8040'));
    });

    test('hex string has exactly 9 characters (# + 8 hex digits)', () {
      const color = Color(0x01020304);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex.length, equals(9));
    });

    test('pads single-digit channel values with leading zeros', () {
      const color = Color(0x01020304);
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, equals('#01020304'));
    });

    test('converts a randomly generated color without error', () {
      final color = RandomColorGenerator.generate();
      final hex = RandomColorGenerator.toHex(color);
      expect(hex, matches(RegExp(r'^#[0-9A-F]{8}$')));
    });
  });

  group('RandomColorGenerator.fromHex', () {
    test('parses hex string with # prefix', () {
      final color = RandomColorGenerator.fromHex('#FFAABBCC');
      expect((color.a * 255.0).round(), equals(255));
      expect((color.r * 255.0).round(), equals(0xAA));
      expect((color.g * 255.0).round(), equals(0xBB));
      expect((color.b * 255.0).round(), equals(0xCC));
    });

    test('parses hex string without # prefix', () {
      final color = RandomColorGenerator.fromHex('FFAABBCC');
      expect((color.a * 255.0).round(), equals(255));
      expect((color.r * 255.0).round(), equals(0xAA));
    });

    test('parses fully opaque white', () {
      final color = RandomColorGenerator.fromHex('#FFFFFFFF');
      expect((color.a * 255.0).round(), equals(255));
      expect((color.r * 255.0).round(), equals(255));
      expect((color.g * 255.0).round(), equals(255));
      expect((color.b * 255.0).round(), equals(255));
    });

    test('parses fully opaque black', () {
      final color = RandomColorGenerator.fromHex('#FF000000');
      expect((color.a * 255.0).round(), equals(255));
      expect((color.r * 255.0).round(), equals(0));
      expect((color.g * 255.0).round(), equals(0));
      expect((color.b * 255.0).round(), equals(0));
    });

    test('parses fully transparent color', () {
      final color = RandomColorGenerator.fromHex('#00000000');
      expect((color.a * 255.0).round(), equals(0));
    });

    test('parses semi-transparent color', () {
      final color = RandomColorGenerator.fromHex('#80FF8040');
      expect((color.a * 255.0).round(), equals(0x80));
      expect((color.r * 255.0).round(), equals(0xFF));
      expect((color.g * 255.0).round(), equals(0x80));
      expect((color.b * 255.0).round(), equals(0x40));
    });

    test('parses lowercase hex string', () {
      final color = RandomColorGenerator.fromHex('#ffaabbcc');
      expect((color.r * 255.0).round(), equals(0xAA));
      expect((color.g * 255.0).round(), equals(0xBB));
      expect((color.b * 255.0).round(), equals(0xCC));
    });

    test('parses mixed-case hex string', () {
      final color = RandomColorGenerator.fromHex('#FfAaBbCc');
      expect((color.r * 255.0).round(), equals(0xAA));
    });
  });

  group('toHex and fromHex roundtrip', () {
    test('roundtrip preserves fully opaque color', () {
      const original = Color(0xFFAABBCC);
      final hex = RandomColorGenerator.toHex(original);
      final restored = RandomColorGenerator.fromHex(hex);
      expect((restored.a * 255.0).round(), equals(255));
      expect((restored.r * 255.0).round(), equals(0xAA));
      expect((restored.g * 255.0).round(), equals(0xBB));
      expect((restored.b * 255.0).round(), equals(0xCC));
    });

    test('roundtrip preserves semi-transparent color', () {
      const original = Color(0x80FF8040);
      final hex = RandomColorGenerator.toHex(original);
      final restored = RandomColorGenerator.fromHex(hex);
      expect((restored.a * 255.0).round(), equals(0x80));
      expect((restored.r * 255.0).round(), equals(0xFF));
      expect((restored.g * 255.0).round(), equals(0x80));
      expect((restored.b * 255.0).round(), equals(0x40));
    });

    test('roundtrip preserves a randomly generated color', () {
      final original = RandomColorGenerator.generate();
      final hex = RandomColorGenerator.toHex(original);
      final restored = RandomColorGenerator.fromHex(hex);
      expect(
        (restored.r * 255.0).round(),
        closeTo((original.r * 255.0).round(), 1),
      );
      expect(
        (restored.g * 255.0).round(),
        closeTo((original.g * 255.0).round(), 1),
      );
      expect(
        (restored.b * 255.0).round(),
        closeTo((original.b * 255.0).round(), 1),
      );
    });

    test('roundtrip with black', () {
      const original = Color(0xFF000000);
      final hex = RandomColorGenerator.toHex(original);
      final restored = RandomColorGenerator.fromHex(hex);
      expect((restored.r * 255.0).round(), equals(0));
      expect((restored.g * 255.0).round(), equals(0));
      expect((restored.b * 255.0).round(), equals(0));
    });

    test('roundtrip with white', () {
      const original = Color(0xFFFFFFFF);
      final hex = RandomColorGenerator.toHex(original);
      final restored = RandomColorGenerator.fromHex(hex);
      expect((restored.r * 255.0).round(), equals(255));
      expect((restored.g * 255.0).round(), equals(255));
      expect((restored.b * 255.0).round(), equals(255));
    });
  });
}
