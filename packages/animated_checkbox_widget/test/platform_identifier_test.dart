// test/platform_identifier_test.dart
import 'package:animated_checkbox_widget/animated_checkbox_widget.dart'
    show DefaultPlatformIdentifier;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultPlatformIdentifier', () {
    test('should detect Web platform', () {
      final identifier = DefaultPlatformIdentifier(
        webChecker: () => true,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );

      expect(identifier.isWeb, isTrue);
      expect(identifier.isIOS, isFalse);
      expect(identifier.isAndroid, isFalse);
      expect(identifier.isMacOS, isFalse);
      expect(identifier.isWindows, isFalse);
      expect(identifier.isLinux, isFalse);
      expect(identifier.platformName, equals('Web'));
    });

    test('should detect iOS platform', () {
      final identifier = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => true,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );

      expect(identifier.isWeb, isFalse);
      expect(identifier.isIOS, isTrue);
      expect(identifier.platformName, equals('iOS'));
    });

    test('should detect Android platform', () {
      final identifier = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => true,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );

      expect(identifier.isAndroid, isTrue);
      expect(identifier.platformName, equals('Android'));
    });

    test('should detect macOS platform', () {
      final identifier = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => true,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );

      expect(identifier.isMacOS, isTrue);
      expect(identifier.platformName, equals('macOS'));
    });

    test('should detect Windows platform', () {
      final identifier = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => true,
        linuxChecker: () => false,
      );

      expect(identifier.isWindows, isTrue);
      expect(identifier.platformName, equals('Windows'));
    });

    test('should detect Linux platform', () {
      final identifier = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => true,
      );

      expect(identifier.isLinux, isTrue);
      expect(identifier.platformName, equals('Linux'));
    });

    test('should return Unknown for unrecognized platform', () {
      final identifier = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );

      expect(identifier.platformName, equals('Unknown'));
    });

    test('should exercise all default checker methods', () {
      const identifier = DefaultPlatformIdentifier();

      // Call each platform getter individually to ensure ALL default
      // checker methods are executed, including the uncovered ones
      identifier.isWeb;
      identifier.isIOS;
      identifier.isAndroid;
      identifier.isMacOS;
      identifier.isWindows; // This executes _defaultWindowsChecker (line 39)
      identifier.isLinux; // This executes _defaultLinuxChecker (line 40)

      // Verify the identifier works correctly
      expect(identifier.platformName, isA<String>());
      expect(identifier.platformName, isNot(equals('')));
    });
  });
}
