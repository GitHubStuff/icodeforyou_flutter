// animated_widgets/test/src/animated_checkbox/checkmark_painter_test.dart

import 'dart:ui' show PictureRecorder;

import 'package:animated_widgets/src/animated_checkbox/src/_checkmark_painter.dart';
import 'package:animated_widgets/src/animated_checkbox/src/_dissolve_particle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _width = 100.0;
const _start = Offset(0.05, 0.52);
const _mid = Offset(0.45, 0.95);
const _finish = Offset(0.95, 0.06);
const _size = Size(_width, _width);

CheckmarkPainter _painter({
  double progress = 0.5,
  Color strokeColor = Colors.purple,
  bool isDraw = true,
  List<DissolveParticle> particles = const [],
}) => CheckmarkPainter(
  progress: progress,
  strokeColor: strokeColor,
  isDraw: isDraw,
  particles: particles,
  width: _width,
  startOffset: _start,
  midOffset: _mid,
  finishOffset: _finish,
);

// Drives [painter.paint] against a real canvas so the painting branches
// execute. Returns normally when no exception is thrown.
void _paint(CheckmarkPainter painter) {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, _size);
  recorder.endRecording().dispose();
}

void main() {
  group('CheckmarkPainter.paint — draw mode', () {
    test('paints first-segment branch when progress is small', () {
      // progress 0.1 keeps currentLength <= firstLength → first branch.
      expect(() => _paint(_painter(progress: 0.1)), returnsNormally);
    });

    test('paints second-segment branch when progress is large', () {
      // progress 0.9 pushes currentLength past firstLength → else branch.
      expect(() => _paint(_painter(progress: 0.9)), returnsNormally);
    });

    test('paints full stroke at progress 1.0', () {
      expect(() => _paint(_painter(progress: 1)), returnsNormally);
    });
  });

  group('CheckmarkPainter.paint — dissolve mode', () {
    test('paints fading stroke while progress <= 0.1', () {
      expect(
        () => _paint(_painter(progress: 0.05, isDraw: false)),
        returnsNormally,
      );
    });

    test('skips the stroke once progress exceeds 0.1', () {
      expect(
        () => _paint(_painter(progress: 0.5, isDraw: false)),
        returnsNormally,
      );
    });

    test('draws visible particles', () {
      const particle = DissolveParticle(
        position: Offset(10, 10),
        velocity: Offset(5, 5),
        startTime: 0,
      );
      expect(
        () => _paint(
          _painter(progress: 0.2, isDraw: false, particles: [particle]),
        ),
        returnsNormally,
      );
    });

    test('skips particles whose opacity has dropped to ~0', () {
      // startTime 0 with progress 1.0 → opacity 0 → continue branch.
      const faded = DissolveParticle(
        position: Offset(10, 10),
        velocity: Offset(5, 5),
        startTime: 0,
      );
      expect(
        () => _paint(
          _painter(progress: 1, isDraw: false, particles: [faded]),
        ),
        returnsNormally,
      );
    });
  });

  group('CheckmarkPainter.shouldRepaint', () {
    test('false when every field is identical', () {
      expect(_painter().shouldRepaint(_painter()), isFalse);
    });

    test('true when progress differs', () {
      expect(
        _painter(progress: 0.5).shouldRepaint(_painter(progress: 0.6)),
        isTrue,
      );
    });

    test('true when strokeColor differs', () {
      expect(
        _painter().shouldRepaint(_painter(strokeColor: Colors.green)),
        isTrue,
      );
    });

    test('true when isDraw differs', () {
      expect(_painter().shouldRepaint(_painter(isDraw: false)), isTrue);
    });

    test('true when particles list identity differs', () {
      final a = _painter(particles: const []);
      final b = _painter(
        particles: [
          const DissolveParticle(
            position: Offset.zero,
            velocity: Offset.zero,
            startTime: 0,
          ),
        ],
      );
      expect(a.shouldRepaint(b), isTrue);
    });
  });

  group('CheckmarkPainter — render through CustomPaint', () {
    testWidgets('renders draw mode without exception', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomPaint(size: _size, painter: _painter()),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders dissolve mode with particles without exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomPaint(
            size: _size,
            painter: _painter(
              progress: 0.3,
              isDraw: false,
              particles: const [
                DissolveParticle(
                  position: Offset(20, 20),
                  velocity: Offset(10, -10),
                  startTime: 0,
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
