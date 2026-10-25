// packages/{{name.snakeCase()}}/test/golden/{{name.snakeCase()}}_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';

import 'load_tilt_{{name.snakeCase()}}.dart';

void main() {
  setUpAll(loadTilt{{name.titleCase()}});

  /// Tag that keeps these tests out of the coverage run.
  const golden = ['golden'];

  /// Near-black so the glow has something to bloom into.
  const backdrop = Color(0xFF0B0B0F);

  /// Logical size of the surface and the scale factor. 3× turns 480×240
  /// logical pixels into a 1440×720 PNG with crisp glow gradients.
  const logicalSize = Size(480, 240);
  const scale = 3.0;

  /// Pumps [sign] on the backdrop and writes `goldens/<name>.png`.
  ///
  /// `flutter_test` disables shadows for determinism and asserts at the end
  /// of every test body that the flag is back to `true`. The halo *is*
  /// shadows, so the flag is cleared only for the duration of the capture
  /// and restored in `finally`, before the binding checks it.
  Future<void> renderGolden(
    WidgetTester tester,
    Widget sign,
    String name,
  ) async {
    tester.view
      ..physicalSize = logicalSize * scale
      ..devicePixelRatio = scale;
    addTearDown(tester.view.reset);

    debugDisableShadows = false;
    try {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: backdrop,
            body: Center(child: sign),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    } finally {
      debugDisableShadows = true;
    }
  }

  group('{{name.titleCase()}}Text', () {
    testWidgets('green, close', (tester) async {
      await renderGolden(
        tester,
        const {{name.titleCase()}}Text('OPEN', color: Colors.green),
        '{{name.snakeCase()}}_text_green',
      );
    }, tags: golden);

    testWidgets('pink, mid distance', (tester) async {
      await renderGolden(
        tester,
        const {{name.titleCase()}}Text('OPEN', color: Colors.pink, distance: 0.5),
        '{{name.snakeCase()}}_text_pink_distance_050',
      );
    }, tags: golden);

    testWidgets('cyan, far', (tester) async {
      await renderGolden(
        tester,
        const {{name.titleCase()}}Text('OPEN', color: Colors.cyan, distance: 1),
        '{{name.snakeCase()}}_text_cyan_distance_100',
      );
    }, tags: golden);
  });

  group('{{name.titleCase()}}Border', () {
    testWidgets('frames plain text', (tester) async {
      await renderGolden(
        tester,
        const {{name.titleCase()}}Border(
          color: Colors.orange,
          child: Text(
            'BAR',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
        ),
        '{{name.snakeCase()}}_border_orange',
      );
    }, tags: golden);

    testWidgets('frames {{name.titleCase()}}Text via the extension', (tester) async {
      await renderGolden(
        tester,
        const {{name.titleCase()}}Text(
          'OPEN',
          color: Colors.green,
        ).with{{name.titleCase()}}Border(color: Colors.green),
        '{{name.snakeCase()}}_sign_green',
      );
    }, tags: golden);
  });
}
