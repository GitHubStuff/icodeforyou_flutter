// packages/custom_widgets/lib/src/sized_spinner/sized_spinner.dart
// ignore_for_file: public_member_api_docs

import 'package:ext_string/ext_string.dart' show ExtString;
import 'package:ext_widget/ext_widget.dart' show ExtWidget;
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:sized_spinner/sized_spinner.dart' show SpinWidget;

class PlatformSpinner extends StatelessWidget {
  const PlatformSpinner({
    required this.size,
    this.color,
    this.osPlatform,
    super.key,
  });

  static const double _kStrokeRatio = 0.07;

  final double size;
  final Color? color;
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

  Widget _indicatorFor(OSPlatform platform) {
    switch (platform) {
      case .android:
        return CircularProgressIndicator(
          color: color,
          strokeWidth: size * _kStrokeRatio,
        );
      case .iOS:
      case .macOS:
        return CupertinoActivityIndicator(
          radius: size / 2,
          color: color,
          animating: true,
        );
      case .windows:
        return SpinWidget(
          autoStart: true,
          child: '💩'.asGlyph().squareFit(side: size),
        );

      case .fuchsia:
      case .linux:
      case .web:
    }
  }
}
