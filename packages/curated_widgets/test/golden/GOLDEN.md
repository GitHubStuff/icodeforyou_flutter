# CuratedWidgets.md — rendering the widgets to PNG

## 1. Folder layout

```
packages/curated_widgets/
  dart_test.yaml                       ← new (step 5)
  test/
    analysis_options.yaml              ← exists
    src/                               ← exists: unit/widget tests
    golden/                            ← new
      goldens/                         ← new, empty; the test fills it
```

Goldens live in their own folder so `test/src/` stays the pure behaviour
suite that feeds the LCOV target.

## 2. The golden test

One file, one PNG per scenario. A single `renderGolden` helper sets the
surface size, enables shadows, paints on black, pumps, captures, and
restores the shadow flag. Each test is one call to it.

Three details that are easy to get wrong, all verified against
Flutter 3.47 / `flutter_test`:

- **`tags` in the file /test/golden/curated_widgets_golden_test.dart,
  there is an example of how 'testWidgets()' has a tag. *NOTE:* Tags are
  within testWidgets() NOT in `group`**

To add a scenario: one more `testWidgets` with a `renderGolden` call and a
new file name. Adjust `logicalSize` if a scenario clips — `CuratedWidgets` at
`fontSize: 48` with `distance: 1` spreads its outer glow to 144 dp.

## 4. Register the tag

**THIS IS AUTO-COPIED FROM THE BRICK

```yaml
# packages/curated_widgets/dart_test.yaml
tags:
  golden:
    description: Writes PNG goldens. Platform-specific; run locally on macOS.

# This is commented out to keep golden test running for CI/CD and lcov reporting
exclude_tags: golden
```

## 6. Generate the PNGs

From the monorepo root:

```sh
melos exec --scope="curated_widgets" -- fvm flutter test --update-goldens --tags golden
```

Or inside the package:

```sh
cd packages/curated_widgets
fvm flutter test --update-goldens --tags golden
```

Expected tail of the output: `00:0x +5: All tests passed!`

Output:

```
packages/curated_widgets/test/golden/goldens/
  curated_widgets.png
```

Re-run after any change to the widgets; `--update-goldens` overwrites.

### If it says "No tests match the requested tag selectors"

The tag is missing from the `testWidgets` calls. It cannot be applied via
`group` (step 4).

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
# curated_widgets

Widgets for curated_widgets

## Quick reference

```sh
# Regenerate curated_widgets's PNGs
melos exec --scope="curated_widgets" -- fvm flutter test --update-goldens --tags golden

# Normal test + coverage run, goldens excluded
melos run test
```

Output folder: `packages/curated_widgets/test/golden/goldens/`
