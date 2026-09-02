// packages/prism_bubble_widget/lib/src/shader_load_exception.dart

/// An exception thrown when a shader fails to load, compile, or initialize.
///
/// This exception generally indicates an issue with the shader asset path,
/// the format of the `.frag` file, or an issue during the asynchronous
/// `ui.FragmentProgram.fromAsset` call.
class ShaderLoadException implements Exception {
  /// Creates a [ShaderLoadException] with the provided error message.
  ShaderLoadException(this.message);

  /// A human-readable description of the error that occurred during the
  /// shader loading process.
  final String message;

  @override
  String toString() => 'ShaderLoadException: $message';
}
