// packages/platform_utils/test/src/dip_scale_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:platform_utils/src/dip_scale.dart' show DipScale, Spacing;

void main() {
  group('DipScale', () {
    test('constants match the documented 8pt-grid values', () {
      expect(DipScale.none, 0);
      expect(DipScale.xs, 4);
      expect(DipScale.sm, 8);
      expect(DipScale.smd, 12);
      expect(DipScale.md, 16);
      expect(DipScale.lg, 24);
      expect(DipScale.xl, 32);
      expect(DipScale.xxl, 48);
    });

    test('every step is divisible by 4 so densities stay whole', () {
      const steps = [
        DipScale.none,
        DipScale.xs,
        DipScale.sm,
        DipScale.smd,
        DipScale.md,
        DipScale.lg,
        DipScale.xl,
        DipScale.xxl,
      ];
      for (final step in steps) {
        expect(step % 4, 0, reason: '$step is not on the 4pt grid');
        expect((step * 1.5) % 1, 0, reason: '$step breaks at 1.5x density');
      }
    });

    test('the scale is strictly increasing', () {
      const steps = [
        DipScale.none,
        DipScale.xs,
        DipScale.sm,
        DipScale.smd,
        DipScale.md,
        DipScale.lg,
        DipScale.xl,
        DipScale.xxl,
      ];
      for (var i = 1; i < steps.length; i++) {
        expect(steps[i], greaterThan(steps[i - 1]));
      }
    });

    test('Spacing typedef aliases double', () {
      const Spacing spacing = DipScale.lg;
      expect(spacing, isA<double>());
    });
  });
}
