// test/src/animated_checkbox/checkmark_painter_test.dart

import 'dart:ui' as ui;

import 'package:animated_widgets/src/animated_checkbox/src/checkmark_painter.dart';
import 'package:animated_widgets/src/animated_checkbox/src/dissolve_particle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _width = 48;
const double _progress = 0.5;
const double _altProgress = 0.6;
const Color _strokeColor = Colors.black;
const Color _altStrokeColor = Colors.red;
const Offset _start = Offset(0.1, 0.5);
const Offset _altStart = Offset(0.2, 0.5);
const Offset _mid = Offset(0.4, 0.8);
const Offset _altMid = Offset(0.5, 0.8);
const Offset _finish = Offset(0.9, 0.2);
const Offset _altFinish = Offset(0.8, 0.2);
const double _smallProgress = 0.05;
const double _largeProgress = 0.95;

void main() {
  CheckmarkPainter buildPainter({
    double progress = _progress,
    Color strokeColor = _strokeColor,
    bool isDraw = true,
    List<DissolveParticle> particles = const <DissolveParticle>[],
    Offset startOffset = _start,
    Offset midOffset = _mid,
    Offset finishOffset = _finish,
  }) {
    return CheckmarkPainter(
      progress: progress,
      strokeColor: strokeColor,
      isDraw: isDraw,
      particles: particles,
      width: _width,
      startOffset: startOffset,
      midOffset: midOffset,
      finishOffset: finishOffset,
    );
  }

  void paintOnce(CheckmarkPainter painter) {
    final recorder = ui.PictureRecorder();
    painter.paint(ui.Canvas(recorder), const Size(_width, _width));
    recorder.endRecording().dispose();
  }

  group('CheckmarkPainter.shouldRepaint', () {
    test('returns false when every field is identical', () {
      expect(buildPainter().shouldRepaint(buildPainter()), isFalse);
    });

    test('returns true when progress changes', () {
      expect(
        buildPainter(progress: _altProgress).shouldRepaint(buildPainter()),
        isTrue,
      );
    });

    test('returns true when only strokeColor changes', () {
      expect(
        buildPainter(strokeColor: _altStrokeColor).shouldRepaint(
          buildPainter(),
        ),
        isTrue,
      );
    });

    test('returns true when only isDraw changes', () {
      expect(
        buildPainter(isDraw: false).shouldRepaint(buildPainter()),
        isTrue,
      );
    });

    test('returns true when only particles changes', () {
      expect(
        buildPainter(particles: <DissolveParticle>[]).shouldRepaint(
          buildPainter(),
        ),
        isTrue,
      );
    });

    test('returns true when only startOffset changes', () {
      expect(
        buildPainter(startOffset: _altStart).shouldRepaint(buildPainter()),
        isTrue,
      );
    });

    test('returns true when only midOffset changes', () {
      expect(
        buildPainter(midOffset: _altMid).shouldRepaint(buildPainter()),
        isTrue,
      );
    });

    test('returns true when only finishOffset changes', () {
      expect(
        buildPainter(finishOffset: _altFinish).shouldRepaint(buildPainter()),
        isTrue,
      );
    });
  });

  group('CheckmarkPainter.paint', () {
    test('draws the first checkmark segment for small progress', () {
      expect(
        () => paintOnce(buildPainter(progress: _smallProgress)),
        returnsNormally,
      );
    });

    test('draws the second checkmark segment for large progress', () {
      expect(
        () => paintOnce(buildPainter(progress: _largeProgress)),
        returnsNormally,
      );
    });

    test('fades the checkmark during the dissolve intro window', () {
      expect(
        () => paintOnce(buildPainter(isDraw: false, progress: _smallProgress)),
        returnsNormally,
      );
    });

    test('skips the dissolve fade once past the intro window', () {
      expect(
        () => paintOnce(buildPainter(isDraw: false, progress: _progress)),
        returnsNormally,
      );
    });
  });
}
