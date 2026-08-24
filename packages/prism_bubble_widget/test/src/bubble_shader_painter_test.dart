// packages/prism_bubble_widget/test/src/bubble_shader_painter_test.dart
import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/bubble_shader_manager.dart';
import 'package:prism_bubble_widget/src/bubble_shader_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BubbleShaderPainter', () {
    test('initializes with default values', () {
      final painter = BubbleShaderPainter(
        manager: BubbleShaderManager.instance,
      );

      expect(painter.tintColor, Colors.white);
      expect(painter.arcOpacity, 0.3);
      expect(painter.diffusion, 0.0);
      expect(painter.phaseAngle, 0.0);
    });

    test('paint returns early without error when shader is not loaded', () {
      final manager = BubbleShaderManager.instance;
      final painter = BubbleShaderPainter(
        manager: manager,
        tintColor: Colors.blue,
        arcOpacity: 0.8,
        diffusion: 0.5,
        phaseAngle: 1.2,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // In unit test environment, manager.isLoaded is false; verifies early exit branch
      expect(
        () => painter.paint(canvas, const Size(200, 200)),
        returnsNormally,
      );
    });

    test('shouldRepaint returns false when properties are identical', () {
      final manager = BubbleShaderManager.instance;
      final painter1 = BubbleShaderPainter(
        manager: manager,
        tintColor: Colors.red,
        arcOpacity: 0.4,
        diffusion: 0.6,
        phaseAngle: 2.0,
      );
      final painter2 = BubbleShaderPainter(
        manager: manager,
        tintColor: Colors.red,
        arcOpacity: 0.4,
        diffusion: 0.6,
        phaseAngle: 2.0,
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint returns true when tintColor changes', () {
      final manager = BubbleShaderManager.instance;
      final oldPainter = BubbleShaderPainter(
        manager: manager,
        tintColor: Colors.red,
      );
      final newPainter = BubbleShaderPainter(
        manager: manager,
        tintColor: Colors.green,
      );

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });

    test('shouldRepaint returns true when arcOpacity changes', () {
      final manager = BubbleShaderManager.instance;
      final oldPainter = BubbleShaderPainter(
        manager: manager,
        arcOpacity: 0.2,
      );
      final newPainter = BubbleShaderPainter(
        manager: manager,
        arcOpacity: 0.5,
      );

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });

    test('shouldRepaint returns true when diffusion changes', () {
      final manager = BubbleShaderManager.instance;
      final oldPainter = BubbleShaderPainter(
        manager: manager,
        diffusion: 0.1,
      );
      final newPainter = BubbleShaderPainter(
        manager: manager,
        diffusion: 0.7,
      );

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });

    test('shouldRepaint returns true when phaseAngle changes', () {
      final manager = BubbleShaderManager.instance;
      final oldPainter = BubbleShaderPainter(
        manager: manager,
        phaseAngle: 0.0,
      );
      final newPainter = BubbleShaderPainter(
        manager: manager,
        phaseAngle: 1.57,
      );

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });
  });
}
