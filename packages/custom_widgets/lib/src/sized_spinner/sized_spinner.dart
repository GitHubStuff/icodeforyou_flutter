// packages/custom_widgets/lib/src/sized_spinner/sized_spinner.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:platform_utils/platform_utils.dart' show PlatformVender;

class SizedSpinner extends StatelessWidget {
  const SizedSpinner({required this.size, this.color, super.key});

  static const double _kStrokeRatio = 0.07;

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    switch (PlatformVender.current()) {
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
