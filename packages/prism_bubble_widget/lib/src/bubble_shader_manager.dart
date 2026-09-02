// packages/prism_bubble_widget/lib/src/bubble_shader_manager.dart
import 'dart:ui' as ui;

import 'package:meta/meta.dart';
import 'package:prism_bubble_widget/src/shader_load_exception.dart'
    show ShaderLoadException;

/// Manager singleton responsible for loading and compiling dark and light
/// bubble fragment shaders.
class BubbleShaderManager {
  BubbleShaderManager._();

  /// Uniform float buffer position for the X coordinate of the size vector.
  static const int uSizeXPos = 0;

  /// Uniform float buffer position for the Y coordinate of the size vector.
  static const int uSizeYPos = 1;

  /// Uniform float buffer position for the red channel of the tint color.
  static const int uTintRPos = 2;

  /// Uniform float buffer position for the green channel of the tint color.
  static const int uTintGPos = 3;

  /// Uniform float buffer position for the blue channel of the tint color.
  static const int uTintBPos = 4;

  /// Uniform float buffer position for the alpha channel of the tint color.
  static const int uTintAPPos = 5;

  /// Uniform float buffer position for the specular arc opacity.
  static const int uArcOpacityPos = 6;

  /// Uniform float buffer position for the diffusion coefficient.
  static const int uDiffusionPos = 7;

  /// Uniform float buffer position for the phase angle of the swirl effect.
  static const int uPhaseAnglePos = 8;

  static const String _darkAssetPath =
      'packages/prism_bubble_widget/shaders/bubble_dark.frag';
  static const String _lightAssetPath =
      'packages/prism_bubble_widget/shaders/bubble_light.frag';

  static const String _localDarkAssetPath = 'shaders/bubble_dark.frag';
  static const String _localLightAssetPath = 'shaders/bubble_light.frag';

  /// Loader function used to compile fragment programs from asset paths.
  @visibleForTesting
  static Future<ui.FragmentProgram> Function(String assetPath) programLoader =
      ui.FragmentProgram.fromAsset;

  ui.FragmentShader? _darkShader;
  ui.FragmentShader? _lightShader;

  /// Whether both dark and light fragment shaders have been loaded.
  bool get isLoaded => _darkShader != null && _lightShader != null;

  /// Retrieves the shader compiled for dark surfaces.
  ///
  /// Throws a [ShaderLoadException] if [init] has not been called yet.
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
  ///
  /// Throws a [ShaderLoadException] if [init] has not been called yet.
  ui.FragmentShader get lightShader {
    final activeShader = _lightShader;
    if (activeShader == null) {
      throw ShaderLoadException(
        'Light bubble shader not loaded. Call init() first.',
      );
    }
    return activeShader;
  }

  /// Resets internal shader references for test isolation.
  @visibleForTesting
  void resetForTesting() {
    _darkShader = null;
    _lightShader = null;
    programLoader = ui.FragmentProgram.fromAsset;
  }

  static Future<ui.FragmentProgram> _loadProgram(
    String packagePath,
    String localPath,
  ) async {
    try {
      return await programLoader(packagePath);
    } on Exception catch (_) {
      return await programLoader(localPath);
    }
  }

  /// Loads and initializes both dark and light shader programs.
  ///
  /// If the shaders are already loaded, this method completes immediately.
  /// Throws a [ShaderLoadException] if loading either asset fails.
  Future<void> init() async {
    if (isLoaded) return;
    try {
      final darkProgram = await _loadProgram(
        _darkAssetPath,
        _localDarkAssetPath,
      );
      _darkShader = darkProgram.fragmentShader();

      final lightProgram = await _loadProgram(
        _lightAssetPath,
        _localLightAssetPath,
      );
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
