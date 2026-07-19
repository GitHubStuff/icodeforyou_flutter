# Cubit State Class Pattern: `abstract` / `sealed` / `final`

## Overview

These three modifiers target different sides of the state hierarchy and should not be conflated.

---

## `abstract class BaseServiceStatus` — The Contract

Defines the interface that all service states must satisfy. Any concrete state must provide `status` and `serviceItem`. Put here because it's shared across potentially multiple sealed hierarchies.

```dart
abstract class BaseServiceStatus {
  ServiceItemStatus get status;
  BaseServiceItem get serviceItem;
}
```

---

## `sealed class ServiceStatus` — The Exhaustiveness Boundary

Declares the closed set of variants. The compiler knows every possible subtype because `sealed` restricts subclassing to the same library. This is what makes `switch` exhaustive.

```dart
sealed class ServiceStatus extends BaseServiceStatus {}
```

It inherits the contract from `BaseServiceStatus` but adds no new members — its only job is to define the closed family.

---

## `final class ServiceLoaded` — A Concrete Variant

`final` prevents further subclassing, which is appropriate for leaf state classes. Must implement the abstract getters from `BaseServiceStatus`.

```dart
final class ServiceLoaded extends ServiceStatus {
  @override
  ServiceItemStatus get status => ServiceItemStatus.loaded;

  @override
  BaseServiceItem get serviceItem => ...;
}
```

---

## Why Not Just One Class?

| Class | Role | Why Separate |
|---|---|---|
| `BaseServiceStatus` | Contract | Reusable across multiple sealed families |
| `ServiceStatus` | Boundary | Scopes exhaustiveness to one hierarchy |
| `ServiceLoaded` | Variant | Concrete, instantiable, leaf node |

If you collapsed `BaseServiceStatus` into `ServiceStatus` you'd lose the ability to share the interface contract with other hierarchies — e.g. a `ServiceError` family that needs the same getters.
