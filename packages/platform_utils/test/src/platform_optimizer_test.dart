// packages/platform_utils/test/src/platform_optimizer_test.dart

import 'package:flutter/widgets.dart' show Builder, SizedBox;
import 'package:flutter_test/flutter_test.dart';
import '../../../platform_tools/lib/src/os_platform.dart' show OSPlatform;
import 'package:platform_utils/src/frame_refresh.dart' show FrameRefreshRate;
import 'package:platform_utils/src/platform_optimizer.dart'
    show PlatformOptimizer;

void main() {
  tearDown(OSPlatform.override);

  group('calculateOptimalParticleCount', () {
    test('web renders at 0.8x width', () {
      final optimizer = PlatformOptimizer(platform: OSPlatform.web);
      expect(optimizer.calculateOptimalParticleCount(100), 80);
    });

    test('mobile platforms render at 0.6x width', () {
      for (final platform in [OSPlatform.android, OSPlatform.iOS]) {
        final optimizer = PlatformOptimizer(platform: platform);
        expect(optimizer.calculateOptimalParticleCount(100), 60);
      }
    });

    test('desktop platforms render at 1.2x width', () {
      const desktops = [
        OSPlatform.linux,
        OSPlatform.macOS,
        OSPlatform.windows,
      ];
      for (final platform in desktops) {
        final optimizer = PlatformOptimizer(platform: platform);
        expect(optimizer.calculateOptimalParticleCount(100), 120);
      }
    });

    test('rounds to the nearest whole particle', () {
      final optimizer = PlatformOptimizer(platform: OSPlatform.web);
      expect(optimizer.calculateOptimalParticleCount(101), 81);
    });

    test('propagates the fuchsia capability error from the guard', () {
      final optimizer = PlatformOptimizer(platform: OSPlatform.fuchsia);
      expect(
        () => optimizer.calculateOptimalParticleCount(100),
        throwsUnimplementedError,
      );
    });
  });

  group('calculateParticleStep', () {
    test('web uses the coarsest step', () {
      expect(
        PlatformOptimizer(platform: OSPlatform.web).calculateParticleStep(),
        2.5,
      );
    });

    test('mobile uses the moderate step', () {
      for (final platform in [OSPlatform.android, OSPlatform.iOS]) {
        expect(
          PlatformOptimizer(platform: platform).calculateParticleStep(),
          2.0,
        );
      }
    });

    test('desktop uses the finest step', () {
      const desktops = [
        OSPlatform.linux,
        OSPlatform.macOS,
        OSPlatform.windows,
      ];
      for (final platform in desktops) {
        expect(
          PlatformOptimizer(platform: platform).calculateParticleStep(),
          1.5,
        );
      }
    });

    test('propagates the fuchsia capability error from the guard', () {
      expect(
        () => PlatformOptimizer(
          platform: OSPlatform.fuchsia,
        ).calculateParticleStep(),
        throwsUnimplementedError,
      );
    });
  });

  group('isHighPerformanceModeEnabled', () {
    test('is true only for native desktop platforms', () {
      const desktops = [
        OSPlatform.linux,
        OSPlatform.macOS,
        OSPlatform.windows,
      ];
      for (final platform in desktops) {
        expect(
          PlatformOptimizer(platform: platform).isHighPerformanceModeEnabled(),
          isTrue,
        );
      }
      expect(
        PlatformOptimizer(
          platform: OSPlatform.web,
        ).isHighPerformanceModeEnabled(),
        isFalse,
      );
      expect(
        PlatformOptimizer(
          platform: OSPlatform.android,
        ).isHighPerformanceModeEnabled(),
        isFalse,
      );
    });
  });

  group('getCurrentPlatformName', () {
    test('returns the effective platform name', () {
      expect(
        PlatformOptimizer(platform: OSPlatform.macOS).getCurrentPlatformName(),
        'macOS',
      );
    });

    test('detects at call time when no platform is injected', () {
      OSPlatform.override(to: OSPlatform.windows);
      expect(PlatformOptimizer().getCurrentPlatformName(), 'windows');
    });
  });

  group('frame rate resolution', () {
    test('falls back to fps60 before resolveFrameRate is called', () {
      final optimizer = PlatformOptimizer(platform: OSPlatform.android);
      expect(
        optimizer.calculateOptimalFrameRate(),
        FrameRefreshRate.fps60.duration,
      );
    });

    testWidgets('resolveFrameRate caches the display refresh rate', (
      tester,
    ) async {
      final optimizer = PlatformOptimizer(platform: OSPlatform.android);

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            optimizer.resolveFrameRate(context);
            return const SizedBox.shrink();
          },
        ),
      );

      // The test display reports 60Hz; the cached duration must match
      // it and keep being returned on subsequent calls.
      expect(
        optimizer.calculateOptimalFrameRate(),
        const Duration(microseconds: 16667),
      );
      expect(
        optimizer.calculateOptimalFrameRate(),
        const Duration(microseconds: 16667),
      );
    });
  });

  group('static convenience methods', () {
    test('delegate to a shared runtime-resolving instance', () {
      OSPlatform.override(to: OSPlatform.linux);

      expect(
        PlatformOptimizer.getOptimalFrameRate(),
        FrameRefreshRate.fps60.duration,
      );
      expect(PlatformOptimizer.getOptimalParticleCount(100), 120);
      expect(PlatformOptimizer.getParticleStep(), 1.5);
      expect(PlatformOptimizer.shouldUseHighPerformanceMode(), isTrue);
      expect(PlatformOptimizer.getPlatformName(), 'linux');
    });

    test('follow the AppPlatform override as it changes', () {
      OSPlatform.override(to: OSPlatform.web);

      expect(PlatformOptimizer.getOptimalParticleCount(100), 80);
      expect(PlatformOptimizer.getParticleStep(), 2.5);
      expect(PlatformOptimizer.shouldUseHighPerformanceMode(), isFalse);
      expect(PlatformOptimizer.getPlatformName(), 'web');
    });
  });
}
