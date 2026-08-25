// packages/prism_bubble_widget/test/src/bubble_shader_manager_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/bubble_shader_manager.dart';
import 'package:prism_bubble_widget/src/shader_load_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BubbleShaderManager', () {
    late BubbleShaderManager manager;

    setUp(() {
      manager = BubbleShaderManager.instance;
      manager.resetForTesting();
    });

    test('constants are correctly assigned', () {
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

    test('throws ShaderLoadException before init', () {
      expect(manager.isLoaded, isFalse);

      expect(
        () => manager.darkShader,
        throwsA(
          isA<ShaderLoadException>().having(
            (e) => e.toString(),
            'message',
            contains(
              'Dark bubble shader not loaded. Call init() first.',
            ),
          ),
        ),
      );

      expect(
        () => manager.lightShader,
        throwsA(
          isA<ShaderLoadException>().having(
            (e) => e.toString(),
            'message',
            contains(
              'Light bubble shader not loaded. Call init() first.',
            ),
          ),
        ),
      );
    });

    test('throws ShaderLoadException on asset load failure', () async {
      BubbleShaderManager.programLoader = (String path) async {
        throw Exception('Simulated asset failure');
      };

      expect(
        manager.init(),
        throwsA(
          isA<ShaderLoadException>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to load bubble shader assets:'),
          ),
        ),
      );
    });

    test('inits successfully, exposes shaders, and handles rerun', () async {
      await manager.init();

      expect(manager.isLoaded, isTrue);
      expect(manager.darkShader, isNotNull);
      expect(manager.lightShader, isNotNull);

      // Verify early return branch when isLoaded == true
      await manager.init();
      expect(manager.isLoaded, isTrue);
    });
  });
}
