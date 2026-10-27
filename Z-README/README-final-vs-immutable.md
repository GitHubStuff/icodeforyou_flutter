# `final class` vs `@immutable` in Dart

Two orthogonal concepts. One controls **who can subtype**, the other documents **whether instances can mutate**. They sound related but aren't.

## `final class` — a subtyping restriction

Dart 3 class modifier. It means: outside this library, nobody can `extend`, `implement`, or `mixin` this class. Says absolutely nothing about the mutability of instances. You can have a `final class` full of mutable fields:

```dart
final class Counter {
  int value = 0; // mutable, perfectly legal
  void increment() => value++;
}
```

Enforced by the **compiler**. Violations are errors.

## `@immutable` — a mutability contract

From the `meta` package. It means: this class and all its subclasses must have only `final` fields. It's what `StatelessWidget` and `Equatable` carry, which is why the analyzer yells when a widget has a non-final field.

Enforced only by the **analyzer** (`must_be_immutable` lint), not the compiler. And it says nothing about subtyping — anyone can extend an `@immutable` class; they just inherit the contract.

## When to use both

Tag a `final class` with `@immutable` when **both** things are true:

1. **You're sealing the type** — it's a leaf in your hierarchy, no external subclassing intended (value objects, sealed-hierarchy variants, temporal interval types like those in `time_spans`).
2. **It's a value type** — all fields `final`, equality/`hashCode` based on fields, safe to use as map keys, safe to share across isolates conceptually.

```dart
@immutable
final class TimeSpan {
  const TimeSpan(this.start, this.end);
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) => /* ... */;
  @override
  int get hashCode => /* ... */;
}
```

This combo is the Dart equivalent of "this is a closed value object" — common for Cubit states, domain models, and anything Freezed would generate (Freezed does effectively both for you).

## When `@immutable` is redundant-ish

- **Extending `Equatable`** — it's already `@immutable`, the annotation is inherited. Adding it again is harmless noise.
- **Using Freezed** — generated code handles it.
- **`const` constructor + all-final fields with no annotation** — instances are already immutable in practice; the annotation just makes the analyzer enforce it on you and any subclasses. Since `final class` blocks external subclasses anyway, the annotation's main remaining value is catching *your own* future mistake of adding a mutable field. Cheap insurance; still worth adding.

## Rule of thumb

| Question | Answered by |
|---|---|
| Can others subtype this? | `final class` |
| Can instances change? | `@immutable` |

For BLoC/Cubit states and domain value objects, the answer to both is usually **no** — so use both.
