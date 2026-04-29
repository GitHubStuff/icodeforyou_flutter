# service_locator

A declarative service registry for Flutter/Dart applications. Stage
service descriptors at your composition root, register them
(automatically resolving dependencies), and resolve instances from
anywhere in your widget tree — with compile-time type safety,
stage-time cycle detection, and a test-friendly mock implementation.

Built on [`get_it`](https://pub.dev/packages/get_it) in production and
a hand-rolled in-memory locator in tests. Both surface the same error
types so test assertions hold against production behavior.

## Features

- **Declarative descriptors.** Services are described by `const`
  `SyncServiceDescriptor` or `LazyAsyncServiceDescriptor` subclasses,
  not registered imperatively. Descriptors live in `const` lists at
  the composition root.
- **Automatic dependency resolution.** Descriptors declare
  dependencies by `Type`; calling `register('auth')` transitively
  registers everything `auth` depends on before registering `auth`
  itself.
- **Stage-time cycle detection.** `CircularDependency` fires at
  `register()` entry before any registration work begins — cycles
  can't strand the caller in a `pendingStart` deadlock. The check
  runs over the full staged graph, so unrelated cycles anywhere in
  the configuration are surfaced immediately.
- **Typed error surface.** Every failure mode is a subclass of
  `ServiceError` (itself a `StateError`): `BlankServiceName`,
  `DuplicateServiceEntry`, `DuplicateServiceType`, `ServiceNotRegistered`,
  `ServiceNotReady`, `ServiceItemTimeout`, `ServiceStartupFailed`,
  `CircularDependency`, `InvalidServiceType`, and more. Catch at
  whatever precision you need.
- **ISP-split interfaces.** `ServiceRegistrar` (write side) goes to
  bootstrap code; `ServiceResolver` (read side) goes to widgets and
  downstream consumers. Widgets can't accidentally register services.
- **Sync and lazy-async registration modes.** Eager instances for
  value objects and in-memory repositories; lazy-async builders for
  anything that performs I/O (databases, remote config, platform
  channels).
- **Concurrency-safe.** Concurrent `register` calls on the same name
  are serialized by an atomic `staged → starting` claim; concurrent
  callers share a single `pendingStart` future and observe identical
  terminal state.
- **Canonical failure identity.** When a service fails to start, the
  `ServiceStartupFailed` wrapper is constructed once and cached on the
  registration — every observer (original thrower, concurrent
  awaiter, later `getAsync`/`getSync`/`register`) receives the same
  exception object with the original stack trace preserved.
- **Deterministic test hooks.** `MockServiceLocator` ships with
  `completeLazyService` and `failLazyService` for manually settling
  lazy-async registrations without racing a real builder.

## Getting started

### Prerequisites

- Dart SDK `>=3.22.0 <4.0.0`
- Flutter (the package depends on `flutter_bloc` and `flutter_test`)

### Installation

Add the package to `pubspec.yaml` via a path, git, or pub dependency
(adjust to your setup):

```yaml
dependencies:
  service_locator:
    path: ../service_locator
```

The package depends on an in-house `extensions` package for its
stage-time cycle-detection helper. If you're vendoring the
`service_locator` package, vendor the `extensions` package alongside
it.

## Usage

### Define a service contract and its descriptor

```dart
import 'package:service_locator/service_locator.dart';

abstract interface class AuthService implements ServiceClass {
  String get token;
}

class _RealAuth implements AuthService {
  _RealAuth(this.token);
  @override
  final String token;
}

class AuthDescriptor extends LazyAsyncServiceDescriptor<AuthService> {
  const AuthDescriptor();

  @override
  String get name => 'auth';

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<AuthService> Function() get builder =>
      () async => _RealAuth(await _fetchToken());
}

Future<String> _fetchToken() async {
  // ...real work...
  return 'bearer-abc';
}
```

### Wire up at the composition root

```dart
import 'package:service_locator/service_locator.dart';

Future<void> main() async {
  final registry = ServiceLocatorRegistry(
    locator: GetItServiceLocator(),
  );

  // Stage every service (no builder runs yet).
  registry
    ..stage(const AuthDescriptor())
    ..stage(const DatabaseDescriptor())
    ..stage(const UserRepositoryDescriptor());

  // Register the root service; transitively registers its deps.
  await registry.register('user-repo');

  // Hand widgets the read-only view.
  runApp(MyApp(resolver: registry));
}
```

### Resolve in widgets

```dart
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.resolver});

  final ServiceResolver resolver;

  @override
  Widget build(BuildContext context) {
    final auth = resolver.getSync<AuthService>('auth');
    return Text(auth.token);
  }
}
```

Downstream widgets hold `ServiceResolver`, not `ServiceLocatorRegistry`
or `ServiceRegistrar` — so they can resolve services but can't stage
or register new ones. The ISP split makes accidental mutation a
compile-time error.

### Declare dependencies by type

```dart
class UserRepositoryDescriptor
    extends SyncServiceDescriptor<UserRepository> {
  const UserRepositoryDescriptor();

  @override
  String get name => 'user-repo';

  @override
  List<Type> get dependencies => const [AuthService, DatabaseService];

  @override
  UserRepository Function() get builder =>
      () => UserRepository(
            // Resolved by the registry before this builder runs.
            auth: /* ... */,
            db: /* ... */,
          );
}
```

The registry walks `dependencies` when you call `register('user-repo')`,
registering `AuthService` and `DatabaseService` first (and recursively
their own dependencies) before `UserRepository`'s builder runs.

### Use the mock in tests

```dart
import 'package:service_locator/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockServiceLocator mock;
  late ServiceLocatorRegistry registry;

  setUp(() {
    mock = MockServiceLocator();
    registry = ServiceLocatorRegistry(locator: mock);
    registry.stage(const AuthDescriptor());
  });

  tearDown(() => mock.reset());

  test('widget renders the current token', () async {
    await registry.register('auth');
    // Drive the lazy-async service to `ready` with a test instance —
    // no racing against the real builder.
    mock.completeLazyService<AuthService>(
      name: 'auth',
      instance: _FakeAuth('test-token'),
    );
    expect(registry.getSync<AuthService>('auth').token, 'test-token');
  });
}
```

The mock produces the same error types as the GetIt adapter, so tests
assert against the same `ServiceNotReady`, `ServiceItemTimeout`,
`DuplicateServiceEntry`, and so on that production code will observe.

## Architecture

The package is organized into four layers:

| Layer | Files | Purpose |
| --- | --- | --- |
| **Descriptors** | `service_descriptor.dart` | Declarative value types (`ServiceDescriptor` sealed hierarchy, the `ServiceClass` marker) |
| **Locator abstraction** | `service_locator.dart`, `getit_service_locator.dart`, `mock_service_locator.dart` | `ServiceLocator` interface + two implementations |
| **Registry** | `service_locator_registry.dart` + `_interfaces.dart` + `_state_change.dart` (part) | Orchestrates staging, dependency resolution, lifecycle, and concurrency |
| **State & errors** | `service_registration.dart`, `locator_status.dart`, `errors.dart` | Per-registration state machine, status enum, sealed error hierarchy |

Design principles applied throughout:

- **SRP.** `register()`, `getAsync()`, and `getSync()` each delegate
  state-specific handling to small, focused helpers.
- **OCP.** `ServiceDescriptor`'s sealed hierarchy drives behavior; the
  registry does not switch on descriptor type.
- **DIP.** The registry depends on the `ServiceLocator` abstraction,
  not on any concrete implementation.
- **ISP.** Write-side (`ServiceRegistrar`) and read-side
  (`ServiceResolver`) responsibilities are exposed as narrow
  interfaces; consumers depend only on what they need.
- **Tell, Don't Ask.** Registration state transitions and
  terminal-error construction live on `ServiceRegistration`, not on
  the registry.

## Additional information

- **Test coverage.** The package targets 100% LCOV coverage.
  Unreachable defensive branches (`WaitingTimeOutException` fallback
  in the GetIt adapter, unreachable switch arms in `_awaitNonStaged`)
  are explicitly excluded via `// coverage:ignore-start` /
  `// coverage:ignore-end` pragmas with documented rationale.

- **File size budget.** Source files cap at 500 lines. Larger
  cohesive units split via `part`/`part of` (e.g. the registry's
  state-change dispatch) or via sibling files (e.g. the `ISP`
  interfaces file).

- **Issues and contributions.** This is an in-house package. File
  issues or PRs against the internal repository; expect review within
  a business day.
