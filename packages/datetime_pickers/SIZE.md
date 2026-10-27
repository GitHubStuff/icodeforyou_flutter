# PickerSize — sizing guide

How each `PickerSize` preset translates into picker dimensions, how wide
each picker comes out, and which presets fit on phones in portrait.

All dimensions are logical pixels. Widths in this document are **estimates**
derived from the formula below; the pickers measure their real column widths
at runtime with `TextPainter`, so treat these numbers as planning figures and
confirm against a device or golden test before hard-coding a layout.

## Presets

`height = itemExtent × visibleRows`. The scale follows two rules:
`itemExtent ≈ 1.5 × fontSize` and `groupSpacing = 2 × columnPadding`.

| Preset       | fontSize | itemExtent | visibleRows | columnPadding | groupSpacing | height | extent / font |
| ------------ | -------: | ---------: | ----------: | ------------: | -----------: | -----: | ------------: |
| `extraSmall` |       18 |         28 |           4 |             5 |           10 |    112 |          1.56 |
| `small`      |       22 |         34 |           4 |             6 |           12 |    136 |          1.55 |
| `medium`     |       24 |         36 |           4 |             7 |           14 |    144 |          1.50 |
| `large`      |       28 |         42 |           4 |             8 |           16 |    168 |          1.50 |
| `extraLarge` |       32 |         48 |           4 |            10 |           20 |    192 |          1.50 |
| `huge`       |       40 |         60 |           4 |            12 |           24 |    240 |          1.50 |

## Width model

Each wheel column is as wide as its widest label plus padding on both sides:

```
columnWidth = labelChars × fontSize × glyphFactor × textScale + 2 × columnPadding
```

| Assumption                           | Value | Note                                                                 |
| ------------------------------------ | ----: | -------------------------------------------------------------------- |
| Digit width (fraction of `fontSize`) |  0.60 | SF / Roboto digits are ~0.55–0.60 em; `8` is the widest digit.       |
| Letter width (fraction of `fontSize`)|  0.62 | Average for the widest three-letter month label in SF / Roboto.      |
| Widest month label                   |     3 | `Jan` … `Dec` are all three characters.                              |
| AM/PM label                          |     2 | `AM`, `PM`.                                                          |
| Accessibility text scale             |   1.0 | Pickers honour `MediaQuery.textScaler`; column widths scale with it. |
| Surface padding, each side           |    20 | Room for popover / bottom-sheet insets.                              |

Pickers compose columns as follows:

| Picker                   | Columns                                              |
| ------------------------ | ---------------------------------------------------- |
| `DatePicker`             | 2-digit + month + 4-digit                            |
| `TimePicker`, no seconds | 2-digit + 2-digit + AM/PM                            |
| `TimePicker`, seconds    | 2-digit + 2-digit + 2-digit + AM/PM                  |
| `FatPicker`              | `DatePicker` + `groupSpacing` + `TimePicker`         |

## Estimated column widths

| Preset       | 2-digit | Month | 4-digit | AM/PM |
| ------------ | ------: | ----: | ------: | ----: |
| `extraSmall` |      32 |    43 |      53 |    32 |
| `small`      |      38 |    53 |      65 |    39 |
| `medium`     |      43 |    59 |      72 |    44 |
| `large`      |      50 |    68 |      83 |    51 |
| `extraLarge` |      58 |    80 |      97 |    60 |
| `huge`       |      72 |    98 |     120 |    74 |

## Estimated picker widths

| Preset       | `DatePicker` | `TimePicker` (no sec) | `TimePicker` (sec) | `FatPicker` (no sec) | `FatPicker` (sec) |
| ------------ | -----------: | --------------------: | -----------------: | -------------------: | ----------------: |
| `extraSmall` |          128 |                    96 |                127 |                  234 |               265 |
| `small`      |          156 |                   116 |                154 |                  284 |               323 |
| `medium`     |          173 |                   129 |                172 |                  316 |               359 |
| `large`      |          201 |                   150 |                200 |                  367 |               416 |
| `extraLarge` |          235 |                   176 |                235 |                  431 |               490 |
| `huge`       |          290 |                   218 |                290 |                  532 |               604 |

## Phone widths

Logical widths in portrait, ascending. Pixel values vary slightly with the
display-size setting.

| Device              | Width |
| ------------------- | ----: |
| iPhone SE (3rd gen) |   375 |
| iPhone 13 mini      |   375 |
| iPhone 16           |   393 |
| iPhone 16 Pro       |   402 |
| Pixel 8 / 9         |   412 |
| Pixel 9 Pro XL      |   412 |
| iPhone 16 Pro Max   |   440 |

Smallest device: **375**. Usable width after 20 px padding each side: **335**.

## Phone fit

