// test/platform_optimizer_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:animated_checkbox_widget/animated_checkbox_widget.dart';

// Mock platform detectors for 100% coverage
class MockWebPlatformIdentifier extends PlatformIdentifier {
  @override
  bool get isWeb => true;
  @override
  bool get isIOS => false;
  @override
  bool get isAndroid => false;
  @override
  bool get isMacOS => false;
  @override
  bool get isWindows => false;
  @override
  bool get isLinux => false;
  @override
  String get platformName => 'Web';
}

class MockIOSPlatformIdentifier extends PlatformIdentifier {
  @override
  bool get isWeb => false;
  @override
  bool get isIOS => true;
  @override
  bool get isAndroid => false;
  @override
  bool get isMacOS => false;
  @override
  bool get isWindows => false;
  @override
  bool get isLinux => false;
  @override
  String get platformName => 'iOS';
}

class MockAndroidPlatformIdentifier extends PlatformIdentifier {
  @override
  bool get isWeb => false;
  @override
  bool get isIOS => false;
  @override
  bool get isAndroid => true;
  @override
  bool get isMacOS => false;
  @override
  bool get isWindows => false;
  @override
  bool get isLinux => false;
  @override
  String get platformName => 'Android';
}

class MockMacOSPlatformIdentifier extends PlatformIdentifier {
  @override
  bool get isWeb => false;
  @override
  bool get isIOS => false;
  @override
  bool get isAndroid => false;
  @override
  bool get isMacOS => true;
  @override
  bool get isWindows => false;
  @override
  bool get isLinux => false;
  @override
  String get platformName => 'macOS';
}

class MockWindowsPlatformIdentifier extends PlatformIdentifier {
  @override
  bool get isWeb => false;
  @override
  bool get isIOS => false;
  @override
  bool get isAndroid => false;
  @override
  bool get isMacOS => false;
  @override
  bool get isWindows => true;
  @override
  bool get isLinux => false;
  @override
  String get platformName => 'Windows';
}

class MockLinuxPlatformIdentifier extends PlatformIdentifier {
  @override
  bool get isWeb => false;
  @override
  bool get isIOS => false;
  @override
  bool get isAndroid => false;
  @override
  bool get isMacOS => false;
  @override
  bool get isWindows => false;
  @override
  bool get isLinux => true;
  @override
  String get platformName => 'Linux';
}

class MockUnknownPlatformIdentifier extends PlatformIdentifier {
  @override
  bool get isWeb => false;
  @override
  bool get isIOS => false;
  @override
  bool get isAndroid => false;
  @override
  bool get isMacOS => false;
  @override
  bool get isWindows => false;
  @override
  bool get isLinux => false;
  @override
  String get platformName => 'Unknown';
}

