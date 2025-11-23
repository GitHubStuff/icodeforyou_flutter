// lib/src/core/mixins/divider_rendering_mixin.dart

import 'package:flutter/material.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/dimensions_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';

/// Mixin for rendering dividers in picker widgets
mixin DividerRenderingMixin {
  /// Build a single divider line
  Widget buildDivider(DividerConfiguration config) {
    return Container(
      height: config.thickness,
      margin: EdgeInsets.only(
        left: config.indent,
        right: config.endIndent,
      ),
      decoration: BoxDecoration(
        color: config.effectiveColor,
        boxShadow: config.hasEffect
            ? [
                BoxShadow(
                  color: config.effectiveColor,
                  blurRadius: config.blurRadius,
                  spreadRadius: config.spreadRadius,
                  blurStyle: config.blurStyle ?? BlurStyle.normal,
                ),
              ]
            : null,
      ),
    );
  }

  /// Build divider pair (top and bottom) for picker
  Widget buildDividerPair({
    required DividerConfiguration config,
    double itemExtent = DimensionConstants.itemExtent,
    double? width,
  }) {
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildDivider(config),
              SizedBox(height: itemExtent),
              buildDivider(config),
            ],
          ),
        ),
      ),
    );
  }

  /// Build dividers with custom positioning
  Widget buildPositionedDividers({
    required DividerConfiguration config,
    required double top,
    required double bottom,
    double? left,
    double? right,
    double? width,
  }) {
    return Stack(
      children: [
        Positioned(
          top: top,
          left: left,
          right: right,
          width: width,
          child: buildDivider(config),
        ),
        Positioned(
          top: bottom,
          left: left,
          right: right,
          width: width,
          child: buildDivider(config),
        ),
      ],
    );
  }

  /// Calculate divider positions based on viewport
  DividerPositions calculateDividerPositions({
    required double viewportHeight,
    double itemExtent = DimensionConstants.itemExtent,
  }) {
    final center = viewportHeight / 2;
    final halfItem = itemExtent / 2;

    return DividerPositions(
      topDivider: center - halfItem,
      bottomDivider: center + halfItem,
    );
  }

  /// Build animated dividers
  Widget buildAnimatedDividers({
    required DividerConfiguration config,
    required double viewportHeight,
    double itemExtent = DimensionConstants.itemExtent,
    Duration animationDuration = const Duration(milliseconds: 200),
    Curve animationCurve = Curves.easeInOut,
  }) {
    final positions = calculateDividerPositions(
      viewportHeight: viewportHeight,
      itemExtent: itemExtent,
    );

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: buildPositionedDividers(
        config: config,
        top: positions.topDivider,
        bottom: positions.bottomDivider,
      ),
    );
  }
}

/// Container for calculated divider positions
class DividerPositions {
  final double topDivider;
  final double bottomDivider;

  const DividerPositions({
    required this.topDivider,
    required this.bottomDivider,
  });

  double get spacing => bottomDivider - topDivider;
}
