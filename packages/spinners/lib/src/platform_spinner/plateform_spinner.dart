// packages/spinners/lib/src/platform_spinner/plateform_spinner.dart

import 'package:ext_string/ext_string.dart' show ExtString;
import 'package:ext_widget/ext_widget.dart' show ExtWidget;
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:spinners/gen/assets.gen.dart' show Assets;
import 'package:spinners/spinners.dart' show SpinWidget;

/// A loading indicator widget customized according to the operating platform.
///
/// Adapts its visual representation based on [osPlatform] (or defaults to
/// [OSPlatform.current] if omitted):
/// * [OSPlatform.android]: A Material [CircularProgressIndicator].
/// * [OSPlatform.iOS] and [OSPlatform.macOS]: An Apple-style
///   [CupertinoActivityIndicator].
/// * [OSPlatform.fuchsia]: A spinning Fuchsia OS logo.
/// * [OSPlatform.linux]: A spinning Tux logo.
/// * [OSPlatform.web]: A spinning Web logo.
/// * [OSPlatform.windows]: A spinning custom glyph placeholder.
class PlatformSpinner extends StatelessWidget {
  /// Creates a platform-adaptive spinner of the specified [size].
  const PlatformSpinner({
    required this.size,
    this.color,
    this.osPlatform,
    super.key,
  });

  /// Ratio used to compute [CircularProgressIndicator.strokeWidth] relative
  /// to [size] on Android platforms.
  static const double _kStrokeRatio = 0.07;

  /// The width and height of the spinner in logical pixels.
  final double size;

  /// The tint color applied to native indicators that support coloring,
  /// such as Android and Apple activity indicators.
  final Color? color;

  /// The target operating system used to resolve the spinner style.
  ///
  /// When `null`, defaults to [OSPlatform.current].
  final OSPlatform? osPlatform;

  @override
  Widget build(BuildContext context) {
    final OSPlatform platform = osPlatform ?? OSPlatform.current;
    // Center loosens whatever constraints the parent hands us so the
    // SizedBox actually gets to be [size] x [size] instead of being
    // stretched into the parent's bounds.
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: _indicatorFor(platform),
      ),
    );
  }

  /// Builds the indicator widget tailored for the target [platform].
  Widget _indicatorFor(OSPlatform platform) {
    switch (platform) {
      case .android:
        return CircularProgressIndicator(
          color: color,
          strokeWidth: size * _kStrokeRatio,
        );

      case .fuchsia:
        return SpinWidget(
          autoStart: true,
          child: ClipOval(
            child: Assets.fuchsia
                .image(width: size, height: size, fit: BoxFit.cover)
                .squareFit(side: size),
          ),
        );

      case .iOS:
      case .macOS:
        return CupertinoActivityIndicator(
          radius: size / 2,
          color: color,
          animating: true,
        );

      case .linux:
        final logo = Assets.tux.image(width: size, height: size);
        return SpinWidget(
          autoStart: true,
          child: logo.squareFit(side: size),
        );

      case .web:
        final logo = Assets.web.image(width: size, height: size);
        return SpinWidget(
          autoStart: true,
          child: logo.squareFit(side: size),
        );

      case .windows:
        return SpinWidget(
          autoStart: true,
          child: '💩'.asGlyph().squareFit(side: size),
        );
    }
  }
}
