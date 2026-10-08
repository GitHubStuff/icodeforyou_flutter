// packages/extensions/test/datetime/src/datetime_ext2_test.dart
import 'package:extensions/extensions.dart' show DateTimeExt;
import 'package:test/test.dart';

void main() {
  group('DateTimeProximityExtension.isWithin', () {
    final anchor = DateTime.utc(2026, 10, 7, 12);
    const oneSecond = Duration(seconds: 1);

    test('returns true when other is identical', () {
      expect(anchor.isWithin(anchor, tolerance: Duration.zero), isTrue);
    });

    test('returns true when other is later but inside tolerance', () {
      final later = anchor.add(const Duration(milliseconds: 999));

      expect(anchor.isWithin(later, tolerance: oneSecond), isTrue);
    });

    test('returns true when other is earlier but inside tolerance', () {
      final earlier = anchor.subtract(const Duration(milliseconds: 999));

      expect(anchor.isWithin(earlier, tolerance: oneSecond), isTrue);
    });

    test('returns true when distance equals tolerance exactly', () {
      final boundary = anchor.add(oneSecond);

      expect(anchor.isWithin(boundary, tolerance: oneSecond), isTrue);
    });

    test('returns false when other is later and outside tolerance', () {
      final later = anchor.add(const Duration(milliseconds: 1001));

      expect(anchor.isWithin(later, tolerance: oneSecond), isFalse);
    });

    test('returns false when other is earlier and outside tolerance', () {
      final earlier = anchor.subtract(const Duration(milliseconds: 1001));

      expect(anchor.isWithin(earlier, tolerance: oneSecond), isFalse);
    });

    test('is symmetric', () {
      final later = anchor.add(const Duration(milliseconds: 500));

      expect(
        anchor.isWithin(later, tolerance: oneSecond),
        later.isWithin(anchor, tolerance: oneSecond),
      );
    });

    test('compares across UTC and local time zones correctly', () {
      final local = anchor.toLocal();

      expect(anchor.isWithin(local, tolerance: Duration.zero), isTrue);
    });

    test('throws ArgumentError for negative tolerance', () {
      expect(
        () => anchor.isWithin(anchor, tolerance: const Duration(seconds: -1)),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
