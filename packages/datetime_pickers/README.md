<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# datetime_popover_pickers

Compact, Cupertino-style wheel pickers for dates, 12-hour times, and both
together — sized for popovers, bottom sheets and inline cards rather than
full-screen dialogs. Every picker is built from `CupertinoPicker` columns
that share a single selection overlay, with column widths measured from
each column's widest label so nothing wraps, clips or jitters as the wheels
spin.

Use it when `CupertinoDatePicker` is too wide, too tall, or too opinionated
about its layout, and you want a picker whose exact size you can predict
and place.

## Features

- **`DatePicker`** — day / abbreviated-month / year wheels. Days beyond the
  end of the selected month are greyed out and the wheel snaps back to the
  last valid day when the month or year changes.
- **`TimePicker`** — 12-hour clock with hour / minute / optional second /
  AM-PM wheels. Emits a `DateTime` in 24-hour form.
- **`FatPicker`** — `DatePicker` and `TimePicker` side by side, merged into
  one `DateTime` callback.
- **`PickerSize`** — four presets (`compact`, `regular`, `large`,
  `expanded`) that fix font size, row height, visible rows, column padding
  and group spacing together, so typography and geometry never drift apart.
- **Measured column widths.** Each column is as wide as its widest label
  (`88`, `8888`, the longest month, `AM`/`PM`) plus padding, measured with
  the resolved text style and the ambient `TextScaler`. Columns do not
  stretch, so the picker's width is intrinsic and stable.
- **One shared selection overlay.** A single
  `CupertinoPickerDefaultSelectionOverlay` spans all columns instead of one
  per wheel.
- **Theme-aware text.** Labels resolve from
  `CupertinoTheme.of(context).textTheme.pickerTextStyle`, merged with your
  `textStyle` for colour / weight / family, with the font size always taken
  from the `PickerSize`.
- **Time-of-day preserved.** `DatePicker` keeps the hour, minute and second
  of `initialDate` in every value it emits; `TimePicker` keeps the calendar
  date of `initialTime`.
- **Year range control** with inclusive `minimumYear` / `maximumYear`
  (defaults `1800`–`2100`), asserted at construction.
- **Looping wheels** for day, month, hour, minute and second; non-looping
  for year and AM/PM.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  datetime_popover_pickers:
```

The package depends on `flutter` (Cupertino) and `intl`. You do not need to
add `intl` yourself unless you use it directly.

Import the barrel file:

```dart
import 'package:datetime_popover_pickers/datetime_popover_pickers.dart';
```

The pickers read `CupertinoTheme`, `Directionality` and `MediaQuery` from
the tree. They work inside `CupertinoApp` directly; inside `MaterialApp`
they also work because Material installs a `CupertinoTheme` for you.

> **Name clash.** `DatePicker` and `TimePicker` do not collide with any
> Flutter widget, but if you also import a package that exports those names,
> import this one with a prefix:
>
> ```dart
> import 'package:datetime_popover_pickers/datetime_popover_pickers.dart'
>     as pickers;
> ```

## Usage

The three pickers share one shape: an optional initial value, a
`PickerSize`, an optional `TextStyle`, and a callback that fires with a full
`DateTime` whenever any wheel settles.

```dart
DatePicker(
  onDateChanged: (date) => debugPrint('$date'),
)
```

### Examples

#### A date picker with defaults

`size` defaults to `PickerSize.regular`, the year range to `1800`–`2100`,
and `initialDate` to `DateTime.now()`.

```dart
DatePicker(
  onDateChanged: (date) => setState(() => _birthday = date),
)
```

#### A date picker with a fixed initial date and year range

```dart
DatePicker(
  initialDate: DateTime(1990, 6, 15),
  minimumYear: 1900,
  maximumYear: DateTime.now().year,
  size: PickerSize.large,
  onDateChanged: (date) => setState(() => _birthday = date),
)
```

If `initialDate.year` falls outside the range it is clamped to the nearest
bound; the day and month are kept.

#### A time picker without seconds

Hour, minute and AM/PM wheels. Emitted values always have `second == 0`.

```dart
TimePicker(
  size: PickerSize.regular,
  showSeconds: false,
  initialTime: DateTime(2024, 1, 1, 9, 30),
  onTimeChanged: (time) => setState(() => _alarm = time),
)
```

#### A time picker with seconds

```dart
TimePicker(
  size: PickerSize.compact,
  showSeconds: true,
  initialTime: DateTime.now(),
  onTimeChanged: (time) => debugPrint('${time.hour}:${time.minute}:${time.second}'),
)
```

The wheels display a 12-hour clock; the `DateTime` you receive is 24-hour.
`12 AM` emits `hour == 0`, `12 PM` emits `hour == 12`.

#### Date and time together with `FatPicker`

One row, one merged `DateTime`. The date wheels and time wheels are
separated by `size.groupSpacing`.

```dart
FatPicker(
  size: PickerSize.regular,
  showSeconds: false,
  initialDateTime: DateTime.now(),
  onDateTimeChanged: (dateTime) => setState(() => _scheduledAt = dateTime),
)
```

With seconds and a bounded year range:

```dart
FatPicker(
  size: PickerSize.compact,
  showSeconds: true,
  minimumYear: 2020,
  maximumYear: 2030,
  initialDateTime: DateTime(2025, 3, 1, 14, 5, 30),
  onDateTimeChanged: (dateTime) => _cubit.setDeadline(dateTime),
)
```

#### Choosing a size preset

Each preset fully determines font size, row height and padding. Pick by the
space you have, not by the font you want.

```dart
// 22 sp labels, 34 px rows, 136 px tall — fits a small popover.
DatePicker(size: PickerSize.compact, onDateChanged: _onDate)

