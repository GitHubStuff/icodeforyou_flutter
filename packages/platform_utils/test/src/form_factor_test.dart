// packages/platform_utils/test/src/form_factor_test.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/widgets.dart' show Builder, Size, SizedBox;
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_utils/src/form_factor.dart' show FormFactor;

void main() {
  tearDown(() {
    FormFactor.setFormFactor();
    debugDefaultTargetPlatformOverride = null;
  });

  group('FormFactor.from', () {
    setUp(() {
      // Pin a native mobile platform so the geometry breakpoints (not
      // the desktop-OS short-circuit) drive resolution. Safe in plain
      // test() bodies; testWidgets bodies must use a
      // TargetPlatformVariant instead — the binding verifies all
      // foundation debug variables are null when the test body ends,
      // before tearDown runs.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    test('shortest side under 600 is phone', () {
      expect(FormFactor.from(const Size(400, 800)), FormFactor.phone);
      expect(FormFactor.from(const Size(599, 1000)), FormFactor.phone);
    });

    test('shortest side of at least 600 is tablet', () {
      expect(FormFactor.from(const Size(600, 960)), FormFactor.tablet);
      expect(FormFactor.from(const Size(800, 1023)), FormFactor.tablet);
    });

    test('width of at least 1024 is desktop regardless of shortest side', () {
      expect(FormFactor.from(const Size(1024, 500)), FormFactor.desktop);
      expect(FormFactor.from(const Size(1920, 1080)), FormFactor.desktop);
    });

    test('native desktop operating systems are always desktop', () {
      const desktops = [
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows,
      ];
      for (final platform in desktops) {
        debugDefaultTargetPlatformOverride = platform;
        expect(FormFactor.from(const Size(400, 800)), FormFactor.desktop);
      }
    });

    test('honors the setFormFactor override over every runtime signal', () {
      for (final formFactor in FormFactor.values) {
        FormFactor.setFormFactor(to: formFactor);
        expect(FormFactor.from(const Size(400, 800)), formFactor);
      }
    });

    test('setFormFactor with no argument restores runtime resolution', () {
      FormFactor.setFormFactor(to: FormFactor.web);
      FormFactor.setFormFactor();

      expect(FormFactor.from(const Size(400, 800)), FormFactor.phone);
    });
  });

  group('FormFactor.of', () {
    testWidgets(
      'resolves from the ambient MediaQuery size',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        late FormFactor resolved;
        await tester.pumpWidget(
          Builder(
            builder: (context) {
              resolved = FormFactor.of(context);
              return const SizedBox.shrink();
            },
          ),
        );

        expect(resolved, FormFactor.phone);
      },
      // The binding sets and restores the platform around the body,
      // on the correct side of its foundation-variable invariant check.
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  });

  group('FormFactor getters', () {
    test('each getter is true only for its own value', () {
      expect(FormFactor.phone.isPhone, isTrue);
      expect(FormFactor.phone.isTablet, isFalse);
      expect(FormFactor.phone.isDesktop, isFalse);
      expect(FormFactor.phone.isWeb, isFalse);

      expect(FormFactor.tablet.isTablet, isTrue);
      expect(FormFactor.tablet.isPhone, isFalse);

      expect(FormFactor.desktop.isDesktop, isTrue);
      expect(FormFactor.desktop.isWeb, isFalse);

      expect(FormFactor.web.isWeb, isTrue);
      expect(FormFactor.web.isDesktop, isFalse);
    });
  });
}
