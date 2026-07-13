// packages/earth_spin/lib/src/sprite_painter.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SpritePainter extends CustomPainter {
  final ui.Image image;
  final int currentFrame;
  final int columns;
  final int rows;

  SpritePainter({
    required this.image,
    required this.currentFrame,
    required this.columns,
    required this.rows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double frameWidth = image.width / columns;
    final double frameHeight = image.height / rows;

    final int col = currentFrame % columns;
    final int row = currentFrame ~/ columns;

    final Rect src = Rect.fromLTWH(
      col * frameWidth,
      row * frameHeight,
      frameWidth,
      frameHeight,
    );

    final Rect dst = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant SpritePainter oldDelegate) {
    return oldDelegate.currentFrame != currentFrame ||
        oldDelegate.image != image;
  }
}
