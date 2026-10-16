// packages/prism_bubble_widget/lib/src/bubble_shader_manager.dart
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:prism_bubble_widget/src/shader_load_exception.dart'
    show ShaderLoadException;

/// Manager singleton responsible for loading and compiling dark and light
/// bubble fragment shaders.
///
/// Shader asset keys differ by who is running: a host application addresses
/// this package's assets as `packages/prism_bubble_widget/shaders/...`,
/// while the package's own tests address them bare as `shaders/...`. [init]
/// resolves each key against the asset manifest before loading, so exactly
/// one load is attempted per shader and a missing asset is reported as such
/// rather than surfacing as a failed probe.
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

  /// Prefix under which a host application's manifest lists this package's
  /// assets.
  static const String _packagePrefix = 'packages/prism_bubble_widget/';

  static const String _darkShaderFile = 'shaders/bubble_dark.frag';
  static const String _lightShaderFile = 'shaders/bubble_light.frag';

  /// Loader function used to compile fragment programs from asset keys.
  @visibleForTesting
  static Future<ui.FragmentProgram> Function(String assetKey) programLoader =
      ui.FragmentProgram.fromAsset;

  /// Loader function used to read the asset manifest.
  @visibleForTesting
  static Future<AssetManifest> Function() manifestLoader = _loadRootManifest;

  static Future<AssetManifest> _loadRootManifest() =>
      AssetManifest.loadFromAssetBundle(rootBundle);

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

  /// Resets internal shader references and loaders for test isolation.
  @visibleForTesting
  void resetForTesting() {
    _darkShader = null;
    _lightShader = null;
    programLoader = ui.FragmentProgram.fromAsset;
    manifestLoader = _loadRootManifest;
  }

  /// Loads and initializes both dark and light shader programs.
  ///
  /// If the shaders are already loaded, this method completes immediately.
  /// Both programs are loaded before either shader is assigned, so a failure
  /// leaves the manager fully unloaded rather than half-initialised.
  ///
  /// Throws a [ShaderLoadException] if the manifest cannot be read, if
  /// either shader is not bundled under any known key, or if either program
  /// fails to load.
  Future<void> init() async {
    if (isLoaded) return;

    final assetKeys = await _loadAssetKeys();
    final darkKey = _resolveAssetKey(assetKeys, _darkShaderFile);
    final lightKey = _resolveAssetKey(assetKeys, _lightShaderFile);

    final darkProgram = await _loadProgram(darkKey);
    final lightProgram = await _loadProgram(lightKey);

    _darkShader = darkProgram.fragmentShader();
    _lightShader = lightProgram.fragmentShader();
  }

  static Future<Set<String>> _loadAssetKeys() async {
    try {
      final manifest = await manifestLoader();
      return manifest.listAssets().toSet();
    } on Exception catch (e) {
      throw ShaderLoadException('Failed to read the asset manifest: $e');
    }
  }

  /// Returns the manifest key under which [shaderFile] is bundled.
  ///
  /// The package-prefixed key is preferred, which is how a host application
  /// lists this package's assets; the bare key is how the package lists its
  /// own assets when its tests run.
  static String _resolveAssetKey(Set<String> assetKeys, String shaderFile) {
    final packageKey = '$_packagePrefix$shaderFile';
    if (assetKeys.contains(packageKey)) return packageKey;
    if (assetKeys.contains(shaderFile)) return shaderFile;
    throw ShaderLoadException(
      'Shader "$shaderFile" is not bundled: neither "$packageKey" nor '
      '"$shaderFile" is present in the asset manifest.',
    );
  }

  static Future<ui.FragmentProgram> _loadProgram(String assetKey) async {
    try {
      return await programLoader(assetKey);
    } on Exception catch (e) {
      throw ShaderLoadException(
        'Failed to load bubble shader "$assetKey": $e',
      );
    }
  }

  /// The shared singleton instance of [BubbleShaderManager].
  static final BubbleShaderManager instance = BubbleShaderManager._();
}
