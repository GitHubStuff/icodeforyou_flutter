// clock_models_test.dart
// ignore_for_file: use_named_constants

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('_ClockColors.hashCode (via helpers)', () {
    test('same inputs => same hash', () {
      final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0));
      const style = ClockStyle(); // all nulls → resolved from theme
      final h1 = debugClockColorsHash(colorScheme: cs, style: style);
      final h2 = debugClockColorsHash(
        colorScheme: cs,
        style: const ClockStyle(),
      );
      expect(h1, equals(h2));
    });

    test('different theme => different hash', () {
      final csA = ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0));
      final csB = ColorScheme.fromSeed(seedColor: const Color(0xFFD32F2F));
      const style = ClockStyle();
      final hA = debugClockColorsHash(colorScheme: csA, style: style);
      final hB = debugClockColorsHash(colorScheme: csB, style: style);
      expect(hA, isNot(hB));
    });

    test('explicit color override changes hash', () {
      final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3));
      const base = ClockStyle();
      const override = ClockStyle(borderColor: Color(0xFF00FF00));
      final hBase = debugClockColorsHash(colorScheme: cs, style: base);
      final hOverride = debugClockColorsHash(colorScheme: cs, style: override);
      expect(hBase, isNot(hOverride));
    });
  });

  group('_ClockDimensions.hashCode (via helpers)', () {
    test('same radius => same hash', () {
      expect(
        debugClockDimensionsHash(80),
        equals(debugClockDimensionsHash(80)),
      );
    });

    test('different radius => different hash', () {
      expect(
        debugClockDimensionsHash(80),
        isNot(debugClockDimensionsHash(96)),
      );
    });
  });

  group('_ClockConfiguration.hashCode (via helpers)', () {
    test('same (radius, theme, style instance) => same hash', () {
      final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2));
      const style = ClockStyle(
        
      );
      final h1 = debugClockConfigurationHash(
        radius: 100,
        colorScheme: cs,
        style: style,
      );
      final h2 = debugClockConfigurationHash(
        radius: 100,
        colorScheme: cs,
        style: style,
      );
      expect(h1, equals(h2));
    });

    test('different radius => different hash', () {
      final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2));
      const style = ClockStyle();
      final h1 = debugClockConfigurationHash(
        radius: 90,
        colorScheme: cs,
        style: style,
      );
      final h2 = debugClockConfigurationHash(
        radius: 120,
        colorScheme: cs,
        style: style,
      );
      expect(h1, isNot(h2));
    });

    test('different theme => different hash', () {
      final cs1 = ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2));
      final cs2 = ColorScheme.fromSeed(seedColor: const Color(0xFFFF5722));
      const style = ClockStyle();
      final h1 = debugClockConfigurationHash(
        radius: 100,
        colorScheme: cs1,
        style: style,
      );
      final h2 = debugClockConfigurationHash(
        radius: 100,
        colorScheme: cs2,
        style: style,
      );
      expect(h1, isNot(h2));
    });

    test('different style => different hash', () {
      final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2));
      const a = ClockStyle(
        
      );
      const b = ClockStyle(
        handStyle: HandStyle.modern,
      );
      final hA = debugClockConfigurationHash(
        radius: 100,
        colorScheme: cs,
        style: a,
      );
      final hB = debugClockConfigurationHash(
        radius: 100,
        colorScheme: cs,
        style: b,
      );
      expect(hA, isNot(hB));
    });
  });
}
