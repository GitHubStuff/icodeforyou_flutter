// packages/bare_dart/test/bare_dart_test.dart
import 'package:bare_dart/bare_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BareDart', () {
    final awesome = BareDart();

    test('isAwesome returns true', () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}