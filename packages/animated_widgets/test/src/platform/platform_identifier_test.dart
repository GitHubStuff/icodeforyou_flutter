// test/platform_identifier_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultPlatformIdentifier', () {
    test('detects Web', () {
      final id = DefaultPlatformIdentifier(
        webChecker: () => true,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );
      expect(id.isWeb, isTrue);
      expect(id.platformName, equals('Web'));
    });

    test('detects iOS', () {
      final id = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => true,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );
      expect(id.isIOS, isTrue);
      expect(id.platformName, equals('iOS'));
    });

    test('detects Android', () {
      final id = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => true,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );
      expect(id.isAndroid, isTrue);
      expect(id.platformName, equals('Android'));
    });

    test('detects macOS', () {
      final id = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => true,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );
      expect(id.isMacOS, isTrue);
      expect(id.platformName, equals('macOS'));
    });

    test('detects Windows', () {
      final id = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => true,
        linuxChecker: () => false,
      );
      expect(id.isWindows, isTrue);
      expect(id.platformName, equals('Windows'));
    });

    test('detects Linux', () {
      final id = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => true,
      );
      expect(id.isLinux, isTrue);
      expect(id.platformName, equals('Linux'));
    });

    test('returns Unknown for unrecognized platform', () {
      final id = DefaultPlatformIdentifier(
        webChecker: () => false,
        iosChecker: () => false,
        androidChecker: () => false,
        macosChecker: () => false,
        windowsChecker: () => false,
        linuxChecker: () => false,
      );
      expect(id.platformName, equals('Unknown'));
    });

    test('exercises all default checker methods', () {
      const id = DefaultPlatformIdentifier();
      id.isWeb;
      id.isIOS;
      id.isAndroid;
      id.isMacOS;
      id.isWindows;
      id.isLinux;
      expect(id.platformName, isA<String>());
      expect(id.platformName, isNot(equals('')));
    });
  });
}
