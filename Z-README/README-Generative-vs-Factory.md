# Generative vs Factory Constructors in Dart

This note expands on the difference between a *named generative constructor*
such as `CaptionSwitch.text({...})` and a *factory constructor* such as
`factory CaptionSwitch.text({...})`, with worked examples and a pro/con
summary for each.

The short version: **a generative constructor builds the object in place; a
factory constructor returns an object.** That one distinction drives every
other difference.

---

## 1. Generative constructors

A generative constructor is obliged to initialise every `final` field of the
class it belongs to. By the time its body runs, `this` already exists and is
fully initialised. It cannot `return` a value.

### 1.1 Unnamed generative constructor

```dart
class Point {
  const Point(this.x, this.y);

  final double x;
  final double y;
}
```

### 1.2 Named generative constructor

```dart
class Point {
  const Point(this.x, this.y);

  /// Named generative constructor: still initialises every field,
  /// just via the initializer list instead of `this.` parameters.
  const Point.origin()
      : x = 0,
        y = 0;

  final double x;
  final double y;
}
```

### 1.3 Initializer list with computed values (the `CaptionSwitch.text` case)

```dart
class CaptionSwitch extends StatelessWidget {
  const CaptionSwitch({
    required this.caption,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  CaptionSwitch.text({
    required String caption,
    required this.value,
    required this.onChanged,
    String? subtitle,
    TextStyle? textStyle,
    TextStyle? subtitleStyle,
    super.key,
  })  : caption = Text(caption, style: textStyle),
        subtitle = _optionalText(subtitle, subtitleStyle);

  final Widget caption;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  static Text? _optionalText(String? data, TextStyle? style) =>
      data == null ? null : Text(data, style: style);

  @override
  Widget build(BuildContext context) => SwitchListTile(
        title: caption,
        subtitle: subtitle,
        value: value,
        onChanged: onChanged,
      );
}
```

Points to note:

- `caption` the *parameter* is a `String`; `caption` the *field* is a `Widget`.
  The initializer list bridges the two. The parameter shadows the field name
  inside the parameter list only.
- `super.key` works because this is a generative constructor and can forward
  to the superclass constructor.
- It is **not** `const` because `Text(caption, ...)` depends on a runtime
  argument. That is inherent; a factory would not fix it.

### 1.4 Redirecting generative constructor

A generative constructor can delegate wholesale to another generative
constructor in the same class with `this(...)`:

```dart
class Rgb {
  const Rgb(this.r, this.g, this.b);

  const Rgb.grey(int level) : this(level, level, level);

  const Rgb.black() : this.grey(0);

  final int r;
  final int g;
  final int b;
}
```

### 1.5 Initializer list assertions

```dart
class Percentage {
  const Percentage(this.value)
      : assert(value >= 0 && value <= 100, 'value must be 0..100');

  final int value;
}
```

### 1.6 Calling a superclass generative constructor

```dart
class Shape {
  const Shape(this.name);

  final String name;
}

class Circle extends Shape {
  const Circle(this.radius) : super('circle');

  final double radius;
}
```

Only generative constructors can be the target of `super(...)`. This matters
later.

---

## 2. Factory constructors

A factory constructor does **not** initialise fields and has no `this`. It is
effectively a static method with constructor syntax: it runs, it `return`s,
and whatever it returns is the result of the `new` expression. That value may
be a freshly constructed instance, a cached one, or an instance of a subtype.

### 2.1 Factory delegating to a generative constructor

```dart
class Temperature {
  const Temperature._celsius(this.celsius);

  factory Temperature.fromFahrenheit(double f) =>
      Temperature._celsius((f - 32) * 5 / 9);

  final double celsius;
}
```

Here the factory exists only to compute an argument before calling the real
constructor. A named generative constructor with an initializer list would do
the same job and could even be `const`:

```dart
  const Temperature.fromFahrenheit(double f) : celsius = (f - 32) * 5 / 9;
```

So this is a case where `factory` is *allowed* but not *required*.

### 2.2 Singleton / caching

```dart
class Logger {
  Logger._();

  static final Logger _instance = Logger._();

  /// Every call returns the same object. Impossible with a generative
  /// constructor, which must always allocate a new one.
  factory Logger() => _instance;
}
```

A keyed cache follows the same pattern:

```dart
class Currency {
  Currency._(this.code);

  static final Map<String, Currency> _cache = {};

  factory Currency(String code) =>
      _cache.putIfAbsent(code, () => Currency._(code));

  final String code;
}
```

### 2.3 Returning a subtype

```dart
abstract class Animal {
  const Animal();

  /// Decides at runtime which concrete class to build.
  factory Animal.fromKind(String kind) => switch (kind) {
        'dog' => const Dog(),
        'cat' => const Cat(),
        _ => throw ArgumentError.value(kind, 'kind', 'unknown animal'),
      };

  String speak();
}

class Dog extends Animal {
  const Dog();

  @override
  String speak() => 'woof';
}

class Cat extends Animal {
  const Cat();

  @override
  String speak() => 'meow';
}
```

A generative constructor on `Animal` could never produce a `Dog`.

### 2.4 Deserialisation

```dart
class User {
  const User({required this.id, required this.name});

  factory User.fromJson(Map<String, Object?> json) => User(
        id: json['id']! as int,
        name: json['name']! as String,
      );

  final int id;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'name': name};
}
```

