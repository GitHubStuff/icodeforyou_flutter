// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:settings_widget/src/_settings_direction.dart';

class SettingsLayout extends StatelessWidget {
  const SettingsLayout({
    required this.direction,
    required this.edgeGap,
    required this.child,
    super.key,
  });

  final SettingsDirection direction;
  final double edgeGap;
  final Widget child;

  static const double _sheetRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _alignment,
      child: Padding(
        padding: _padding,
        child: _sized(
          context,
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            elevation: 6,
            borderRadius: BorderRadius.circular(_sheetRadius),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _sized(BuildContext context, Widget child) {
    final size = MediaQuery.sizeOf(context);
    return switch (direction) {
      SettingsDirection.left || SettingsDirection.right => SizedBox(
          width: size.width * 0.85,
          height: size.height,
          child: child,
        ),
      _ => child,
    };
  }

  AlignmentGeometry get _alignment => switch (direction) {
    SettingsDirection.bottom => Alignment.bottomCenter,
    SettingsDirection.top    => Alignment.topCenter,
    SettingsDirection.left   => Alignment.centerLeft,
    SettingsDirection.right  => Alignment.centerRight,
  };

  EdgeInsets get _padding => switch (direction) {
    SettingsDirection.bottom => EdgeInsets.only(bottom: edgeGap),
    SettingsDirection.top    => EdgeInsets.only(top: edgeGap),
    SettingsDirection.left   => EdgeInsets.only(left: edgeGap),
    SettingsDirection.right  => EdgeInsets.only(right: edgeGap),
  };
}
