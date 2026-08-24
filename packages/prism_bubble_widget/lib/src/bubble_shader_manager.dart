// packages/prism_bubble_widget/lib/src/bubble_shader_manager.dart
import 'dart:ui' as ui;

import 'package:prism_bubble_widget/src/shader_load_exception.dart'
    show ShaderLoadException;

/// Manager singleton responsible for loading and compiling dark and light
/// bubble fragment shaders.
class BubbleShaderManager {
  BubbleShaderManager._();

  static const int uSizeXPos = 0;
  static const int uSizeYPos = 1;
  static const int uTintRPos = 2;
  static const int uTintGPos = 3;
  static const int uTintBPos = 4;
  static const int uTintAPPos = 5;
  static const int uArcOpacityPos = 6;
  static const int uDiffusionPos = 7;
  static const int uPhaseAnglePos = 8;

  static const String _darkAssetPath =
      'packages/prism_bubble_widget/shaders/bubble_dark.frag';
  static const String _lightAssetPath =
      'packages/prism_bubble_widget/shaders/bubble_light.frag';

  ui.FragmentShader? _darkShader;
  ui.FragmentShader? _lightShader;

  bool get isLoaded => _darkShader != null && _lightShader != null;

  /// Retrieves the shader compiled for dark surfaces.
  ui.FragmentShader get darkShader {
    final activeShader = _darkShader;
    if (activeShader == null) {
      throw ShaderLoadException(
        'Dark bubble shader not loaded. Call init() first.',
      );
    }
    return activeShader;
  }

  /// Retrieves the shader compiled for light surfaces.
  ui.FragmentShader get lightShader {
    final activeShader = _lightShader;
    if (activeShader == null) {
      throw ShaderLoadException(
        'Light bubble shader not loaded. Call init() first.',
      );
    }
    return activeShader;
  }

  /// Loads and initializes both dark and light shader programs.
  Future<void> init() async {
    if (isLoaded) return;
    try {
      final darkProgram = await ui.FragmentProgram.fromAsset(_darkAssetPath);
      _darkShader = darkProgram.fragmentShader();

      final lightProgram = await ui.FragmentProgram.fromAsset(_lightAssetPath);
      _lightShader = lightProgram.fragmentShader();
    } on Exception catch (e) {
      throw ShaderLoadException(
        'Failed to load bubble shader assets: $e',
      );
    }
  }

  /// The shared singleton instance of [BubbleShaderManager].
  static final BubbleShaderManager instance = BubbleShaderManager._();
}
