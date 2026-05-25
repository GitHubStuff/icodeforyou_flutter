// packages/ice_chips_service/lib/src/ice_chips_descriptor.dart

import 'package:ice_chips_service/src/ice_chips_service_class.dart';
import 'package:service_locator/service_locator.dart'
    show LazyAsyncServiceDescriptor;
import 'package:since_when_service/since_when_service.dart'
    show SinceWhenServiceClass;

/// Service-locator descriptor for [IceChipsServiceClass].
///
/// ## STUBBED — does not build a working service
///
/// The original descriptor read `SinceWhenServiceClass.db` (a
/// `SinceWhenDatabase` god-object) and constructed a `TagsCubit` from
/// it. That god-object no longer exists: `since_when_service` now
/// exposes a `DatabaseLifecycleCubit` (with a `DatabaseHandle` reachable
/// through it), and `TagsCubit` now depends on four narrow role-segregated
/// interfaces — `GlossaryReader`, `GlossaryRepository`, `GlossaryWriter`,
/// `GlossaryDeleter` — that have no implementation against the new
/// framework yet. Those implementations are the job of the future
/// `since_when` package.
///
/// Until that package ships, this descriptor's [builder] throws
/// [UnimplementedError] with a clear migration message. The dependency
/// declaration on [SinceWhenServiceClass] is preserved so the registry
/// orders startup correctly the day the builder is wired up.
///
/// ## Migration steps when the real `since_when` package arrives
///
/// 1. Add `since_when: ^x.y.z` to `pubspec.yaml`.
/// 2. Replace [builder]'s body with:
///    ```dart
///    final sinceWhen = ServiceRegistry.R.getSync<SinceWhenServiceClass>('SinceWhen');
///    final glossary = SinceWhen.glossary(sinceWhen.handle); // or similar
///    final tagsCubit = TagsCubit(
///      reader:     glossary,
///      repository: glossary,
///      writer:     glossary,
///      deleter:    glossary,
///    );
///    await tagsCubit.load().timeout(timeout);
///    return IceChipsServiceClass(tagsCubit);
///    ```
///    The exact constructor on the real `since_when` package will determine
///    the shape — the placeholder above assumes one repository object
///    implements all four narrow interfaces, which is the most common pattern.
/// 3. Restore the `try { ... } on TimeoutException { throw ServiceItemTimeout(...) }`
///    wrapper around the `load().timeout(...)` call.
/// 4. Remove this entire doc-comment block and the [UnimplementedError]
///    throw.
///
/// This service does not register `SinceWhen` — it consumes it. The
/// composition root is responsible for staging both descriptors with
/// the registry.
class IceChipsDescriptor
    extends LazyAsyncServiceDescriptor<IceChipsServiceClass> {
  /// Default-constructible descriptor.
  const IceChipsDescriptor();

  @override
  String get name => 'IceChips';

  @override
  List<Type> get dependencies => const [SinceWhenServiceClass];

  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<IceChipsServiceClass> Function() get builder => () async {
    throw UnimplementedError(
      'IceChipsDescriptor.builder is stubbed pending the new `since_when` '
      'package. See the class doc-comment for migration steps. The '
      'descriptor itself is otherwise wired correctly: dependency on '
      'SinceWhenServiceClass, name "IceChips", and 5-second timeout are '
      'all preserved so the registry orders startup correctly the day '
      'the builder body is restored.',
    );
  };
}
