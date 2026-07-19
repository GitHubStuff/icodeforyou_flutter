import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ProjectorPainter extends CustomPainter {
  const ProjectorPainter({
    required this.image,
    required this.currentFrame,
    required this.columns,
    required this.rows,
    required this.fit,
    required this.alignment,
    required this.filterQuality,
  });

  final ui.Image image;
  final int currentFrame;
  final int columns;
  final int rows;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;

  @override
  void paint(Canvas canvas, Size size) {
    final double sourceFrameWidth = image.width.toDouble() / columns;
    final double sourceFrameHeight = image.height.toDouble() / rows;

    final int sourceColumn = currentFrame % columns;
    final int sourceRow = currentFrame ~/ columns;

    final Rect sourceRect = Rect.fromLTWH(
      sourceColumn * sourceFrameWidth,
      sourceRow * sourceFrameHeight,
      sourceFrameWidth,
      sourceFrameHeight,
    );

    final Size sourceSize = Size(sourceFrameWidth, sourceFrameHeight);

    final FittedSizes fittedSizes = applyBoxFit(fit, sourceSize, size);

    final Rect fittedSourceRect = alignment.inscribe(
      fittedSizes.source,
      Offset.zero & sourceSize,
    );

    final Rect destinationRect = alignment.inscribe(
      fittedSizes.destination,
      Offset.zero & size,
    );

    final Rect adjustedSourceRect = Rect.fromLTWH(
      sourceRect.left + fittedSourceRect.left,
      sourceRect.top + fittedSourceRect.top,
      fittedSourceRect.width,
      fittedSourceRect.height,
    );

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = filterQuality;

    canvas.drawImageRect(image, adjustedSourceRect, destinationRect, paint);
  }

  @override
  bool shouldRepaint(covariant ProjectorPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.currentFrame != currentFrame ||
        oldDelegate.columns != columns ||
        oldDelegate.rows != rows ||
        oldDelegate.fit != fit ||
        oldDelegate.alignment != alignment ||
        oldDelegate.filterQuality != filterQuality;
  }
}
