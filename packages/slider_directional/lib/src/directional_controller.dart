// packages/slider_directional/lib/src/directional_controller.dart
// ignore_for_file: comment_references

import 'package:flutter/foundation.dart';

/// Holds the current value of a [Directional] slider and notifies listeners
/// when it changes.
///
/// Callers construct a [DirectionalController], hand it to [Directional], and
/// (optionally) to widgets that need to drive the slider externally.
///
/// Writes to [value] update only the slider's subtree; the caller's widget
/// does not rebuild.
///
/// Callers own the controller's lifecycle and must call [dispose] when the
/// owning widget is disposed — the same contract as [TextEditingController].
class DirectionalController extends ChangeNotifier
    implements ValueListenable<double> {
  /// Creates a controller with the given initial value.
  DirectionalController({double initial = 0.0}) : _value = initial;

  double _value;

  /// The current slider value.
  ///
  /// Setting this notifies listeners only if the new value differs from the
  /// current one (bit-exact `==`). Callers are expected to pass values
  /// already snapped to the slider's step grid; passing values computed via
  /// different math paths may produce redundant notifications.
  @override
  double get value => _value;

  set value(double newValue) {
    if (newValue == _value) return;
    _value = newValue;
    notifyListeners();
  }
}