// 24 sp labels, 36 px rows, 144 px tall — the default.
DatePicker(size: PickerSize.regular, onDateChanged: _onDate)

// 28 sp labels, 42 px rows, 168 px tall — bottom sheets.
DatePicker(size: PickerSize.large, onDateChanged: _onDate)

// 32 sp labels, 48 px rows, 192 px tall — tablets and large phones.
DatePicker(size: PickerSize.expanded, onDateChanged: _onDate)
```

| Preset     | Font | Row  | Rows | Height | Column pad | Group gap |
| ---------- | ---- | ---- | ---- | ------ | ---------- | --------- |
| `compact`  | 22   | 34   | 4    | 136    | 6          | 12        |
| `regular`  | 24   | 36   | 4    | 144    | 7          | 14        |
| `large`    | 28   | 42   | 4    | 168    | 8          | 16        |
| `expanded` | 32   | 48   | 4    | 192    | 10         | 20        |

The height is available as `size.height`:

```dart
SizedBox(
  height: PickerSize.large.height,
  child: Row(
    children: [
      const Text('Due'),
      const Spacer(),
      DatePicker(size: PickerSize.large, onDateChanged: _onDate),
    ],
  ),
)
```

#### Styling the labels

`textStyle` overrides colour, weight and family. Font size is always taken
from the preset and cannot be overridden here — set `size` instead.

```dart
TimePicker(
  size: PickerSize.regular,
  showSeconds: false,
  textStyle: const TextStyle(
    color: CupertinoColors.activeBlue,
    fontWeight: FontWeight.w600,
    fontFamily: 'Menlo',
  ),
  onTimeChanged: _onTime,
)
```

Follow the Material theme inside a `MaterialApp`:

```dart
DatePicker(
  textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
  onDateChanged: _onDate,
)
```

#### Inside a Cupertino popover

The package is named for this use. Wrap the picker in a
`CupertinoPopupSurface` and show it with `showCupertinoModalPopup`.

```dart
Future<DateTime?> pickDate(BuildContext context, DateTime initial) {
  var selected = initial;
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => CupertinoPopupSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Done'),
              ),
            ],
          ),
          DatePicker(
            size: PickerSize.large,
            initialDate: initial,
            onDateChanged: (date) => selected = date,
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
```

#### Inside a Material bottom sheet

```dart
Future<void> showTimeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: TimePicker(
          size: PickerSize.expanded,
          showSeconds: false,
          initialTime: DateTime.now(),
          onTimeChanged: (time) => context.read<ReminderCubit>().setTime(time),
        ),
      ),
    ),
  );
}
```

#### Anchored popover with `showMenu`-style positioning

Because the picker's size is known from `size.height` and its intrinsic
width, it can be placed in an `Overlay` or a `PopupMenu`-like surface
without measuring first.

```dart
class DateField extends StatefulWidget {
  const DateField({super.key});

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  final _link = LayerLink();
  OverlayEntry? _entry;
  DateTime _value = DateTime.now();

