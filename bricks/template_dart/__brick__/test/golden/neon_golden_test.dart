// {{folder_source}}/{{name}}/test/golden/{{name}}_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Tag that keeps these tests out of the coverage run.
  const golden = ['golden'];

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

  group('NeonText', () {
    testWidgets('green, close', (tester) async {
      await renderGolden(
        tester,
        const NeonText('OPEN', color: Colors.green),
        'neon_text_green',
      );
    }, tags: golden);

    testWidgets('pink, mid distance', (tester) async {
      await renderGolden(
        tester,
        const NeonText('OPEN', color: Colors.pink, distance: 0.5),
        'neon_text_pink_distance_050',
      );
    }, tags: golden);

    testWidgets('cyan, far', (tester) async {
      await renderGolden(
        tester,
        const NeonText('OPEN', color: Colors.cyan, distance: 1),
        'neon_text_cyan_distance_100',
      );
    }, tags: golden);
  });

  group('NeonBorder', () {
    testWidgets('frames plain text', (tester) async {
      await renderGolden(
        tester,
        const NeonBorder(
          color: Colors.orange,
          child: Text(
            'BAR',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
        ),
        'neon_border_orange',
      );
    }, tags: golden);

    testWidgets('frames NeonText via the extension', (tester) async {
      await renderGolden(
        tester,
        const NeonText(
          'OPEN',
          color: Colors.green,
        ).withNeonBorder(color: Colors.green),
        'neon_sign_green',
      );
    }, tags: golden);
  });
}
