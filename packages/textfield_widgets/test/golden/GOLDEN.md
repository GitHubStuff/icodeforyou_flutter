# {name.titleCase()}.md — rendering the `textfield_widgets` widgets to PNG

How to produce pixel-accurate PNGs of `Textfield Widgets` from the
`textfield_widgets` package, headlessly, with `flutter test`. No device, emulator or
simulator. The images are what the real engine draws, so they are fit for the
package README, Widgetbook screenshots, or a design review.

Everything below is specific to `packages/textfield_widgets` and has been run end to end.
Paths are relative to the monorepo root unless stated.

---

## 1. Dependencies

## 2. Folder layout

```
packages/textfield_widgets/
  dart_test.yaml                       ← new (step 5)
  test/
    analysis_options.yaml              ← exists
    src/                               ← exists: unit/widget tests
    golden/                            ← new
      GOLDEN.md
      goldens/                         ← new, empty; the test fills it
```

Goldens live in their own folder so `test/src/` stays the pure behaviour
suite that feeds the LCOV target.

## 3. The golden test

One file, one PNG per scenario. A single `renderGolden` helper sets the
surface size, enables shadows, paints on black, pumps, captures, and
restores the shadow flag. Each test is one call to it.

Three details that are easy to get wrong, all verified against Flutter
3.47 / `flutter_test`:

- **`debugDisableShadows` must be restored inside the test body.** The
  binding asserts that every painting debug variable is back to its default
  at the *end of the body*, before `addTearDown` callbacks run. Restoring it
  in a tear-down fails every test with "The value of a painting debug
  variable was changed by the test." Use `try`/`finally` around the capture.
- **`tags` goes on `testWidgets`, not `group`.** `flutter_test` wraps
  `group` in its own function that accepts only `skip` and `retry`; passing
  `tags` there is a compile error. Every `testWidgets` carries the tag.
- **`debugDisableShadows` comes from `material.dart`.** A separate
  `rendering.dart` import is flagged as unnecessary by the analyzer.

```dart
// packages/textfield_widgets/test/golden/textfield_widgets_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:textfield_widgets/textfield_widgets.dart';

import 'load_tilt_textfield_widgets.dart';

void main() {
  setUpAll(loadTiltTextfield Widgets);

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

  group('Textfield Widgets', () {
    testWidgets('green, close', (tester) async {
      await renderGolden(
        tester,
        const Textfield WidgetsText('OPEN', color: Colors.green),
        'textfield_widgets_text_green',
      );
    }, tags: golden);

    testWidgets('pink, mid distance', (tester) async {
      await renderGolden(
        tester,
        const Textfield WidgetsText('OPEN', color: Colors.pink, distance: 0.5),
        'textfield_widgets_text_pink_distance_050',
      );
    }, tags: golden);

    testWidgets('cyan, far', (tester) async {
      await renderGolden(
        tester,
        const Textfield WidgetsText('OPEN', color: Colors.cyan, distance: 1),
        'textfield_widgets_text_cyan_distance_100',
      );
    }, tags: golden);
  });

  group('Textfield WidgetsBorder', () {
    testWidgets('frames plain text', (tester) async {
      await renderGolden(
        tester,
        const Textfield WidgetsBorder(
          color: Colors.orange,
          child: Text(
            'BAR',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
        ),
        'textfield_widgets_border_orange',
      );
    }, tags: golden);

    testWidgets('frames Textfield WidgetsText via the extension', (tester) async {
      await renderGolden(
        tester,
        const Textfield WidgetsText(
          'OPEN',
          color: Colors.green,
        ).withTextfield WidgetsBorder(color: Colors.green),
        'textfield_widgets_sign_green',
      );
    }, tags: golden);
  });
}
```

To add a scenario: one more `testWidgets` with a `renderGolden` call and a
new file name. Adjust `logicalSize` if a scenario clips — `Textfield WidgetsText` at
`fontSize: 48` with `distance: 1` spreads its outer glow to 144 dp.

## 5. Register the tag

```yaml
# packages/textfield_widgets/dart_test.yaml
tags:
  golden:
    description: Writes PNG goldens. Platform-specific; run locally on macOS.

exclude: golden
```

## 6. Generate the PNGs

From the monorepo root:

```sh
melos exec --scope="textfield_widgets" -- fvm flutter test --update-goldens --tags golden
```

Or inside the package:

```sh
cd packages/textfield_widgets
fvm flutter test --update-goldens --tags golden
```

Expected tail of the output: `00:0x +5: All tests passed!`

Output:

```
packages/textfield_widgets/test/golden/goldens/
  textfield_widgets***.png
```

Re-run after any change to the widgets; `--update-goldens` overwrites.

### If it says "No tests match the requested tag selectors"

The tag is missing from the `testWidgets` calls. It cannot be applied via
`group` (step 4).

### If every test fails with "painting debug variable was changed"

`debugDisableShadows` is being restored in `addTearDown` instead of a
`finally` inside the body (step 4).

## 7. Keep goldens out of the coverage run

Rasterisation is not byte-identical across macOS and Linux, and the glow
makes textfield_widgets especially sensitive to anti-aliasing differences. Exclude the tag
from the normal run so the 100% LCOV gate never depends on a pixel diff:

```sh
fvm flutter test --exclude-tags golden --coverage
```

In the root `melos.yaml` test script:

```yaml
scripts:
  test:
    run: melos exec --dir-exists=test -- fvm flutter test --exclude-tags golden --coverage
```

The golden files contribute no coverage and require none; they are
documentation, not verification.

## 8. Commit the PNGs and use them

Commit `test/golden/goldens/*.png` — they are the package's visual
documentation. The `README.md` is still the pub template with every section
reading `TODO`; replace it and embed the renders:

```markdown
# textfield_widgets

Glowing textfield_widgets-sign widgets for Flutter.

## Textfield WidgetsText

![Textfield WidgetsText, green](test/golden/goldens/textfield_widgets_text_green.png)

## Distance

![Textfield WidgetsText at distance 0.5](test/golden/goldens/textfield_widgets_text_pink_distance_050.png)
![Textfield WidgetsText at distance 1.0](test/golden/goldens/textfield_widgets_text_cyan_distance_100.png)

## Textfield WidgetsBorder

![Textfield WidgetsBorder](test/golden/goldens/textfield_widgets_border_orange.png)
![Textfield WidgetsText inside Textfield WidgetsBorder](test/golden/goldens/textfield_widgets_sign_green.png)
```

Regenerate on a Mac whenever the glow constants or the font change, and
commit the refreshed images in the same change as the widget edit.

## Quick reference

```sh
# Regenerate textfield_widgets's PNGs
melos exec --scope="textfield_widgets" -- fvm flutter test --update-goldens --tags golden

# Normal test + coverage run, goldens excluded
melos run test
```

Output folder: `packages/textfield_widgets/test/golden/goldens/`
