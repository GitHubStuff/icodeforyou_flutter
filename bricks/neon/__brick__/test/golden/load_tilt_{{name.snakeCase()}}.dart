// packages/{{name.snakeCase()}}/test/golden/load_tilt_{{name.snakeCase()}}.dart
import 'dart:io' show File;
import 'dart:typed_data' show ByteData;

import 'package:flutter/services.dart' show FontLoader;

/// The font family `{{name.titleCase()}}Text` renders with.
const String tilt{{name.titleCase()}}Family = 'Tilt{{name.titleCase()}}';

/// Loads the bundled Tilt{{name.titleCase()}} variable font into the test engine.
///
/// Without this the sign renders in the block glyphs `flutter_test` uses for
/// unknown families. The path is relative to the package root, which is the
/// working directory `flutter test` runs in.
Future<void> loadTilt{{name.titleCase()}}() async {
  final bytes = File('assets/fonts/Tilt{{name.titleCase()}}-Variable.ttf').readAsBytes();
  final loader = FontLoader(tilt{{name.titleCase()}}Family)
    ..addFont(bytes.then(ByteData.sublistView));

  await loader.load();
}
