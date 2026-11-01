// packages/custom_errors/lib/src/plugin_error.dart
/// Thrown when a plugin encounters an unrecoverable failure during operation.
class PluginError extends Error {
  /// Creates a [PluginError] with an explanatory [message].
  PluginError(this.message);

  /// A description or name of the uninitialized entity.
  final String message;

  @override
  String toString() => 'PluginError: $message faulted on call';
}
