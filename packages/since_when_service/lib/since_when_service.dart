// packages/since_when_service/lib/since_when_service.dart
// ignore_for_file: comment_references

/// Service-locator integration for the `since_when_framework` database
/// layer.
///
/// Provides:
///
/// - [SinceWhenServiceClass] — the `ServiceClass` handle exposing a
///   pre-opened [DatabaseLifecycleCubit] (and a convenience [handle]
///   getter for direct SQL access).
/// - [SinceWhenDescriptor] — the `LazyAsyncServiceDescriptor` that
///   builds the cubit, opens it against a [DatabaseConfiguration], runs
///   any registered [DatabaseSetup] contributions, and waits for the
///   cubit to reach [DatabaseReady] before handing the service back to
///   the locator. Three named constructors mirror the three
///   [DatabaseConfiguration] variants: `.documents`, `.applicationSupport`,
///   `.inMemory`. A `.fromConfiguration` escape hatch is available for
///   callers that already hold a configuration value.
///
/// This package is a pure data-access service. It does not depend on
/// state-management beyond `flutter_bloc` (transitive via the framework)
/// and does not depend on the UI layer. Other services that need
/// database access declare a dependency on [SinceWhenServiceClass] and
/// observe its `cubit` or read its `handle` from the locator.
///
/// Re-exports the database layer of `since_when_framework` for consumer
/// convenience — any code holding a [SinceWhenServiceClass] needs the
/// [DatabaseLifecycleCubit], [DatabaseHandle], and [DatabaseFailure]
/// types to use it.
library;

export 'package:since_when_framework/database.dart';

export 'src/since_when_descriptor.dart';
export 'src/since_when_service_class.dart';
