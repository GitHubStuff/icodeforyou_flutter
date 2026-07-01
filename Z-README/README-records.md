# Records in Dart / Flutter

Records are anonymous, immutable, value-typed bundles of fields. Added in Dart 3 (2023). Think "tuple, but with optional field names and structural typing."

## Shape

A record value uses parentheses; the type mirrors the value.

```dart
// Values
(1, 2)                        // positional
(name: 'Bob', age: 40)        // named
('hello', count: 5)           // mixed

// Types
(int, int)
({String name, int age})
(String, {int count})
```

Declare variables directly, or `typedef` for readability:

```dart
(int, int) pair = (1, 2);

typedef Person = ({String name, int age});
Person bob = (name: 'Bob', age: 40);
```

## What makes them different from classes

- **Structural typing.** Two records are the same type if their shapes match. No declaration required — `(1, 2)` and `(3, 4)` are both `(int, int)`.
- **Free value equality.** `(1, 2) == (1, 2)` is `true`. `hashCode` is built from fields. No `Equatable`, no `freezed` boilerplate.
- **Immutable.** No setters. To "change" a field, build a new record.
- **No methods, no inheritance, no named constructors, no private fields.** A record is just its fields. Behavior comes only via extensions on the structural type.

## Accessing fields

Positional fields use `$1`, `$2`, `$3`, …:

```dart
final pair = (1, 2);
pair.$1; // 1
pair.$2; // 2
```

Named fields use the name:

```dart
final p = (name: 'Bob', age: 40);
p.name; // 'Bob'
p.age;  // 40
```

## Destructuring

The killer ergonomic feature. Works in declarations, assignments, and patterns.

```dart
final (a, b) = (1, 2);              // a = 1, b = 2
final (name: n, age: yrs) = bob;    // n = 'Bob', yrs = 40
final (name: n, age: _) = bob;      // ignore age with _
```

In `switch`:

```dart
String describe((int, int) point) => switch (point) {
  (0, 0) => 'origin',
  (_, 0) => 'on x-axis',
  (0, _) => 'on y-axis',
  (final x, final y) when x == y => 'diagonal at $x',
  _ => 'somewhere',
};
```

## Arity

Records have no fixed size. Any number of fields, positional and/or named.

```dart
(int, int, int, int, int) five() => (1, 2, 3, 4, 5);

({String name, int age, String email, DateTime joined}) user() =>
    (name: 'Bob', age: 40, email: 'bob@example.com', joined: DateTime.now());

(String, String, {int line, int column}) location() =>
    ('main.dart', 'parse error', line: 42, column: 7);
```

Past three or four fields, prefer named over positional — `r.$7` is unreadable, `r.email` isn't. Past five or six, consider a class instead.

## The killer use case: multiple return values

```dart
(int min, int max) bounds(List<int> xs) {
  xs.sort();
  return (xs.first, xs.last);
}

final (min: lo, max: hi) = bounds([3, 1, 4, 1, 5]);
```

Names in the return type are type-level documentation. The caller can destructure positionally if they don't care about the labels.

## Extensions for behavior

Records can't have methods, but extensions on the structural type can:

```dart
extension on (int, int) {
  int get sum => $1 + $2;
}

(3, 4).sum; // 7
```

## When to use records vs classes

**Records** when:
- The data is transient (function return, intermediate computation).
- You don't need methods, named constructors, or a stable type name across the codebase.
- You want free equality without `freezed` / `Equatable` boilerplate.

**Classes** when:
- The type has behavior (methods, computed properties beyond a tiny extension).
- The type is a domain concept that should appear in error messages, type signatures, and APIs by name. `Range range = Range(0, 5)` is clearer than `(num, num) range = (0, 5)`.
- You need subtyping, mixins, sealed hierarchies, private fields, or `const` constructors with assertions.

Rule of thumb: if you'd name the class, use a class. If you'd call it "the pair" or "the result," use a record.

## Footguns

- Mixing shapes in a collection widens to `Record` (the supertype) and you lose field access. `[(1, 2), (1, 2, 3)]` infers `List<Record>`.
- Inline record types get noisy in generics: `Map<String, ({double lat, double lng})>`. A `typedef` cleans it up.
- Records are **not** JSON-serializable out of the box. No `toJson` / `fromJson`. For anything crossing a wire, use a class — likely with `freezed` or `json_serializable`.
- Records can't `implements` or `extends` anything. They're not in the class hierarchy.
- `const (1, 2)` works when all fields are const, but the `const` keyword is usually unnecessary — record literals are canonicalized when all fields are constants.
