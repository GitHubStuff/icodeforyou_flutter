# {{name.pascalCase()}}.md — rendering the widgets to PNG

## 1. Dependencies — nothing to add

`{{folder_source}}/{{name.snakeCase()}}/pubspec.yaml` already has everything the golden needs:

```yaml
dependencies:
  extensions: ^1.0.0
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  icodeforyou_lints: ^1.0.0
```

`matchesGoldenFile` ships with `flutter_test`. Do not add a golden toolkit.

## 2. Folder layout

```
{{folder_source}}/{{name}}/
  dart_test.yaml                       ← new (step 5)
  test/
    analysis_options.yaml              ← exists
    src/                               ← exists: unit/widget tests
    golden/                            ← new
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
// {{folder_source}}/{{name}}/test/golden/{{name}}_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{name}}/{{name}}.dart';

void main() {

  /// Tag that keeps these tests out of the coverage run.
  const golden = ['golden'];
}
```

To add a scenario: one more `testWidgets` with a `renderGolden` call and a
new file name. Adjust `logicalSize` if a scenario clips — `{{name.pascalCase()}}` at
`fontSize: 48` with `distance: 1` spreads its outer glow to 144 dp.

## 4. Register the tag

```yaml
# {{folder_source}}/{{name}}/dart_test.yaml
tags:
  golden:
    description: Writes PNG goldens. Platform-specific; run locally on macOS.
```

## 6. Generate the PNGs

From the monorepo root:

```sh
melos exec --scope="{{name}}" -- fvm flutter test --update-goldens --tags golden
```

Or inside the package:

```sh
cd {{folder_source}}/{{name}}
fvm flutter test --update-goldens --tags golden
```

Expected tail of the output: `00:0x +5: All tests passed!`

Output:

```
{{folder_source}}/{{name}}/test/golden/goldens/
  {{name}}_suffix.png
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
makes neon especially sensitive to anti-aliasing differences. Exclude the tag
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
# {{name}}

Widgets for {{name}}

## Quick reference

```sh
# Regenerate neon's PNGs
melos exec --scope="{{name}}" -- fvm flutter test --update-goldens --tags golden

# Normal test + coverage run, goldens excluded
melos run test
```

Output folder: `packages/{{name}}/test/golden/goldens/`
