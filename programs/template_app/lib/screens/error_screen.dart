// programs/template_app/lib/screens/error_screen.dart

import 'package:flutter/material.dart';

/// The app's landing screen.
///
/// Presents the bundled `iconer` artwork centered on the surface, scaled to
/// fit within [_kIconerExtent] without distortion.
class ErrorScreen extends StatelessWidget {
  /// Creates a [ErrorScreen].
  const ErrorScreen({super.key});

  static const String _kIconerAsset = 'assets/iconer.png';
  static const String _kIconerLabel = 'Error Screen';
  static const double _kIconerExtent = 240;
  static const EdgeInsets _kContentPadding = EdgeInsets.all(24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_kIconerLabel)),
      body: Center(
        child: Padding(
          padding: _kContentPadding,
          child: Image.asset(
            _kIconerAsset,
            width: _kIconerExtent,
            height: _kIconerExtent,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            semanticLabel: _kIconerLabel,
          ),
        ),
      ),
    );
  }
}