void main() {
  group('PlatformOptimizer Static Methods', () {
    test('getOptimalParticleCount returns integer', () {
      final result = PlatformOptimizer.getOptimalParticleCount(100.0);
      expect(result, isA<int>());
      expect(result, greaterThanOrEqualTo(0));
    });

    test('getOptimalFrameRate returns Duration', () {
      final result = PlatformOptimizer.getOptimalFrameRate();
      expect(result, isA<Duration>());
      expect(result.inMicroseconds, greaterThan(0));
    });

    test('getParticleStep returns double', () {
      final result = PlatformOptimizer.getParticleStep();
      expect(result, isA<double>());
      expect(result, greaterThan(0.0));
    });

    test('shouldUseHighPerformanceMode returns boolean', () {
      final result = PlatformOptimizer.shouldUseHighPerformanceMode();
      expect(result, isA<bool>());
    });

    test('getPlatformName returns non-empty string', () {
      final result = PlatformOptimizer.getPlatformName();
      expect(result, isA<String>());
      expect(result.isNotEmpty, isTrue);
    });

    test('static methods are consistent', () {
      final count1 = PlatformOptimizer.getOptimalParticleCount(100.0);
      final count2 = PlatformOptimizer.getOptimalParticleCount(100.0);
      expect(count1, equals(count2));

      final rate1 = PlatformOptimizer.getOptimalFrameRate();
      final rate2 = PlatformOptimizer.getOptimalFrameRate();
      expect(rate1, equals(rate2));
    });
  });

  group('PlatformOptimizer Constructor', () {
    test('creates with default detector', () {
      const optimizer = PlatformOptimizer();
      expect(optimizer.getCurrentPlatformName(), isA<String>());
      expect(optimizer.getCurrentPlatformName().isNotEmpty, isTrue);
    });

    test('creates with custom detector', () {
      final optimizer = PlatformOptimizer(
        platformDetector: MockWebPlatformIdentifier(),
      );
      expect(optimizer.getCurrentPlatformName(), equals('Web'));
    });
  });

  group('PlatformOptimizer Web Platform', () {
    late PlatformOptimizer optimizer;

    setUp(() {
      optimizer = PlatformOptimizer(
        platformDetector: MockWebPlatformIdentifier(),
      );
    });

    test('calculateOptimalParticleCount returns web values', () {
      expect(optimizer.calculateOptimalParticleCount(100.0), equals(80));
      expect(optimizer.calculateOptimalParticleCount(0.0), equals(0));
      expect(optimizer.calculateOptimalParticleCount(123.7), equals(99));
    });

    test('calculateOptimalFrameRate returns web values', () {
      expect(
        optimizer.calculateOptimalFrameRate(),
        equals(const Duration(milliseconds: 16)),
      );
    });

    test('calculateParticleStep returns web values', () {
      expect(optimizer.calculateParticleStep(), equals(2.5));
    });

    test('isHighPerformanceModeEnabled returns false for web', () {
      expect(optimizer.isHighPerformanceModeEnabled(), isFalse);
    });

    test('getCurrentPlatformName returns Web', () {
      expect(optimizer.getCurrentPlatformName(), equals('Web'));
    });
  });

  group('PlatformOptimizer iOS Platform', () {
    late PlatformOptimizer optimizer;

    setUp(() {
      optimizer = PlatformOptimizer(
        platformDetector: MockIOSPlatformIdentifier(),
      );
    });

    test('calculateOptimalParticleCount returns iOS values', () {
      expect(optimizer.calculateOptimalParticleCount(100.0), equals(60));
      expect(optimizer.calculateOptimalParticleCount(0.0), equals(0));
      expect(optimizer.calculateOptimalParticleCount(123.7), equals(74));
    });

    test('calculateOptimalFrameRate returns iOS values', () {
      expect(
        optimizer.calculateOptimalFrameRate(),
        equals(const Duration(milliseconds: 16)),
      );
    });

    test('calculateParticleStep returns iOS values', () {
      expect(optimizer.calculateParticleStep(), equals(2.0));
    });

    test('isHighPerformanceModeEnabled returns false for iOS', () {
      expect(optimizer.isHighPerformanceModeEnabled(), isFalse);
    });

    test('getCurrentPlatformName returns iOS', () {
      expect(optimizer.getCurrentPlatformName(), equals('iOS'));
    });
  });

  group('PlatformOptimizer Android Platform', () {
    late PlatformOptimizer optimizer;

    setUp(() {
      optimizer = PlatformOptimizer(
        platformDetector: MockAndroidPlatformIdentifier(),
      );
    });

    test('calculateOptimalParticleCount returns Android values', () {
      expect(optimizer.calculateOptimalParticleCount(100.0), equals(60));
      expect(optimizer.calculateOptimalParticleCount(0.0), equals(0));
      expect(optimizer.calculateOptimalParticleCount(123.7), equals(74));
    });

    test('calculateOptimalFrameRate returns Android values', () {
      expect(
        optimizer.calculateOptimalFrameRate(),
        equals(const Duration(milliseconds: 16)),
      );
    });

    test('calculateParticleStep returns Android values', () {
      expect(optimizer.calculateParticleStep(), equals(2.0));
    });

    test('isHighPerformanceModeEnabled returns false for Android', () {
      expect(optimizer.isHighPerformanceModeEnabled(), isFalse);
    });

    test('getCurrentPlatformName returns Android', () {
      expect(optimizer.getCurrentPlatformName(), equals('Android'));
    });
  });

  group('PlatformOptimizer macOS Platform', () {
    late PlatformOptimizer optimizer;

    setUp(() {
      optimizer = PlatformOptimizer(
        platformDetector: MockMacOSPlatformIdentifier(),
      );
    });

    test('calculateOptimalParticleCount returns macOS values', () {
      expect(optimizer.calculateOptimalParticleCount(100.0), equals(120));
      expect(optimizer.calculateOptimalParticleCount(0.0), equals(0));
      expect(optimizer.calculateOptimalParticleCount(123.7), equals(148));
    });

    test('calculateOptimalFrameRate returns macOS values', () {
      expect(
        optimizer.calculateOptimalFrameRate(),
        equals(const Duration(microseconds: 8333)),
      );
    });

    test('calculateParticleStep returns macOS values', () {
      expect(optimizer.calculateParticleStep(), equals(1.5));
    });

    test('isHighPerformanceModeEnabled returns true for macOS', () {
      expect(optimizer.isHighPerformanceModeEnabled(), isTrue);
    });

    test('getCurrentPlatformName returns macOS', () {
      expect(optimizer.getCurrentPlatformName(), equals('macOS'));
    });
  });

  group('PlatformOptimizer Windows Platform', () {
    late PlatformOptimizer optimizer;

    setUp(() {
      optimizer = PlatformOptimizer(
        platformDetector: MockWindowsPlatformIdentifier(),
      );
    });

    test('calculateOptimalParticleCount returns Windows values', () {
      expect(optimizer.calculateOptimalParticleCount(100.0), equals(120));
      expect(optimizer.calculateOptimalParticleCount(0.0), equals(0));
      expect(optimizer.calculateOptimalParticleCount(123.7), equals(148));
    });

    test('calculateOptimalFrameRate returns Windows values', () {
      expect(
        optimizer.calculateOptimalFrameRate(),
        equals(const Duration(microseconds: 8333)),
      );
    });

    test('calculateParticleStep returns Windows values', () {
      expect(optimizer.calculateParticleStep(), equals(1.5));
    });

    test('isHighPerformanceModeEnabled returns true for Windows', () {
      expect(optimizer.isHighPerformanceModeEnabled(), isTrue);
    });

    test('getCurrentPlatformName returns Windows', () {
      expect(optimizer.getCurrentPlatformName(), equals('Windows'));
    });
  });

  group('PlatformOptimizer Linux Platform', () {
    late PlatformOptimizer optimizer;

    setUp(() {
      optimizer = PlatformOptimizer(
        platformDetector: MockLinuxPlatformIdentifier(),
      );
    });

    test('calculateOptimalParticleCount returns Linux values', () {
      expect(optimizer.calculateOptimalParticleCount(100.0), equals(120));
      expect(optimizer.calculateOptimalParticleCount(0.0), equals(0));
      expect(optimizer.calculateOptimalParticleCount(123.7), equals(148));
    });

    test('calculateOptimalFrameRate returns Linux values', () {
      expect(
        optimizer.calculateOptimalFrameRate(),
        equals(const Duration(microseconds: 8333)),
      );
    });

    test('calculateParticleStep returns Linux values', () {
      expect(optimizer.calculateParticleStep(), equals(1.5));
    });

    test('isHighPerformanceModeEnabled returns true for Linux', () {
      expect(optimizer.isHighPerformanceModeEnabled(), isTrue);
    });

    test('getCurrentPlatformName returns Linux', () {
      expect(optimizer.getCurrentPlatformName(), equals('Linux'));
    });
  });

  group('PlatformOptimizer Unknown Platform', () {
    late PlatformOptimizer optimizer;

    setUp(() {
      optimizer = PlatformOptimizer(
        platformDetector: MockUnknownPlatformIdentifier(),
      );
    });

    test('calculateOptimalParticleCount returns fallback values', () {
      expect(optimizer.calculateOptimalParticleCount(100.0), equals(100));
      expect(optimizer.calculateOptimalParticleCount(0.0), equals(0));
      expect(optimizer.calculateOptimalParticleCount(123.7), equals(124));
    });

    test('calculateOptimalFrameRate returns fallback values', () {
      expect(
        optimizer.calculateOptimalFrameRate(),
        equals(const Duration(milliseconds: 16)),
      );
    });

    test('calculateParticleStep returns fallback values', () {
      expect(optimizer.calculateParticleStep(), equals(2.0));
    });

    test('isHighPerformanceModeEnabled returns false for unknown', () {
      expect(optimizer.isHighPerformanceModeEnabled(), isFalse);
    });

    test('getCurrentPlatformName returns Unknown', () {
      expect(optimizer.getCurrentPlatformName(), equals('Unknown'));
    });
  });

  group('Static vs Instance Method Consistency', () {
    test('static methods delegate to default instance correctly', () {
      const optimizer = PlatformOptimizer();

      expect(
        PlatformOptimizer.getOptimalParticleCount(100.0),
        equals(optimizer.calculateOptimalParticleCount(100.0)),
      );

      expect(
        PlatformOptimizer.getOptimalFrameRate(),
        equals(optimizer.calculateOptimalFrameRate()),
      );

      expect(
        PlatformOptimizer.getParticleStep(),
        equals(optimizer.calculateParticleStep()),
      );

      expect(
        PlatformOptimizer.shouldUseHighPerformanceMode(),
        equals(optimizer.isHighPerformanceModeEnabled()),
      );

      expect(
        PlatformOptimizer.getPlatformName(),
        equals(optimizer.getCurrentPlatformName()),
      );
    });
  });

  group('Cross-Platform Consistency', () {
    test('mobile platforms have consistent behavior', () {
      final ios = PlatformOptimizer(
        platformDetector: MockIOSPlatformIdentifier(),
      );
      final android = PlatformOptimizer(
        platformDetector: MockAndroidPlatformIdentifier(),
      );

      expect(
        ios.calculateOptimalParticleCount(100.0),
        equals(android.calculateOptimalParticleCount(100.0)),
      );
      expect(
        ios.calculateOptimalFrameRate(),
        equals(android.calculateOptimalFrameRate()),
      );
      expect(
        ios.calculateParticleStep(),
        equals(android.calculateParticleStep()),
      );
      expect(
        ios.isHighPerformanceModeEnabled(),
        equals(android.isHighPerformanceModeEnabled()),
      );
    });

    test('desktop platforms have consistent behavior', () {
      final macos = PlatformOptimizer(
        platformDetector: MockMacOSPlatformIdentifier(),
      );
      final windows = PlatformOptimizer(
        platformDetector: MockWindowsPlatformIdentifier(),
      );
      final linux = PlatformOptimizer(
        platformDetector: MockLinuxPlatformIdentifier(),
      );

      expect(
        macos.calculateOptimalParticleCount(100.0),
        equals(windows.calculateOptimalParticleCount(100.0)),
      );
      expect(
        macos.calculateOptimalParticleCount(100.0),
        equals(linux.calculateOptimalParticleCount(100.0)),
      );

      expect(
        macos.calculateOptimalFrameRate(),
        equals(windows.calculateOptimalFrameRate()),
      );
      expect(
        macos.calculateOptimalFrameRate(),
        equals(linux.calculateOptimalFrameRate()),
      );

      expect(
        macos.calculateParticleStep(),
        equals(windows.calculateParticleStep()),
      );
      expect(
        macos.calculateParticleStep(),
        equals(linux.calculateParticleStep()),
      );

      expect(
        macos.isHighPerformanceModeEnabled(),
        equals(windows.isHighPerformanceModeEnabled()),
      );
      expect(
        macos.isHighPerformanceModeEnabled(),
        equals(linux.isHighPerformanceModeEnabled()),
      );
    });

    test('all platforms handle zero width consistently', () {
      final platforms = [
        PlatformOptimizer(platformDetector: MockWebPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockIOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockAndroidPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockMacOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockWindowsPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockLinuxPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockUnknownPlatformIdentifier()),
      ];

      for (final platform in platforms) {
        expect(platform.calculateOptimalParticleCount(0.0), equals(0));
      }
    });

    test('all platforms return positive values for positive width', () {
      final platforms = [
        PlatformOptimizer(platformDetector: MockWebPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockIOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockAndroidPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockMacOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockWindowsPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockLinuxPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockUnknownPlatformIdentifier()),
      ];

      for (final platform in platforms) {
        expect(platform.calculateOptimalParticleCount(100.0), greaterThan(0));
        expect(
          platform.calculateOptimalFrameRate().inMicroseconds,
          greaterThan(0),
        );
        expect(platform.calculateParticleStep(), greaterThan(0.0));
      }
    });
  });

  group('Edge Cases and Mathematical Properties', () {
    test('handles fractional widths correctly for all platforms', () {
      final testValues = [1.1, 50.7, 99.9, 123.456];
      final platforms = [
        PlatformOptimizer(platformDetector: MockWebPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockIOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockMacOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockUnknownPlatformIdentifier()),
      ];

      for (final platform in platforms) {
        for (final width in testValues) {
          final result = platform.calculateOptimalParticleCount(width);
          expect(result, isA<int>());
          expect(result, greaterThanOrEqualTo(0));
        }
      }
    });

    test('particle count scales proportionally with width', () {
      final platforms = [
        PlatformOptimizer(platformDetector: MockWebPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockIOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockMacOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockUnknownPlatformIdentifier()),
      ];

      for (final platform in platforms) {
        final small = platform.calculateOptimalParticleCount(50.0);
        final large = platform.calculateOptimalParticleCount(100.0);
        expect(large, greaterThan(small));
      }
    });

    test('methods are deterministic for all platforms', () {
      final platforms = [
        PlatformOptimizer(platformDetector: MockWebPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockIOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockMacOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockUnknownPlatformIdentifier()),
      ];

      for (final platform in platforms) {
        final count1 = platform.calculateOptimalParticleCount(75.0);
        final count2 = platform.calculateOptimalParticleCount(75.0);
        expect(count1, equals(count2));

        final rate1 = platform.calculateOptimalFrameRate();
        final rate2 = platform.calculateOptimalFrameRate();
        expect(rate1, equals(rate2));

        final step1 = platform.calculateParticleStep();
        final step2 = platform.calculateParticleStep();
        expect(step1, equals(step2));
      }
    });

    test('handles large widths appropriately', () {
      final testWidths = [500.0, 1000.0, 5000.0];
      final platforms = [
        PlatformOptimizer(platformDetector: MockWebPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockMacOSPlatformIdentifier()),
      ];

      for (final platform in platforms) {
        for (final width in testWidths) {
          final result = platform.calculateOptimalParticleCount(width);
          expect(result, isA<int>());
          expect(result, greaterThan(0));
          expect(result, lessThan(width * 2));
        }
      }
    });

    test('frame rates are within reasonable bounds', () {
      final platforms = [
        PlatformOptimizer(platformDetector: MockWebPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockIOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockMacOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockUnknownPlatformIdentifier()),
      ];

      for (final platform in platforms) {
        final frameRate = platform.calculateOptimalFrameRate();
        expect(frameRate.inMicroseconds, greaterThan(5000));
        expect(frameRate.inMicroseconds, lessThan(50000));
      }
    });

    test('particle steps are within reasonable bounds', () {
      final platforms = [
        PlatformOptimizer(platformDetector: MockWebPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockIOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockMacOSPlatformIdentifier()),
        PlatformOptimizer(platformDetector: MockUnknownPlatformIdentifier()),
      ];

      for (final platform in platforms) {
        final step = platform.calculateParticleStep();
        expect(step, greaterThanOrEqualTo(1.0));
        expect(step, lessThanOrEqualTo(5.0));
      }
    });
  });

  group('DefaultPlatformIdentifier Integration', () {
    test('default detector is properly initialized', () {
      const detector = DefaultPlatformIdentifier();
      expect(detector.platformName, isA<String>());
      expect(detector.platformName.isNotEmpty, isTrue);

      final validPlatforms = [
        'Web',
        'iOS',
        'Android',
        'macOS',
        'Windows',
        'Linux',
        'Unknown',
      ];
      expect(validPlatforms, contains(detector.platformName));
    });

    test('default platform optimizer uses real platform detection', () {
      const optimizer = PlatformOptimizer();
      final platformName = optimizer.getCurrentPlatformName();

      expect(platformName, isA<String>());
      expect(platformName.isNotEmpty, isTrue);

      final validPlatforms = [
        'Web',
        'iOS',
        'Android',
        'macOS',
        'Windows',
        'Linux',
        'Unknown',
      ];
      expect(validPlatforms, contains(platformName));
    });
  });
}
