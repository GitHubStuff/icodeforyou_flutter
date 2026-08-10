// packages/platform_utils/test/src/orientation_factor_test.dart

import 'package:flutter/widgets.dart' show Builder, Orientation, Size, SizedBox;
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_utils/src/orientation_factor.dart'
    show OrientationFactor;

void main() {
  tearDown(OrientationFactor.setOrientation);

  group('OrientationFactor.from', () {
    test('taller-than-wide is portrait', () {
      expect(
        OrientationFactor.from(const Size(400, 800)),
        Orientation.portrait,
      );
    });

    test('wider-than-tall is landscape', () {
      expect(
        OrientationFactor.from(const Size(800, 400)),
        Orientation.landscape,
      );
    });

    test('a square window is portrait, matching MediaQueryData', () {
      expect(
        OrientationFactor.from(const Size(500, 500)),
        Orientation.portrait,
      );
    });

    test('honors the setOrientation override', () {
      OrientationFactor.setOrientation(to: Orientation.landscape);
      expect(
        OrientationFactor.from(const Size(400, 800)),
        Orientation.landscape,
      );

      OrientationFactor.setOrientation(to: Orientation.portrait);
      expect(
        OrientationFactor.from(const Size(800, 400)),
        Orientation.portrait,
      );
    });

    test('setOrientation with no argument restores runtime resolution',
        () {
      OrientationFactor.setOrientation(to: Orientation.landscape);
      OrientationFactor.setOrientation();

      expect(
        OrientationFactor.from(const Size(400, 800)),
        Orientation.portrait,
      );
    });
  });

  group('OrientationFactor.of', () {
    testWidgets('resolves from the ambient MediaQuery size',
        (tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late Orientation resolved;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            resolved = OrientationFactor.of(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(resolved, Orientation.landscape);
    });
  });
}
