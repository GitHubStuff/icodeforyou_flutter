// packages/since_when_service/lib/src/since_when_service_class.dart
// ignore_for_file: public_member_api_docs

import 'package:service_locator/service_locator.dart' show ServiceClass;
import 'package:since_when_framework/database.dart'
    show DatabaseHandle, DatabaseLifecycleCubit, DatabaseReady;

/// Service-locator handle for the database layer.
///
/// Owns a [DatabaseLifecycleCubit] that has already been opened and is
/// reporting [DatabaseReady] by the time the service finishes starting up.
/// Consumers read [cubit] for reactive lifecycle observation (via
/// `BlocBuilder<DatabaseLifecycleCubit, DatabaseLifecycleState>`) or
/// [handle] for direct SQL access when they know the database is ready.
///
/// Why expose the cubit and not just the handle: consumer widgets that
/// want to react to import/export/failure states need the cubit anyway.
/// Hiding it forces every consumer to wrap the handle in their own
/// state-management plumbing.
class SinceWhenServiceClass implements ServiceClass {
  const SinceWhenServiceClass(this.cubit);

  /// The lifecycle cubit, open and ready when the service is up. The cubit
  /// remains the owner of the connection; consumers observe and dispatch
  /// (`import`, `export`, `closeDatabase`) but do not replace it.
  final DatabaseLifecycleCubit cubit;

  /// Convenience accessor for the live [DatabaseHandle].
  ///
  /// Returns the handle directly when the cubit is in [DatabaseReady],
  /// throws [StateError] otherwise. Code that may run during import,
  /// export, or after close should observe [cubit] instead of calling
  /// this getter.
  DatabaseHandle get handle {
    final state = cubit.state;
    if (state is DatabaseReady) return state.handle;
    throw StateError(
      'SinceWhenServiceClass.handle called while cubit is in $state. '
      'Observe the cubit and read the handle from DatabaseReady, or '
      'call this getter only when you know the database is ready.',
    );
  }
}
