# ice_chips_service

Service-locator integration that exposes a fully-loaded `TagsCubit` (from `ice_chips`) backed by the `SinceWhen` service's database. Other services declare a dependency on this one and read the cubit from the locator.

> **Status: stubbed.** The descriptor's builder currently throws `UnimplementedError` pending the new `since_when` package. The descriptor itself — name, dependency declaration, and timeout — is wired correctly so the registry orders startup the right way the day the builder body is restored. See [Stub status and migration](#stub-status-and-migration) below.

## Features

- **`IceChipsServiceClass`** — `ServiceClass` handle exposing a single loaded `TagsCubit` field.
- **`IceChipsDescriptor`** — `LazyAsyncServiceDescriptor<IceChipsServiceClass>` registered under the name `'IceChips'`, depending on `SinceWhenServiceClass`, with a 5-second build timeout.
- **Eager initial load** — when the builder is implemented, the `TagsCubit`'s initial `load()` will complete before the service is marked ready, so consumers see `TagsLoaded` (or `TagsError`) immediately on first build.
- **Re-exports `ice_chips`** — single import gives you the descriptor, the handle, and the `TagsCubit` / `TagsState` / `IcePickerTray` types needed to wire the cubit into widgets.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ice_chips_service: ^1.0.0
```

Then import the barrel where you wire up services and where you consume the cubit:

```dart
import 'package:ice_chips_service/ice_chips_service.dart';
```

This single import gives you `IceChipsDescriptor`, `IceChipsServiceClass`, and everything `ice_chips` exports (`TagsCubit`, `TagsState`, `IcePickerTray`, `IceChipsTray`, the layout strategies, etc.).

This package depends on `since_when_service` but does **not** register it. The composition root is responsible for staging both `IceChipsDescriptor` and `SinceWhenDescriptor` with the registry — the locator will then order startup so `SinceWhen` is ready before `IceChips` builds.

## Usage

### Register the descriptor

The descriptor is `const`-constructible and declares its own name, dependencies, and timeout:

```dart
const IceChipsDescriptor()
// name:         'IceChips'
// dependencies: [SinceWhenServiceClass]
// timeout:      5 seconds
```

Stage it alongside the `SinceWhen` descriptor at your composition root. The exact registration call depends on your `service_locator` setup; both descriptors must be present before startup runs.

### Consume the handle from a widget

Once the service has built, retrieve `IceChipsServiceClass` from the locator and wire its `tagsCubit` into the widget tree with `BlocProvider.value`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips_service/ice_chips_service.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key, required this.iceChips});

  final IceChipsServiceClass iceChips;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: iceChips.tagsCubit),
        BlocProvider(create: (_) => IceChipsTrayCubit()),
      ],
      child: const Scaffold(
        body: IcePickerTray(
          layout: IceChipsTrayLayoutWrap(spacing: 8, runSpacing: 8),
        ),
      ),
    );
  }
}
```

The cubit is `BlocProvider.value`'d — not created — because the service owns its lifecycle. The selection cubit (`IceChipsTrayCubit`), by contrast, is screen-scoped and created in place.

### Consume the handle from another service

When another service needs the `TagsCubit`, depend on `IceChipsServiceClass` in your descriptor and read `tagsCubit` from it:

```dart
class MyFeatureDescriptor extends LazyAsyncServiceDescriptor<MyFeature> {
  const MyFeatureDescriptor();

  @override
  String get name => 'MyFeature';

  @override
  List<Type> get dependencies => const [IceChipsServiceClass];

  @override
  Future<MyFeature> Function() get builder => () async {
    final iceChips = /* resolve IceChipsServiceClass from the locator */;
    return MyFeature(tags: iceChips.tagsCubit);
  };

  @override
  Duration get timeout => const Duration(seconds: 2);
}
```

## Stub status and migration

`IceChipsDescriptor.builder` currently throws `UnimplementedError` with a descriptive message. The descriptor still declares the correct `name`, `dependencies`, and `timeout`, so the registry orders startup correctly today — the only thing missing is the builder body that constructs the `TagsCubit`.

Why it's stubbed: the original descriptor read a `SinceWhenDatabase` god-object from `SinceWhenServiceClass` and passed it to `TagsCubit`. That god-object no longer exists. `since_when_service` now exposes a `DatabaseLifecycleCubit` with a `DatabaseHandle`, and `TagsCubit` now depends on four narrow role-segregated interfaces (`GlossaryReader`, `GlossaryRepository`, `GlossaryWriter`, `GlossaryDeleter`) that have no implementation against the new framework yet. Those implementations are the job of the forthcoming `since_when` package.

When the real `since_when` package ships, the migration is mechanical (the exact constructor shape will follow whatever the real package exposes; the placeholder below assumes one object implements all four narrow interfaces, which is the common pattern):

1. Add `since_when: ^x.y.z` to `pubspec.yaml`.
2. Replace `IceChipsDescriptor.builder`'s body with something like:
   ```dart
   final sinceWhen = ServiceRegistry.R.getSync<SinceWhenServiceClass>('SinceWhen');
   final glossary = SinceWhen.glossary(sinceWhen.handle);
   final tagsCubit = TagsCubit(
     reader:     glossary,
     repository: glossary,
     writer:     glossary,
     deleter:    glossary,
   );
   await tagsCubit.load().timeout(timeout);
   return IceChipsServiceClass(tagsCubit);
   ```
3. Restore the `try { ... } on TimeoutException { throw ServiceItemTimeout(...) }` wrapper around the `load().timeout(...)` call.
4. Remove the stub doc-comment block and the `UnimplementedError` throw.

## Additional information

`IceChipsDescriptor` does not register `SinceWhen`. The composition root must stage `SinceWhenDescriptor` alongside it; the locator handles ordering via the declared `[SinceWhenServiceClass]` dependency. Once the builder is implemented, the cubit's initial `load()` completes before the service is marked ready, so the first widget build will see `TagsLoaded` (or `TagsError`) rather than `TagsInitial` or `TagsLoading`.
