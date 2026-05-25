# Random Color Generator

A lightweight Flutter package that generates random, visually appealing colors using the HSL color space. Every generated color is designed to work well in both light and dark themes with readable text overlays.

## Why HSL?

Most naive random color generators operate in RGB space, which produces unpredictable results — you'll frequently get muddy browns, near-blacks, washed-out pastels, or blinding neons. HSL (Hue, Saturation, Lightness) solves this by giving independent control over three intuitive axes:

- **Hue** (0–360°) — the full visible spectrum, sampled uniformly so no color family is favored.
- **Saturation** (40–80%) — vibrant enough to feel intentional, restrained enough to avoid garish neons.
- **Lightness** (35–65%) — the mid-range sweet spot that avoids both near-white and near-black, ensuring the result is a *real* color regardless of the surrounding theme.

By constraining saturation and lightness while leaving hue unrestricted, every call to `generate()` returns a color that looks deliberately chosen rather than randomly thrown together.

## API

### `RandomColorGenerator.generate({int alpha = 255})`

Returns a random `Color` within the constrained HSL range.

**Use cases:**

- Assigning a unique color to a new user avatar or tag when no specific color is provided.
- Generating distinct background colors for list items, cards, or category chips.
- Creating color-coded identifiers for warehouse bins, equipment, or shipment groups.

```dart
final color = RandomColorGenerator.generate();
final semiTransparent = RandomColorGenerator.generate(alpha: 128);
```

### `RandomColorGenerator.toHex(Color color)`

Converts a `Color` to its `#AARRGGBB` hex string representation.

**Use cases:**

- Persisting a generated color to a database or shared preferences as a string.
- Displaying the hex value in a UI for debugging or user reference.
- Serializing colors for JSON payloads or API requests.

```dart
final hex = RandomColorGenerator.toHex(color); // e.g. "#FF4A8BC2"
```

### `RandomColorGenerator.fromHex(String hex)`

Parses a `#AARRGGBB` hex string back into a `Color`.

**Use cases:**

- Restoring a previously persisted color from storage.
- Deserializing color values received from an API or configuration file.

```dart
final color = RandomColorGenerator.fromHex('#FF4A8BC2');
```

### `RandomColorGenerator.contrastingTextColor(Color background)`

Returns `Colors.white` or `Colors.black` depending on which provides better contrast against the given background, based on relative luminance.

**Use cases:**

- Choosing readable text color for labels rendered on top of a generated background.
- Ensuring accessibility compliance (WCAG contrast) for dynamically colored UI elements.
- Setting icon or overlay colors on user-customizable surfaces.

```dart
final bg = RandomColorGenerator.generate();
final textColor = RandomColorGenerator.contrastingTextColor(bg);

Container(
  color: bg,
  child: Text('Readable', style: TextStyle(color: textColor)),
);
```

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  random_color_generator:
    path: packages/random_color_generator
```

## Requirements

- Flutter SDK
- Dart 3.0+


## HSL Details

```text
HSL = Hue, Saturation, Lightness
It's a way to describe colors that matches how humans think about them, unlike RGB which is how screens display them.
Hue (0-360°) — The "color" on a color wheel:

0° = Red
60° = Yellow
120° = Green
180° = Cyan
240° = Blue
300° = Magenta

Saturation (0-100%) — How vivid the color is:

0% = Gray (no color)
100% = Pure, vibrant color

Lightness (0-100%) — How bright:

0% = Black
50% = Pure color
100% = White

Why it's useful here: with RGB, getting a "medium brightness" color means balancing three values and hoping they don't combine into something too dark or too light. With HSL, you just set lightness to 35-65% and you're guaranteed a mid-range color regardless of hue.
Visual:

RGB: "Mix 138 red, 76 green, 107 blue" → ??? (hard to predict)
HSL: "Pink, vivid, medium bright" → Predictable result
```