`fromJson` is conventionally a factory because the mapping logic often
requires statements (validation, loops, early throws) that cannot live in an
initializer list. If it *can* be expressed as pure field initialisers, a
generative constructor is equally valid.

### 2.5 Factory on an abstract class with a private implementation

```dart
abstract class Clock {
  factory Clock() = _SystemClock;

  DateTime now();
}

class _SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now();
}
```

The `= _SystemClock` form is a **redirecting factory constructor**. It is how
Flutter and the SDK expose public interfaces backed by private concrete
classes (`Map()`, `List()`, `Stream.fromIterable`, etc.).

### 2.6 Redirecting factory constructor to a subclass

```dart
abstract class Button extends StatelessWidget {
  const Button({super.key});

  factory Button.primary({required VoidCallback onPressed, Key? key}) =
      _PrimaryButton;

  factory Button.secondary({required VoidCallback onPressed, Key? key}) =
      _SecondaryButton;
}

class _PrimaryButton extends Button {
  const _PrimaryButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: onPressed, child: const Text('OK'));
}

class _SecondaryButton extends Button {
  const _SecondaryButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed, child: const Text('Cancel'));
}
```

---

## 3. Side-by-side: the same intent both ways

### 3.1 Converting arguments to fields

```dart
// Generative — preferred when the conversion is a pure expression.
class Label {
  const Label.upper(String text) : text = text.toUpperCase();  // not const-able at runtime; shown for shape only

  final String text;
}

// Factory — needed only if statements are required.
class Label {
  const Label._(this.text);

  factory Label.upper(String text) {
    if (text.isEmpty) throw ArgumentError('text must not be empty');
    final trimmed = text.trim();
    return Label._(trimmed.toUpperCase());
  }

  final String text;
}
```

### 3.2 What a factory version of `CaptionSwitch.text` would look like

```dart
factory CaptionSwitch.text({
  required String caption,
  required bool value,
  required ValueChanged<bool>? onChanged,
  String? subtitle,
  TextStyle? textStyle,
  TextStyle? subtitleStyle,
  Key? key,
}) =>
    CaptionSwitch(
      caption: Text(caption, style: textStyle),
      subtitle: subtitle == null ? null : Text(subtitle, style: subtitleStyle),
      value: value,
      onChanged: onChanged,
      key: key,
    );
```

Compared with the generative version this:

- repeats every parameter type because `this.value` / `super.key` are
  unavailable;
- plumbs `key` manually;
- adds a second call frame for no behavioural gain;
- blocks any future subclass from writing `super.text(...)`.

The generative constructor is the correct choice.

---

## 4. Rules at a glance

| Capability                                   | Generative | Factory |
| -------------------------------------------- | :--------: | :-----: |
| Must initialise all `final` fields           |     ✅     |   ❌    |
| Can use `this.field` parameters              |     ✅     |   ❌    |
| Can use `super.param` / call `super(...)`    |     ✅     |   ❌    |
| Has `this` available in body                 |     ✅     |   ❌    |
| Can be `const`                               |     ✅     |   ❌    |
| Can `return` a value                         |     ❌     |   ✅    |
| Can return a cached / existing instance      |     ❌     |   ✅    |
| Can return a subtype                         |     ❌     |   ✅    |
| Can be the target of a subclass `super(...)` |     ✅     |   ❌    |
| Can be declared on an `abstract` class and called directly | ❌ | ✅ |
| Can contain arbitrary statements before construction | ❌ (initializer list only) | ✅ |

---

## 5. Pros and cons

### Generative constructor

**Pros**

- Guarantees a new, fully initialised instance of exactly this class.
- Supports `const`, enabling compile-time constants and `const` widget trees.
- Terse: `this.field` and `super.field` parameters remove boilerplate.
- Composable: subclasses can extend it via `super(...)`.
- Initializer list `assert`s run at construction with no extra ceremony.
- The compiler enforces that nothing is left uninitialised.

**Cons**

- Cannot return an existing or cached object.
- Cannot choose a subtype at runtime.
- Cannot run statements before fields are set; only initializer-list
  expressions are allowed, which pushes complex setup into private static
  helpers.
- Cannot be called on an abstract class.

### Factory constructor

**Pros**

- Full control over what is returned: new, cached, singleton, or subtype.
- Can contain any statements — validation, parsing, loops, early throws.
- Can be declared on an abstract class, letting an interface hide its
  concrete implementations (`factory Clock() = _SystemClock`).
- Redirecting form (`= OtherClass`) is zero-boilerplate for interface-to-impl
  mapping.

**Cons**

- Never `const`.
- No `this.field` / `super.field` parameters; every argument is re-typed and
  re-forwarded by hand.
- Cannot be the target of `super(...)`, so subclasses cannot build on it.
- Adds an indirection layer when all it does is call another constructor.
- Does not guarantee a fresh object, which can surprise callers who assume
  identity semantics.

---

## 6. Decision rule

Use a **generative** constructor by default. Switch to a **factory** only when
you need at least one of:

1. a cached, pooled, or singleton instance;
2. a subtype chosen at runtime;
3. statements (not just expressions) before the object exists;
4. a constructor on an abstract class or interface.

If none of those apply, `factory` is pure overhead.
