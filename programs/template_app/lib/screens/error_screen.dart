// programs/template_app/lib/screens/error_screen.dart

import 'package:flutter/material.dart';
import 'package:template_app/gen/assets.gen.dart';

const String _kIconerLabel = 'Error Screen';
const double _kIconerExtent = 240;

/// The app's landing screen.
///
/// Presents the bundled `iconer` artwork centered on the surface, scaled to
/// fit within [_kIconerExtent] without distortion.
class ErrorScreen extends StatelessWidget {
  /// Creates a [ErrorScreen].
  const ErrorScreen({this.errorBody, super.key});

  final Widget? errorBody;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_kIconerLabel)),
      body: Center(child: _defaultErrorWidget(errorBody)),
    );
  }
}

//-
Widget _defaultErrorWidget(Widget? errorWidget) {
  if (errorWidget != null) return errorWidget;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _defaultIcon(),
      const Text('Fatal Error', style: TextStyle(fontSize: 24)),
    ],
  );
}

//-
Widget _defaultIcon() => Assets.iconer.image(
  width: _kIconerExtent,
  height: _kIconerExtent,
  fit: BoxFit.contain,
  filterQuality: FilterQuality.medium,
  semanticLabel: _kIconerLabel,
);