A picker fits when `width + 2 × 20 ≤ deviceWidth`. Headroom is the spare width
on the smallest (375 px) device; negative means overflow.

| Preset       | Picker                   | Width | Fits 375? | Headroom | Smallest phone it fits |
| ------------ | ------------------------ | ----: | :-------: | -------: | ---------------------- |
| `extraSmall` | `DatePicker`             |   128 |    Yes    |      207 | iPhone SE              |
| `extraSmall` | `TimePicker` (no sec)    |    96 |    Yes    |      239 | iPhone SE              |
| `extraSmall` | `TimePicker` (sec)       |   127 |    Yes    |      208 | iPhone SE              |
| `extraSmall` | `FatPicker` (no sec)     |   234 |    Yes    |      101 | iPhone SE              |
| `extraSmall` | `FatPicker` (sec)        |   265 |    Yes    |       70 | iPhone SE              |
| `small`      | `DatePicker`             |   156 |    Yes    |      179 | iPhone SE              |
| `small`      | `TimePicker` (no sec)    |   116 |    Yes    |      219 | iPhone SE              |
| `small`      | `TimePicker` (sec)       |   154 |    Yes    |      181 | iPhone SE              |
| `small`      | `FatPicker` (no sec)     |   284 |    Yes    |       51 | iPhone SE              |
| `small`      | `FatPicker` (sec)        |   323 |    Yes    |       12 | iPhone SE              |
| `medium`     | `DatePicker`             |   173 |    Yes    |      162 | iPhone SE              |
| `medium`     | `TimePicker` (no sec)    |   129 |    Yes    |      206 | iPhone SE              |
| `medium`     | `TimePicker` (sec)       |   172 |    Yes    |      163 | iPhone SE              |
| `medium`     | `FatPicker` (no sec)     |   316 |    Yes    |       19 | iPhone SE              |
| `medium`     | `FatPicker` (sec)        |   359 |    No     |      −24 | iPhone 16 Pro          |
| `large`      | `DatePicker`             |   201 |    Yes    |      134 | iPhone SE              |
| `large`      | `TimePicker` (no sec)    |   150 |    Yes    |      185 | iPhone SE              |
| `large`      | `TimePicker` (sec)       |   200 |    Yes    |      135 | iPhone SE              |
| `large`      | `FatPicker` (no sec)     |   367 |    No     |      −32 | Pixel 8 / 9            |
| `large`      | `FatPicker` (sec)        |   416 |    No     |      −81 | none                   |
| `extraLarge` | `DatePicker`             |   235 |    Yes    |      100 | iPhone SE              |
| `extraLarge` | `TimePicker` (no sec)    |   176 |    Yes    |      159 | iPhone SE              |
| `extraLarge` | `TimePicker` (sec)       |   235 |    Yes    |      100 | iPhone SE              |
| `extraLarge` | `FatPicker` (no sec)     |   431 |    No     |      −96 | none                   |
| `extraLarge` | `FatPicker` (sec)        |   490 |    No     |     −155 | none                   |
| `huge`       | `DatePicker`             |   290 |    Yes    |       45 | iPhone SE              |
| `huge`       | `TimePicker` (no sec)    |   218 |    Yes    |      117 | iPhone SE              |
| `huge`       | `TimePicker` (sec)       |   290 |    Yes    |       45 | iPhone SE              |
| `huge`       | `FatPicker` (no sec)     |   532 |    No     |     −197 | none                   |
| `huge`       | `FatPicker` (sec)        |   604 |    No     |     −269 | none                   |

## Recommendations for phones

| Use                            | Preset                  | Width | Height | Reason                                                                                                   |
| ------------------------------ | ----------------------- | ----: | -----: | -------------------------------------------------------------------------------------------------------- |
| `DatePicker` alone             | `medium`                |   173 |    144 | Fits every phone with ample margin; `large` also fits but leaves little room on 375 px.                 |
| `TimePicker` alone, no seconds | `medium`                |   129 |    144 | Narrower than `DatePicker`; comfortable everywhere.                                                      |
| `FatPicker`, no seconds        | `small`                 |   284 |    136 | `medium` fits 375 px with only 19 px headroom and overflows at larger accessibility text sizes.          |
| `FatPicker`, with seconds      | `extraSmall`            |   265 |    112 | Only `extraSmall` leaves usable headroom on 375 px; prefer hiding seconds in a side-by-side layout.      |
| Tablets (`shortestSide ≥ 600`) | `large` / `extraLarge`  |     — |      — | Opt up explicitly at the call site via `MediaQuery.sizeOf(context).shortestSide`.                        |

Height is never the constraint on phones; width is. Re-check the fit table
after changing any preset or assumption, and remember that accessibility text
scaling widens every column proportionally while padding stays fixed.
