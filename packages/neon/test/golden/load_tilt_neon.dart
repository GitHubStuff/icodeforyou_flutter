// packages/neon/test/golden/load_tilt_neon.dart
import 'dart:io' show File;
import 'dart:typed_data' show ByteData;

import 'package:flutter/services.dart' show FontLoader;

/// The font family `NeonText` renders with.
const String tiltNeonFamily = 'TiltNeon';

/// Loads the bundled TiltNeon variable font into the test engine.
///
/// Without this the sign renders in the block glyphs `flutter_test` uses for
/// unknown families. The path is relative to the package root, which is the
/// working directory `flutter test` runs in.
Future<void> loadTiltNeon() async {
  final bytes = File('assets/fonts/TiltNeon-Variable.ttf').readAsBytes();
  final loader = FontLoader(tiltNeonFamily)
    ..addFont(bytes.then(ByteData.sublistView));

  await loader.load();
}