  void _toggle() {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
      return;
    }
    _entry = OverlayEntry(
      builder: (_) => Positioned(
        width: 260,
        child: CompositedTransformFollower(
          link: _link,
          offset: const Offset(0, 48),
          child: CupertinoPopupSurface(
            child: DatePicker(
              size: PickerSize.compact,
              initialDate: _value,
              onDateChanged: (date) => setState(() => _value = date),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: CupertinoButton(
        onPressed: _toggle,
        child: Text('${_value.day}/${_value.month}/${_value.year}'),
      ),
    );
  }
}
```

#### Preserving time-of-day through a `DatePicker`

`DatePicker` carries the hour, minute and second from `initialDate` into
every emitted value, so you can keep a time the user already chose while
they change only the date.

```dart
DatePicker(
  initialDate: DateTime(2024, 12, 21, 13, 47, 22),
  onDateChanged: (date) {
    // Scrolling to 5 Jan 2025 emits DateTime(2025, 1, 5, 13, 47, 22).
    setState(() => _appointment = date);
  },
)
```

Likewise `TimePicker` keeps the year, month and day of `initialTime`:

```dart
TimePicker(
  size: PickerSize.regular,
  showSeconds: false,
  initialTime: _appointment,
  onTimeChanged: (time) {
    // Year, month and day are those of _appointment; only h:m change.
    setState(() => _appointment = time);
  },
)
```

#### Month-end snapping

The day wheel always shows 1–31. Days past the end of the selected month
are rendered in `CupertinoColors.inactiveGray`, and when the month or year
wheel lands on a shorter month the day wheel animates back to the last
valid day. Emitted values are already clamped, so you never receive
`31 Feb`.

```dart
DatePicker(
  initialDate: DateTime(2024, 1, 31),
  onDateChanged: (date) {
    // Scrolling the month wheel from Jan to Feb emits DateTime(2024, 2, 29)
    // and the day wheel animates from 31 to 29.
    debugPrint('$date');
  },
)
```

#### Wiring into a Cubit

The pickers are uncontrolled: the initial value seeds the wheels and the
widget owns the position afterwards. Push changes into your state through
the callback.

```dart
BlocBuilder<EventCubit, EventState>(
  buildWhen: (previous, current) => previous.id != current.id,
  builder: (context, state) {
    return FatPicker(
      key: ValueKey(state.id),
      size: PickerSize.regular,
      showSeconds: false,
      initialDateTime: state.startsAt,
      onDateTimeChanged: context.read<EventCubit>().setStartsAt,
    );
  },
)
```

The `key` forces a fresh picker when a different event is loaded; without
it the wheels would keep their old positions.

#### Two pickers for a range

```dart
Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text('From'),
    DatePicker(
      size: PickerSize.compact,
      initialDate: _from,
      onDateChanged: (date) => setState(() => _from = date),
    ),
    const SizedBox(height: 12),
    const Text('To'),
    DatePicker(
      size: PickerSize.compact,
      initialDate: _to,
      minimumYear: _from.year,
      onDateChanged: (date) => setState(() => _to = date),
    ),
  ],
)
```

#### Displaying the chosen value

The package formats nothing for you. Use `intl` with the same patterns the
pickers' labels follow.

```dart
import 'package:intl/intl.dart';

final dateLabel = DateFormat('d MMM yyyy').format(_value);     // 21 Dec 2024
final timeLabel = DateFormat('h:mm a').format(_value);         // 1:47 PM
final fullLabel = DateFormat('d MMM yyyy h:mm:ss a').format(_value);
```

#### Testing

The pickers need a `CupertinoTheme`, `Directionality` and `MediaQuery`;
`CupertinoApp` supplies all three. Drive the wheels with `tester.drag` by
one `itemExtent` per step.

```dart
testWidgets('scrolling the hour wheel emits the new hour', (tester) async {
  final emitted = <DateTime>[];

  await tester.pumpWidget(
    CupertinoApp(
      home: Center(
        child: TimePicker(
          size: PickerSize.regular,
          showSeconds: false,
          initialTime: DateTime(2024, 1, 1, 9, 0),
          onTimeChanged: emitted.add,
        ),
      ),
    ),
  );

  // Move the hour wheel down one row: 9 -> 10.
  await tester.drag(find.text('9'), Offset(0, -PickerSize.regular.itemExtent));
  await tester.pumpAndSettle();

  expect(emitted.last.hour, 10);
  expect(emitted.last.minute, 0);
});
```

## Additional information

### Design notes

- **Why not `CupertinoDatePicker`?** It owns its width, paints one overlay
  per column in some modes, and offers no control over row height or font
  size. These pickers expose exactly those knobs through `PickerSize` and
  size themselves to their content.
- **Column width measurement.** Widths are measured with a `TextPainter`
  using the resolved style, the ambient `Directionality` and the ambient
  `TextScaler`, so accessibility text scaling widens the columns rather than
  clipping them. `88` and `8888` are used as the widest two- and four-digit
  samples because `8` is the widest digit in virtually every Latin typeface.
- **12-hour only.** `TimePicker` always shows an AM/PM wheel. There is no
  24-hour mode.
- **English month labels.** The month wheel shows `Jan` … `Dec` as fixed
  strings; it is not localised.
- **Uncontrolled.** Initial values seed the scroll controllers in
  `initState`. Supply a new `Key` to reset a picker to a different value.
- **Assertions.** `DatePicker` asserts `minimumYear <= maximumYear` at
  construction.

### Public API

| Export       | Kind                                         |
| ------------ | -------------------------------------------- |
| `DatePicker` | `StatefulWidget` — day / month / year        |
| `TimePicker` | `StatefulWidget` — hour / minute / [second] / AM-PM |
| `FatPicker`  | `StatefulWidget` — `DatePicker` + `TimePicker` |
| `PickerSize` | `enum` — `compact`, `regular`, `large`, `expanded` |

`DatePicker.defaultMinimumYear` (`1800`) and `DatePicker.defaultMaximumYear`
(`2100`) are also public.

### Contributing

This package lives in the `icodeforyou_flutter` monorepo and is managed with
Melos. Contributions must keep 100% LCOV coverage and pass
`very_good_analysis` with no warnings:

```sh
melos bootstrap
melos run analyze
melos run test
```

### Issues

File issues in the monorepo's issue tracker. Include a minimal reproduction
(a single picker inside a `CupertinoApp` is usually enough), the
`PickerSize` in use, and the Flutter version from `fvm flutter --version`.