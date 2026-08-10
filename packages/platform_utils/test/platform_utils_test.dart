// packages/platform_utils/test/platform_utils_test.dart

import 'package:flutter/widgets.dart' show Orientation, Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_utils/platform_utils.dart';

/// Smoke tests proving every symbol exported by the `platform_utils`
/// barrel resolves through the barrel import alone.
void main() {
  group('platform_utils barrel', () {
    test('exports the platform and vendor enums', () {
      expect(AppPlatform.values, hasLength(7));
      expect(PlatformVendor.values, hasLength(4));
    });

    test('exports the form factor and orientation resolvers', () {
      expect(FormFactor.values, hasLength(4));
      expect(
        OrientationFactor.from(const Size(400, 800)),
        Orientation.portrait,
      );
    });

    test('exports the spacing scale and Spacing typedef', () {
      const Spacing spacing = DipScale.md;
      expect(spacing, 16);
    });

    test('exports the frame refresh rates and optimizer', () {
      expect(FrameRefreshRate.values, hasLength(4));
      expect(PlatformOptimizer, isNotNull);
    });
  });
}
