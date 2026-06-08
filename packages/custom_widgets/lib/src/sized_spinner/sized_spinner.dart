// packages/custom_widgets/lib/src/sized_spinner/sized_spinner.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:platform_utils/platform_utils.dart' show PlatformVendor;

class SizedSpinner extends StatelessWidget {
  const SizedSpinner({
    required this.size,
    this.color,
    this.platformVendor,
    super.key,
  });

  static const double _kStrokeRatio = 0.07;

  final double size;
  final Color? color;
  final PlatformVendor? platformVendor;

  @override
  Widget build(BuildContext context) {
    final PlatformVendor vendor = platformVendor ?? PlatformVendor.current();
    switch (vendor) {
      case .apple:
        return CupertinoActivityIndicator(
          radius: size / 2,
          color: color, //CupertinoColors.activeBlue,
          animating: true,
        );
      case .google:
      case .microsoft:
      case .other:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: size * _kStrokeRatio,
          ),
        );
    }
  }
}
