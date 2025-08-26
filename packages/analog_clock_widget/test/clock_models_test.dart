// clock_models_test.dart
import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('_ClockColors.hashCode (via helpers)', () {
    test('same inputs => same hash', () {
      final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0));
      final style = const ClockStyle(); // all nulls → resolved from theme
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
      final style = const ClockStyle();
      final hA = debugClockColorsHash(colorScheme: csA, style: style);
      final hB = debugClockColorsHash(colorScheme: csB, style: style);
      expect(hA, isNot(hB));
    });

    test('explicit color override changes hash', () {
      final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3));
      final base = const ClockStyle();
      final override = const ClockStyle(borderColor: Color(0xFF00FF00));
      final hBase = debugClockColorsHash(colorScheme: cs, style: base);
      final hOverride = debugClockColorsHash(colorScheme: cs, style: override);
      expect(hBase, isNot(hOverride));
    });
  });

  group('_ClockDimensions.hashCode (via helpers)', () {
    test('same radius => same hash', () {
      expect(
        debugClockDimensionsHash(80.0),
        equals(debugClockDimensionsHash(80.0)),
      );
    });

    test('different radius => different hash', () {
      expect(
        debugClockDimensionsHash(80.0),
        isNot(debugClockDimensionsHash(96.0)),
      );
    });
  });

  group('_ClockConfiguration.hashCode (via helpers)', () {
    test('same (radius, theme, style instance) => same hash', () {
      final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2));
      final style = const ClockStyle(
        faceStyle: ClockFaceStyle.classic,
        handStyle: HandStyle.traditional,
        showSecondHand: true,
        showNumbers: true,
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
      final style = const ClockStyle();
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
      final style = const ClockStyle();
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
      final a = const ClockStyle(
        handStyle: HandStyle.traditional,
        showNumbers: true,
      );
      final b = const ClockStyle(
        handStyle: HandStyle.modern,
        showNumbers: true,
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
