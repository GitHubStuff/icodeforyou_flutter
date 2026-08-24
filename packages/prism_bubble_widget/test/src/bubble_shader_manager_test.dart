// packages/prism_bubble_widget/test/src/bubble_shader_manager_test.dart
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/bubble_shader_manager.dart';
import 'package:prism_bubble_widget/src/shader_load_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BubbleShaderManager', () {
    test('verifies uniform slot index constants', () {
      expect(BubbleShaderManager.uSizeXPos, 0);
      expect(BubbleShaderManager.uSizeYPos, 1);
      expect(BubbleShaderManager.uTintRPos, 2);
      expect(BubbleShaderManager.uTintGPos, 3);
      expect(BubbleShaderManager.uTintBPos, 4);
      expect(BubbleShaderManager.uTintAPPos, 5);
      expect(BubbleShaderManager.uArcOpacityPos, 6);
      expect(BubbleShaderManager.uDiffusionPos, 7);
      expect(BubbleShaderManager.uPhaseAnglePos, 8);
    });

    test('throws ShaderLoadException when accessing shader before init', () {
      final manager = BubbleShaderManager.instance;
      if (!manager.isLoaded) {
        expect(
          () => manager.shader,
          throwsA(isA<ShaderLoadException>()),
        );
      }
    });

    test(
      'handles initialization failure gracefully with ShaderLoadException',
      () async {
        final manager = BubbleShaderManager.instance;
        // In default headless test environments without compiled spir-v assets,
        // init() triggers the catch block and throws ShaderLoadException.
        try {
          await manager.init();
          expect(manager.isLoaded, isTrue);
          expect(manager.shader, isA<ui.FragmentShader>());
          // Subsequent call triggers early return branch
          await manager.init();
        } on ShaderLoadException catch (e) {
          expect(e.message, contains('Failed to load shader asset'));
          expect(manager.isLoaded, isFalse);
        }
      },
    );
  });
}
