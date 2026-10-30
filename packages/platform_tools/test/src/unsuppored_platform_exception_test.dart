// test/src/unsuppored_platform_exception_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:platform_tools/platform_tools.dart'
    show OSPlatform, UnsupportedPlatformException;

void main() {
  group('UnsupportedPlatformException', () {
    test('instantiates with the given platform', () {
      const exception = UnsupportedPlatformException(OSPlatform.android);

      expect(exception.platform, equals(OSPlatform.android));
    });

    test('toString formats correctly using platform name', () {
      const exception = UnsupportedPlatformException(OSPlatform.android);

      expect(
        exception.toString(),
        equals('UnsupportedPlatformException: android is not supported'),
      );
    });

    group('equality and hashCode', () {
      test('supports value equality and identical instances', () {
        const exceptionA = UnsupportedPlatformException(OSPlatform.android);
        const exceptionB = UnsupportedPlatformException(OSPlatform.android);
        const exceptionC = UnsupportedPlatformException(OSPlatform.iOS);

        // identical branch: identical(this, other)
        expect(exceptionA == exceptionA, isTrue);

        // equal value branch: other is UnsupportedPlatformException && other.platform == platform
        expect(exceptionA == exceptionB, isTrue);
        expect(exceptionA.hashCode, equals(exceptionB.hashCode));

        // unequal platform
        expect(exceptionA == exceptionC, isFalse);

        // different type branch: other is not UnsupportedPlatformException
        expect(exceptionA == Object(), isFalse);
      });
    });
  });
}
