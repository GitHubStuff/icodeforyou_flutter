// packages/ice_chips_service/lib/ice_chips_service.dart
// ignore_for_file: comment_references

/// Service-locator integration providing a [TagsCubit] backed by the
/// `SinceWhen` service's database.
///
/// ## STUBBED
///
/// [IceChipsDescriptor.builder] throws [UnimplementedError] until the
/// new `since_when` package ships glossary repository implementations
/// against the framework's `DatabaseHandle`. See the descriptor's
/// doc-comment for migration steps.
///
/// Provides:
///
/// - [IceChipsServiceClass] — the `ServiceClass` handle exposing the
///   loaded [TagsCubit].
/// - [IceChipsDescriptor] — the `LazyAsyncServiceDescriptor`. Dependency
///   declarations are valid; builder is stubbed.
///
/// This package depends on `since_when_service` but does not register
/// it. The composition root must stage both [IceChipsDescriptor] and
/// `SinceWhenDescriptor` with the registry; the locator orders the
/// startup based on the declared dependency.
///
/// Re-exports `ice_chips` for consumer convenience — any code holding
/// an [IceChipsServiceClass] needs the [TagsCubit] type and the
/// [TagsState] hierarchy to wire it into widgets.
library;

export 'package:ice_chips/ice_chips.dart';

export 'src/ice_chips_descriptor.dart';
export 'src/ice_chips_service_class.dart';
