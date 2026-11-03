// packages/demo/lib/status_bar_visibility/status_bar_visibility_demo.dart

import 'package:flutter/material.dart';
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

/// A minimal "dumb" widget for exercising a [StatusBarVisibilityAbstract]
/// implementation by hand.
///
/// Exercises every member of the contract:
/// - [StatusBarVisibilityAbstract.initialize]
/// - [StatusBarVisibilityAbstract.setStatusBarVisibility]
/// - [StatusBarVisibilityAbstract.isInitialized]
/// - [StatusBarVisibilityAbstract.isBarHidden]
///
/// Shows the raw query results and a derived status as read-only text, and
/// offers three actions: initialize, show, and hide. Must be placed under a
/// [Scaffold] so that feedback can be shown via [SnackBar].
class StatusBarVisibilityDemo extends StatefulWidget {
  /// Creates a [StatusBarVisibilityDemo] driving [controller].
  const StatusBarVisibilityDemo({required this.controller, super.key});

  /// The platform implementation under test.
  final StatusBarVisibilityAbstract controller;

  @override
  State<StatusBarVisibilityDemo> createState() =>
      _StatusBarVisibilityDemoState();
}

class _StatusBarVisibilityDemoState extends State<StatusBarVisibilityDemo> {
  /// Initial state passed to [StatusBarVisibilityAbstract.initialize].
  /// Change by hand to exercise the other branch.
  static const bool _withBarHidden = false;

  static const _notInitialized = 'Not Initialized';
  static const _notSupported = 'Not Supported';
  static const _hidden = 'Status Bar Hidden';
  static const _visible = 'Status Bar Visible';

  /// `null` until [StatusBarVisibilityAbstract.initialize] has reported.
  /// A `false` return from either async contract method means the platform
  /// is not supported.
  bool? _isSupported;

  StatusBarVisibilityAbstract get _controller => widget.controller;

  String get _status {
    if (!_controller.isInitialized()) return _notInitialized;
    if (_isSupported == false) return _notSupported;
    return _controller.isBarHidden() ? _hidden : _visible;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onInitialize() async {
    final isSupported = await _controller.setStatusBarVisibility(
      isHidden: _withBarHidden,
    );
    if (!mounted) return;
    setState(() => _isSupported = isSupported);
    if (!isSupported) {
      _toast('Status bar visibility is not supported on this platform');
    }
  }

  Future<void> _onSetVisibility({required bool isHidden}) async {
    if (!_controller.isInitialized()) {
      _toast('Not initialized — tap Initialize first');
      return;
    }
    final isSupported = await _controller.setStatusBarVisibility(
      isHidden: isHidden,
    );
    if (!mounted) return;
    setState(() => _isSupported = isSupported);
    if (!isSupported) {
      _toast('Status bar visibility is not supported on this platform');
    }
  }

  Widget _row(BuildContext context, String label, String value) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label: ', style: style),
        Text(value, style: style?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_status, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _row(context, 'isInitialized()', '${_controller.isInitialized()}'),
        _row(context, 'isBarHidden()', '${_controller.isBarHidden()}'),
        _row(context, 'withBarHidden', '$_withBarHidden'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _onInitialize,
          child: const Text('Initialize Status Bar Visibility'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => _onSetVisibility(isHidden: false),
          child: const Text('Show Status Bar'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => _onSetVisibility(isHidden: true),
          child: const Text('Hide Status Bar'),
        ),
      ],
    );
  }
}
