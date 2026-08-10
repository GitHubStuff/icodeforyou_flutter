// packages/platform_utils/test/src/frame_refresh_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:platform_utils/src/frame_refresh.dart'
    show FrameRefreshRate;

void main() {
  group('FrameRefreshRate', () {
    test('each rate carries its documented fps and frame interval', () {
      expect(FrameRefreshRate.fps24.fps, 24);
      expect(FrameRefreshRate.fps24.microseconds, 41667);
      expect(FrameRefreshRate.fps60.fps, 60);
      expect(FrameRefreshRate.fps60.microseconds, 16667);
      expect(FrameRefreshRate.fps90.fps, 90);
      expect(FrameRefreshRate.fps90.microseconds, 11111);
      expect(FrameRefreshRate.fps120.fps, 120);
      expect(FrameRefreshRate.fps120.microseconds, 8333);
    });

    test('microseconds equal 1e6 ~/ fps rounded, for every rate', () {
      for (final rate in FrameRefreshRate.values) {
        expect(
          rate.microseconds,
          (1000000 / rate.fps).round(),
          reason: '${rate.name} interval drifted from its fps',
        );
      }
    });

    test('duration is built from the precomputed microseconds', () {
      for (final rate in FrameRefreshRate.values) {
        expect(
          rate.duration,
          Duration(microseconds: rate.microseconds),
        );
      }
    });

    test('preset is the 60fps frame interval', () {
      expect(FrameRefreshRate.preset, FrameRefreshRate.fps60.duration);
      expect(FrameRefreshRate.preset.inMicroseconds, 16667);
    });
  });
}
